library IEEE;
use IEEE.std_logic_1164.all;
use work.bus_32.all;

entity tb_mux32to1_32 is
    generic(gCLK_HPER   : time := 10 ns);
end tb_mux32to1_32;

architecture tb of tb_mux32to1_32 is
    component mux32to1_32 is
        port(
            i_D     : in t_bus_32x32;
            i_S     : in std_logic_vector(5-1 downto 0);
            o_Q     : out std_logic_vector(32-1 downto 0)
        );
    end component;

    signal s_D      : t_bus_32x32;
    signal s_S      : std_logic_vector(5-1 downto 0);
    signal s_O      : std_logic_vector(32-1 downto 0);

begin
    G_MUX: mux32to1_32 port map(
        i_D     => s_D,
        i_S     => s_S,
        o_Q     => s_O
    );

    P_TEST: process
    begin
        s_D(0) <= x"FFFF0000";
        s_D(1) <= x"0FFFF000";
        s_D(2) <= x"00FFFF00";
        s_D(3) <= x"0000FFFF";
        s_D(4) <= x"00000FFF";
        s_D(5) <= x"000000FF";

        s_S <= "00000";
        wait for gCLK_HPER;

        s_S <= "00001";
        wait for gCLK_HPER;

        s_S <= "00010";
        wait for gCLK_HPER;

        s_S <= "00011";
        wait for gCLK_HPER;

        s_S <= "00100";
        wait for gCLK_HPER;

        s_S <= "00101";
        wait for gCLK_HPER;

        wait;
    end process;
end tb;