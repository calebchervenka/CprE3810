-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_ALU.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the ALU unit.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ALU is
end tb_ALU;

architecture behavior of tb_ALU is

  component ALU
    port(
      i_A   : in std_logic_vector(31 downto 0);
      i_B   : in std_logic_vector(31 downto 0);
      i_Op  : in std_logic_vector(3 downto 0);
      o_Out : out std_logic_vector(31 downto 0)
    );
  end component;

  signal s_A   : std_logic_vector(31 downto 0) := (others => '0');
  signal s_B   : std_logic_vector(31 downto 0) := (others => '0');
  signal s_Op  : std_logic_vector(3 downto 0) := (others => '0');
  signal s_Out : std_logic_vector(31 downto 0);

  begin
    DUT: ALU
        port map(
        i_A   => s_A,
        i_B   => s_B,
        i_Op  => s_Op,
        o_Out => s_Out
        );
    
    stim_proc: process
    begin
        -- Test case 1: ADD
        s_A <= x"00000001";
        s_B <= x"00000001";
        s_Op <= "0000"; -- Assuming "0000" corresponds to ADD
        wait for 10 ns;
        -- Check s_Out for expected result (0x00000002)

        -- Test case 2: SUB
        s_A <= x"00000002";
        s_B <= x"00000001";
        s_Op <= "0001"; -- Assuming "0001" corresponds to SUB
        wait for 10 ns;
        -- Check s_Out for expected result (0x00000001)

        -- TODO: Add more test cases for other ALU operations (AND, OR, XOR, etc.)
        wait;
    end process;
end behavior;