library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.RISCV_types.all;

entity tb_barrel_shifter_left is
end tb_barrel_shifter_left;

architecture tb of tb_barrel_shifter_left is
    component barrel_shifter_left is
        Port (i_D       : in  std_logic_vector(31 downto 0);
              i_shift   : in  std_logic_vector(4 downto 0);
              o_Q       : out std_logic_vector(31 downto 0));
    end component;

    signal s_D       : std_logic_vector(31 downto 0);
    signal s_shift   : std_logic_vector(4 downto 0);
    signal s_Q       : std_logic_vector(31 downto 0);
begin
    p_barrel_shifter_left: barrel_shifter_left port map(
        i_D => s_D,
        i_shift => s_shift,
        o_Q => s_Q
    );

    P_TEST: process
    begin
        s_D <= x"00000001";
        s_shift <= "00000";  -- Shift by 0
        wait for 10 ns;

        s_shift <= "00001";  -- Shift by 1
        wait for 10 ns;
        s_shift <= "00010";  -- Shift by 2
        wait for 10 ns;
        s_shift <= "00011";  -- Shift by 3
        wait for 10 ns;
        s_shift <= "00100";  -- Shift by 4
        wait for 10 ns;
        s_shift <= "00101";  -- Shift by 5
        wait for 10 ns;
        s_shift <= "00110";  -- Shift by 6
        wait for 10 ns;
        s_shift <= "00111";  -- Shift by 7
        wait for 10 ns;
        s_shift <= "01000";  -- Shift by 8
        wait for 10 ns;
        s_shift <= "01001";  -- Shift by 9
        wait for 10 ns;
        s_shift <= "01010";  -- Shift by 10
        wait for 10 ns;
        s_shift <= "01011";  -- Shift by 11
        wait for 10 ns;
        s_shift <= "01100";  -- Shift by 12
        wait for 10 ns;
        s_shift <= "01101";  -- Shift by 13
        wait for 10 ns;
        s_shift <= "01110";  -- Shift by 14
        wait for 10 ns;
        s_shift <= "01111";  -- Shift by 15
        wait for 10 ns;
        s_shift <= "10000";  -- Shift by 16
        wait for 10 ns;
    end process;
end tb;