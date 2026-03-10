-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_ripple_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for a ripple carry adder using structural VHDL.

-- 03/08/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ripple_adder is
end tb_ripple_adder;

architecture behavior of tb_ripple_adder is
    constant N : integer := 32;
    signal i_A   : std_logic_vector(N-1 downto 0);
    signal i_B   : std_logic_vector(N-1 downto 0);
    signal i_Cin : std_logic;
    signal o_Sum : std_logic_vector(N-1 downto 0);
    signal o_Cout: std_logic;

    component ripple_adder
        generic(N : integer := 32);
        port(
            i_A   : in std_logic_vector(N-1 downto 0);
            i_B   : in std_logic_vector(N-1 downto 0);
            i_Cin : in std_logic;
            o_Sum : out std_logic_vector(N-1 downto 0);
            o_Cout: out std_logic
        );
    end component;

begin
    uut: ripple_adder generic map(N => N) port map(
        i_A => i_A,
        i_B => i_B,
        i_Cin => i_Cin,
        o_Sum => o_Sum,
        o_Cout => o_Cout
    );

    stim_proc: process
    begin
        -- Test case 1: 0 + 0 + 0
        i_A <= (others => '0');
        i_B <= (others => '0');
        i_Cin <= '0';
        wait for 10 ps;

        -- Test case 2: all 1s + all 1s + 1
        i_A <= (others => '1');
        i_B <= (others => '1');
        i_Cin <= '1';
        wait for 10 ps;
        
        -- Test case 3: 0x12345678 + 0x9ABCDEF0 + 0
        i_A <= x"12345678";
        i_B <= x"9ABCDEF0";
        i_Cin <= '0';
        wait for 10 ps;

        wait;
    end process;
end behavior;
