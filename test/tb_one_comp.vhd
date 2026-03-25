-------------------------------------------------------------------------
-- Caleb Chervenka
-- Created 1/28/2025
-------------------------------------------------------------------------
--
-- mux2to1.vhd
-------------------------------------------------------------------------
-- Testbench implementation of a 2:1 MUX
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_one_comp is
end tb_one_comp;

architecture mixed of tb_one_comp is
    constant N : integer := 32;
    
    component one_comp
        generic(N : integer := 16);
        port(
            i_D : in std_logic_vector(N-1 downto 0);
            o_O : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal i_D : std_logic_vector(N-1 downto 0);
    signal o_O : std_logic_vector(N-1 downto 0);

begin
    COMP: one_comp generic map(N => N) port map(
        i_D => i_D,
        o_O => o_O
    );

    p_tb: process
    begin
        -- All 0s
        i_D <= x"00000000";
        wait for 10 ps;
        -- All 1s
        i_D <= x"FFFFFFFF";
        wait for 10 ps;
        -- Alternating 1010
        i_D <= x"AAAAAAAA";
        wait for 10 ps;
        -- Alternating 0101...
        i_D <= x"55555555";
        wait for 10 ps;
        -- Counting
        i_D <= x"12345678";
        wait for 10 ps;
        -- End simulation
        wait;
    end process;
end mixed;
