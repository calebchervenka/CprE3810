library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.RISCV_types.all;

entity control_unit is
    generic(
        DATA_WIDTH : integer
    );
    port(
        i_Inst      : in std_logic_vector(DATA_WIDTH-1 downto 0);
        o_Branch    : out std_logic;
        o_ALUSrc    : out std_logic_vector(1 downto 0);
        o_MemToReg  : out std_logic;
        o_MemWrite  : out std_logic;
        o_RegWrite  : out std_logic;
        o_Halt      : out std_logic
    );
end control_unit;

architecture df of control_unit is
    signal s_opcode : std_logic_vector(7-1 downto 0);
    signal s_func3  : std_logic_vector(3-1 downto 0);
    signal s_func7  : std_logic_vector(7-1 downto 0);

    begin
        s_opcode  <= i_inst(6 downto 0);
        s_func3   <= i_inst(14 downto 12);
        s_func7   <= i_inst(31 downto 25);

        with s_opcode select
            o_Branch <=
            '1' when "1101111", -- JAL
            '0' when others;
        
        with s_opcode select
            o_ALUSrc <=
            "01" when "0010011", -- ADDI, ANDI, ORI, XORI
            "01" when "0100011", -- SW
            "01" when "0000011", -- LW, LB, LH, LBU, LHU
            "01" when "0110111", -- LUI
            "10" when "1101111", -- JAL
            "00" when others;

        with s_opcode select
            o_MemToReg <=
            '1' when "0000011", -- LW, LB, LH, LBU, LHU
            '0' when others;

        with s_opcode select
            o_MemWrite <=
            '1' when "0100011", -- SW
            '0' when others;

        with s_opcode select
            o_RegWrite <=
            '1' when "0010011", -- ADDI, ANDI, ORI, XORI
            '1' when "0110011", -- ADD, AND, OR, XOR
            '1' when "0000011", -- LW, LB, LH, LBU, LHU
            '1' when "0110111", -- LUI
            '1' when "1101111", -- JAL
            '0' when others;
        
        with s_opcode select
            o_Halt <=
            '1' when "1110011",
            '0' when others;

end df;