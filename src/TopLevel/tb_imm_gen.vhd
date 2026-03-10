-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_imm_gen.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for imm_gen.vhd.

-- 03/10/2026 by CC::Design created.
-------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_imm_gen is
end tb_imm_gen;

architecture behavioral of tb_imm_gen is
    -- Component declaration
    component imm_gen is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals
    signal instr : std_logic_vector(31 downto 0);
    signal imm_out : std_logic_vector(31 downto 0);

begin
    -- Instantiate the unit under test
    uut : imm_gen port map (
        instr => instr,
        imm_out => imm_out
    );

    -- Test process
    process
    begin
        -- Test 1: I-type instruction (ADDI)
        -- Expected: 12-bit immediate sign-extended to 32 bits
        instr <= x"01410293"; -- ADDI x5, x2, 20
        wait for 10 ns;
        -- Expected imm_out: 0x00000014 (20)

        -- Test 2: S-type instruction (SW)
        -- Expected: 12-bit immediate (split fields) sign-extended
        instr <= x"00A12023"; -- SW x10, 0(x2)
        wait for 10 ns;
        -- Expected imm_out: 0x00000000 (0)

        -- Test 3: SB-type instruction (BEQ)
        -- Expected: 12-bit immediate (split fields) sign-extended, left-shifted by 1
        instr <= x"00208063"; -- BEQ x1, x2, 0
        wait for 10 ns;
        -- Expected imm_out: 0x00000000 (0)

        -- Test 4: U-type instruction (LUI)
        -- Expected: 20-bit immediate left-shifted by 12 bits
        instr <= x"12345037"; -- LUI x0, 0x12345
        wait for 10 ns;
        -- Expected imm_out: 0x12345000

        -- Test 5: UJ-type instruction (JAL)
        -- Expected: 20-bit immediate (split fields) sign-extended, left-shifted by 1
        instr <= x"008000EF"; -- JAL x1, 8
        wait for 10 ns;
        -- Expected imm_out: 0x00000008

        wait;
    end process;

end behavioral;