-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- fetch_logic_tb.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the fetch logic unit.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch_logic_tb is
end fetch_logic_tb;

architecture behavior of fetch_logic_tb is

  component fetch_logic
    port(
      i_imm    : in std_logic_vector(31 downto 0);
      i_Branch : in std_logic;
      i_Clk    : in std_logic;
      i_Rst    : in std_logic;
      o_PC     : out std_logic_vector(31 downto 0)
    );
  end component;

  signal tb_imm    : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_Branch : std_logic := '0';
  signal tb_Clk    : std_logic := '0';
  signal tb_Rst    : std_logic := '0';
  signal tb_PC     : std_logic_vector(31 downto 0);

  constant clk_period : time := 10 ns;

begin

  DUT: fetch_logic
    port map(
      i_imm    => tb_imm,
      i_Branch => tb_Branch,
      i_Clk    => tb_Clk,
      i_Rst    => tb_Rst,
      o_PC     => tb_PC
    );

  clk_process: process
  begin
    tb_Clk <= '0';
    wait for clk_period / 2;
    tb_Clk <= '1';
    wait for clk_period / 2;
  end process;

  stimulus_process: process
  begin
    -- Test 1: Reset functionality
    -- Apply reset signal and check initial state
    -- Expected result: o_PC should output the instruction at the reset PC address (assuming PC starts at 0)
    tb_Rst <= '1';
    wait for clk_period;
    tb_Rst <= '0';
    wait for clk_period;
    -- Check: o_PC should be the value from memory at address 0

    -- Test 2: Normal instruction fetch (no branch)
    -- Set branch to 0, imm to 0, let PC increment by 4 each cycle
    -- Expected result: o_PC should reflect instructions fetched sequentially from memory addresses 0, 4, 8, etc.
    tb_Branch <= '0';
    tb_imm <= (others => '0');
    wait for 4 * clk_period;
    -- Check: o_PC values should correspond to memory contents at PC=0, PC=4, etc.

    -- Test 3: Branch taken
    -- Set branch to 1, imm to a specific offset (e.g., 8)
    -- Expected result: PC should jump to current PC + imm, o_PC should be the instruction at the new address
    tb_Branch <= '1';
    tb_imm <= std_logic_vector(to_unsigned(8, 32));
    wait for clk_period;
    -- Check: o_PC should be the instruction at address = previous PC + 8

    -- Test 4: Branch not taken after branch signal
    -- Set branch back to 0
    -- Expected result: Resume normal increment by 4
    tb_Branch <= '0';
    wait for 2 * clk_period;
    -- Check: o_PC should continue sequential fetch

    -- Test 5: Large immediate value for branch
    -- Set branch to 1, imm to a large positive value
    -- Expected result: PC jumps to current PC + large imm, o_PC fetches from new address
    tb_Branch <= '1';
    tb_imm <= std_logic_vector(to_unsigned(100, 32));
    wait for clk_period;
    -- Check: o_PC should be instruction at PC + 100

    -- Test 6: Negative immediate (branch backwards)
    -- Set imm to negative value (two's complement)
    -- Expected result: PC jumps backwards, o_PC fetches from lower address
    tb_imm <= std_logic_vector(to_signed(-16, 32));
    wait for clk_period;
    -- Check: o_PC should be instruction at PC - 16

    -- End of tests
    wait;
  end process;

end behavior;