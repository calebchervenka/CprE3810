library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux32to1 is
    generic(gCLK_HPER   : time := 10 ns);
end tb_mux32to1;

architecture tb of tb_mux32to1 is
    component mux32to1 is
        port(
            i_D     : in std_logic_vector(32-1 downto 0);
            i_S     : in std_logic_vector(5-1 downto 0);
            o_Q     : out std_logic
        );
    end component;

    signal s_D      : std_logic_vector(32-1 downto 0);
    signal s_S      : std_logic_vector(5-1 downto 0);
    signal s_O      : std_logic;

begin
    G_MUX: mux32to1 port map(
        i_D     => s_D,
        i_S     => s_S,
        o_Q     => s_O
    );

    P_TEST: process
    begin
        s_D <= x"FFFF0000";
        s_S <= "00000";
        wait for gCLK_HPER;

        s_S <= "00100";
        wait for gCLK_HPER;

        s_S <= "01000";
        wait for gCLK_HPER;

        s_S <= "11000";
        wait for gCLK_HPER;

        s_S <= "11001";
        wait for gCLK_HPER;

        wait;
    end process;
end tb;