-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- imm_gen.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of an immediate value generator.
--  The immediate value generator takes a 32-bit instruction as input and produces a 32-bit immediate value as output. 
--  The immediate value is generated based on the instruction type, which is determined by the opcode (bits [6:0] of the instruction).
--  The immediate value is then sign-extended to 32 bits.

-- 03/07/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity imm_gen is
    port(
        i_instr : in std_logic_vector(31 downto 0);
        o_imm   : out std_logic_vector(31 downto 0)
    );
end imm_gen;

architecture Structural of imm_gen is

    component Mux8t1_N is
        generic(N : integer := 32);
        port(
            i_S   : in std_logic_vector(3-1 downto 0);
            i_D0  : in std_logic_vector(N-1 downto 0);
            i_D1  : in std_logic_vector(N-1 downto 0);
            i_D2  : in std_logic_vector(N-1 downto 0);
            i_D3  : in std_logic_vector(N-1 downto 0);
            i_D4  : in std_logic_vector(N-1 downto 0);
            i_D5  : in std_logic_vector(N-1 downto 0);
            i_D6  : in std_logic_vector(N-1 downto 0);
            i_D7  : in std_logic_vector(N-1 downto 0);
            o_O   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component Mux4t1_N is
        generic(N : integer := 32);
        port(
            i_S   : in std_logic_vector(2-1 downto 0);
            i_D0  : in std_logic_vector(N-1 downto 0);
            i_D1  : in std_logic_vector(N-1 downto 0);
            i_D2  : in std_logic_vector(N-1 downto 0);
            i_D3  : in std_logic_vector(N-1 downto 0);
            o_O   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal s_imm_i : std_logic_vector(31 downto 0);
    signal s_imm_s : std_logic_vector(31 downto 0);
    signal s_imm_sb : std_logic_vector(31 downto 0);
    signal s_imm_u : std_logic_vector(31 downto 0);
    signal s_imm_uj : std_logic_vector(31 downto 0);

    signal s_mux_1 : std_logic_vector(31 downto 0);

begin
    -- No Immediate:
    -- R:   0110011 

    -- [31:20]:
    -- I:   0000011, 0001111, 0010011, 1110011, 1100111
    s_imm_i(11 downto 0) <= i_instr(31 downto 20);
    s_imm_i(31 downto 12) <= (others => i_instr(31)); -- sign-extend the immediate value

    -- [31:25|11:7]:
    -- S:   0100011
    s_imm_s(4 downto 0) <= i_instr(11 downto 7);
    s_imm_s(11 downto 5) <= i_instr(31 downto 25);
    s_imm_s(31 downto 12) <= (others => i_instr(31)); -- sign-extend the immediate value

    -- [31|7|30:25|11:8]:
    -- SB:  1100011
    s_imm_sb(0) <= '0'; -- imm[0] is always 0 for branch instructions
    s_imm_sb(4 downto 1) <= i_instr(11 downto 8);
    s_imm_sb(10 downto 5) <= i_instr(30 downto 25);
    s_imm_sb(11) <= i_instr(7);
    s_imm_sb(31 downto 12) <= (others => i_instr(31)); -- sign-extend the immediate value

    -- [31:12]:
    -- U:   0010111, 0110111
    s_imm_u(31 downto 12) <= i_instr(31 downto 12);
    s_imm_u(11 downto 0) <= (others => '0'); -- the lower 12 bits of the immediate value are always 0 for U-type instructions

    -- [31|19:12|20|30:21]:
    -- UJ:  1101111
    s_imm_uj(0) <= '0'; -- imm[0] is always 0 for jump instructions
    s_imm_uj(10 downto 1) <= i_instr(30 downto 21);
    s_imm_uj(11) <= i_instr(20);
    s_imm_uj(19 downto 12) <= i_instr(19 downto 12);
    s_imm_uj(31 downto 20) <= (others => i_instr(31)); -- sign-extend the immediate value

    mux_imm_1 : Mux4t1_N generic map(32) port map(
        i_S => i_instr(6 downto 5),
        i_D0 => s_imm_sb,
        i_D1 => s_imm_i,
        i_D2 => s_imm_uj,
        i_D3 => s_imm_uj,
        o_O =>  s_mux_1
    );

    mux_imm_type : Mux8t1_N generic map(32) port map(
        i_S => i_instr(6 downto 4),
        i_D0 => s_imm_i,
        i_D1 => s_imm_i,
        i_D2 => s_imm_s,
        i_D3 => s_imm_u,
        i_D4 => (others => '0'),
        i_D5 => (others => '0'),
        i_D6 => s_mux_1,
        i_D7 => s_imm_i,
        o_O => o_imm
    );
end Structural;