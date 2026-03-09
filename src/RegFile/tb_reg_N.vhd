library IEEE;
use IEEE.std_logic_1164.all;

entity tb_reg_N is
    generic(gCLK_HPER   : time := 10ns);
end tb_reg_N;

architecture mixed of tb_reg_N is

    component reg_N is
        generic (N : integer := 32);
        port(
            i_CLK   : in std_logic; -- Clock input
            i_RST   : in std_logic; -- Reset input
            i_WE    : in std_logic; -- Write enable input
            i_D     : in std_logic_vector(N-1 downto 0); -- Data value input
            o_Q     : out std_logic_vector(N-1 downto 0) -- Data value output
        );
    end component;
    
    constant N : integer := 32;
    signal s_CLK        : std_logic;
    signal s_RST        : std_logic;
    signal s_WE         : std_logic;
    signal s_D          : std_logic_vector(N-1 downto 0);
    signal s_Q          : std_logic_vector(N-1 downto 0);

begin
    p_reg: reg_N generic map(N => N) port map(
        i_CLK   => s_CLK,
        i_RST   => s_RST,
        i_WE    => s_WE,
        i_D     => s_D,
        o_Q     => s_Q
    );

    P_CLK: process
    begin
        s_CLK <= '1';
        wait for gCLK_HPER;
        s_CLK <= '0';
        wait for gCLK_HPER;
    end process;

    P_TEST: process
    begin
        wait for gCLK_HPER/2;

        -- Reset
        s_RST   <= '1';
        s_WE    <= '0';
        s_D     <= x"00000000";
        wait for gCLK_HPER*2;

        -- Load 0x01234567
        s_RST   <= '0';
        s_WE    <= '1';
        s_D     <= x"01234567";
        wait for gCLK_HPER*2;

        -- Disable write
        s_RST   <= '0';
        s_WE    <= '1';
        s_D     <= x"00000000";
        wait for gCLK_HPER*2;
    end process;
end mixed;