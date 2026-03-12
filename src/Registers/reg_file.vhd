library IEEE;
use IEEE.std_logic_1164.all;
use work.bus_32.all;

entity reg_file is
    generic(
        address_width   : integer := 5;
        reg_count       : integer := 32;   
        data_width      : integer := 32
    );

    port(
        i_WD        : in std_logic_vector(data_width-1 downto 0);       -- Write data
        o_RD0       : out std_logic_vector(data_width-1 downto 0);      -- Read data 0
        o_RD1       : out std_logic_vector(data_width-1 downto 0);      -- Read data 1

        i_RS0       : in std_logic_vector(address_width-1 downto 0);    -- Register source 0, address for read data 0
        i_RS1       : in std_logic_vector(address_width-1 downto 0);    -- Register source 1, address for read data 1
        i_RD        : in std_logic_vector(address_width-1 downto 0);    -- Register destination

        i_CLK       : in std_logic; -- Clock
        i_RST       : in std_logic; -- Reset all registers
        i_WE        : in std_logic  -- Write enable
    );
end reg_file;

architecture structural of reg_file is

    component mux32to1_32 is
        port(
            i_D    : in t_bus_32x32;
            i_S     : in std_logic_vector(5-1 downto 0);
            o_Q     : out std_logic_vector(32-1 downto 0)
        );
    end component;
        
    component decoder5to32 is
        port(
            i_S     : in std_logic_vector(5-1 downto 0);
            o_Q     : out std_logic_vector(32-1 downto 0)
        );
    end component;

    component reg_N is
        generic(N : integer);
        port(
            i_CLK   : in std_logic; -- Clock input
            i_RST   : in std_logic; -- Reset input
            i_WE    : in std_logic; -- Write enable input
            i_D     : in std_logic_vector(data_width-1 downto 0); -- Data value input
            o_Q     : out std_logic_vector(data_width-1 downto 0) -- Data value output
        );
    end component;

    component andg2 is
        port(i_A        : in std_logic;
            i_B         : in std_logic;
            o_F         : out std_logic
        );
    end component;

    signal s_rd_decoder    : std_logic_vector(reg_count-1 downto 0) := x"00000000" ; -- Output from decoder
    signal s_rd_we         : std_logic_vector(reg_count-1 downto 0); -- Output from decoder, AND with write enable
    signal s_reg_d         : t_bus_32x32;
    
begin
    c_register_decoder : decoder5to32 port map(
        i_S     => i_RD,
        o_Q     => s_rd_decoder
    );

    c_and_N : for i in 32-1 downto 0 generate
        c_and_I : andg2 port map(
            i_A     => s_rd_decoder(i),
            i_B     => i_WE,
            o_F     => s_rd_we(i)
        );
    end generate c_and_N;

    s_reg_d(0) <= (others => '0');
    c_reg_N : for i in 32-1 downto 1 generate
        c_reg_I : reg_N
        generic map (N => reg_count)
        port map(
            i_CLK   => i_CLK,
            i_RST   => i_RST,
            i_WE    => s_rd_we(i),
            i_D     => i_WD,
            o_Q     => s_reg_d(i)
        );
    end generate c_reg_N;

    c_mux_0 : mux32to1_32 port map(
        i_D => s_reg_d,
        i_S => i_RS0,
        o_Q => o_RD0
    );

    c_mux_1 : mux32to1_32 port map(
        i_D     => s_reg_d,
        i_S     => i_RS1,
        o_Q     => o_RD1
    );

end structural;