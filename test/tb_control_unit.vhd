library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity tb_control_unit is
end tb_control_unit;

architecture tb of tb_control_unit is
    component control_unit is
        generic(
            DATA_WIDTH : integer := 32
        );
        port(
            i_Inst      : in std_logic_vector(DATA_WIDTH-1 downto 0);
            o_Branch    : out std_logic;
            o_ALUSrc    : out std_logic;
            o_MemToReg  : out std_logic;
            o_MemWrite  : out std_logic;
            o_RegWrite  : out std_logic;
            o_Halt      : out std_logic
        );
    end component;

    signal s_Inst     : std_logic_vector(32-1 downto 0);
    signal s_Branch   : std_logic;
    signal s_ALUSrc   : std_logic;
    signal s_MemToReg : std_logic;
    signal s_MemWrite : std_logic;
    signal s_RegWrite : std_logic;
    signal s_Halt     : std_logic;

begin
    p_control_unit: control_unit port map(
        i_Inst      => s_Inst,
        o_Branch    => s_Branch,
        o_ALUSrc    => s_ALUSrc,
        o_MemToReg  => s_MemToReg,
        o_MemWrite  => s_MemWrite,
        o_RegWrite  => s_RegWrite,
        o_Halt      => s_Halt
    );

    P_TEST: process
    begin
        -- Test: ADDI, ANDI, ORI, XORI, ADD, AND, OR, XOR, SW, LW, LUI

        -- ADDI
        s_Inst <= x"00000013";
        wait for 10 ns;

        -- ANDI
        s_Inst <= x"00007013";
        wait for 10 ns;

        -- ORI
        s_Inst <= x"00006013";
        wait for 10 ns;

        -- XORI
        s_Inst <= x"00004013";
        wait for 10 ns;

        -- ADD
        s_Inst <= x"00000033";
        wait for 10 ns;

        -- AND
        s_Inst <= x"00007033";
        wait for 10 ns;

        -- OR
        s_Inst <= x"00006033";
        wait for 10 ns;

        -- XOR
        s_Inst <= x"00004033";
        wait for 10 ns;

        -- SW
        s_Inst <= x"00002023";
        wait for 10 ns;

        -- LW
        s_Inst <= x"00002003";
        wait for 10 ns;

        -- LUI
        s_Inst <= x"00003037";
        wait for 10 ns;

    end process;
end tb;