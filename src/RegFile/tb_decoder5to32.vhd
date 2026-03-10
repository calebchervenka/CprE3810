-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_decoder5to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for a 5:32 decoder.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder5to32 is
    generic(gCLK_HPER   : time := 10 ns);
end tb_decoder5to32;

architecture tb of tb_decoder5to32 is
    component decoder5to32 is
        port(
            i_S     : in std_logic_vector(5-1 downto 0);
            o_Q     : out std_logic_vector(32-1 downto 0)
        );
    end component;

    signal s_S      : std_logic_vector(5-1 downto 0);
    signal s_O      : std_logic_vector(32-1 downto 0);

begin
    p_decoder: decoder5to32 port map(
        i_S     => s_S,
        o_Q     => s_O
    );

    P_TEST: process
    begin
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
        s_S <= "00110";
        wait for gCLK_HPER;
        s_S <= "00111";
        wait for gCLK_HPER;
        s_S <= "11111";
        wait for gCLK_HPER;

        wait;
    end process;
end tb;