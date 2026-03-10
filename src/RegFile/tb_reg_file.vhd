-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for a register file.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use work.bus_32.all;

entity tb_reg_file is
end tb_reg_file;

architecture behavioral of tb_reg_file is
    component reg_file is
        generic(
            address_width   : integer := 5;
            reg_count       : integer := 32;   
            data_width      : integer := 32
        );
        port(
            i_WD        : in std_logic_vector(data_width-1 downto 0);
            o_RD0       : out std_logic_vector(data_width-1 downto 0);
            o_RD1       : out std_logic_vector(data_width-1 downto 0);
            i_RS0       : in std_logic_vector(address_width-1 downto 0);
            i_RS1       : in std_logic_vector(address_width-1 downto 0);
            i_RD        : in std_logic_vector(address_width-1 downto 0);
            i_CLK       : in std_logic;
            i_RST       : in std_logic;
            i_WE        : in std_logic
        );
    end component;

    -- Test signals
    signal s_i_WD       : std_logic_vector(31 downto 0);
    signal s_o_RD0      : std_logic_vector(31 downto 0);
    signal s_o_RD1      : std_logic_vector(31 downto 0);
    signal s_i_RS0      : std_logic_vector(4 downto 0);
    signal s_i_RS1      : std_logic_vector(4 downto 0);
    signal s_i_RD       : std_logic_vector(4 downto 0);
    signal s_i_CLK      : std_logic := '0';
    signal s_i_RST      : std_logic := '0';
    signal s_i_WE       : std_logic := '0';

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the register file
    dut : reg_file port map(
        i_WD    => s_i_WD,
        o_RD0   => s_o_RD0,
        o_RD1   => s_o_RD1,
        i_RS0   => s_i_RS0,
        i_RS1   => s_i_RS1,
        i_RD    => s_i_RD,
        i_CLK   => s_i_CLK,
        i_RST   => s_i_RST,
        i_WE    => s_i_WE
    );

    -- Clock generation
    process
    begin
        s_i_CLK <= '0';
        wait for CLK_PERIOD / 2;
        s_i_CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Test process
    process
    begin
        -- Initialize
        s_i_RST <= '1';
        s_i_WE <= '0';
        s_i_RD <= "00001";  -- Write to register 1
        s_i_RS0 <= "00001"; -- Read from register 1
        s_i_RS1 <= "00010"; -- Read from register 2
        s_i_WD <= x"00000000";
        wait for CLK_PERIOD;
        
        -- Release reset
        s_i_RST <= '0';
        wait for CLK_PERIOD;

        -- Test 1: Enable write signal and store data in register 1
        s_i_WE <= '1';
        s_i_RD <= "00001";
        s_i_WD <= x"DEADBEEF";
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;  -- Wait for write to complete

        -- Test 2: Disable write signal and change input data
        s_i_WE <= '0';
        s_i_WD <= x"CAFEBABE";  -- Change input data
        s_i_RD <= "00010";        -- Try to write to register 2 (should fail due to WE=0)
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;

        -- Verify that register 1 still holds old data
        s_i_RS0 <= "00001";
        wait for CLK_PERIOD;
        
        -- Test 3: Trigger reset
        s_i_RST <= '1';
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;

        -- Verify all registers are reset to 0
        s_i_RST <= '0';
        s_i_RS0 <= "00001";
        s_i_RS1 <= "00001";
        wait for CLK_PERIOD;

        -- Simulation complete
        wait;
    end process;

end behavioral;
