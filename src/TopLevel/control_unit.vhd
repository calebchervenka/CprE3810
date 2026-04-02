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
        o_Branch    : out std_logic_vector(1 downto 0);
        o_Branch_Cond   : out std_logic;
        o_ALUSrcA   : out std_logic_vector(1 downto 0);
        o_ALUSrcB   : out std_logic_vector(1 downto 0);
        o_MemToReg  : out std_logic;
        o_MemWrite  : out std_logic;
        o_RegWrite  : out std_logic;
        o_Jalr      : out std_logic;
        o_Halt      : out std_logic
    );
end control_unit;

architecture df of control_unit is
    signal s_opcode : std_logic_vector(7-1 downto 0);
    signal s_func3  : std_logic_vector(3-1 downto 0);
    signal s_func7  : std_logic_vector(7-1 downto 0);

    begin
        s_opcode  <= i_inst(6 downto 0);

        o_Branch(0) <= s_opcode(6) and s_opcode(2);
        o_Branch(1) <= (s_opcode(6) and s_opcode(2) and not s_opcode(3)) or (s_opcode(6) and not s_opcode(2));
        o_ALUSrcA <= '0' & s_opcode(2) and (s_opcode(5) xor s_opcode(4));
        o_ALUSrcB(0) <= not s_opcode(6) and (s_opcode(2) or (s_opcode(5) nand s_opcode(4)));
        o_ALUSrcB(1) <= s_opcode(6) and s_opcode(2);
        o_MemToReg <= s_opcode(4) nor s_opcode(5);
        o_MemWrite <= not (s_opcode(6) or s_opcode(4)) and s_opcode(5);
        o_RegWrite <= 
            not (s_opcode(6) or s_opcode(5)) 
            or (not s_opcode(6) and s_opcode(4)) 
            or (s_opcode(6) and s_opcode(3));
        
        o_Halt <= s_opcode(6) and s_opcode(4);

        -- with s_opcode select
        --     o_Branch <=
        --     -- '1' when "1100011", -- BEQ, BNE, BLT, BGE, BLTU, BGEU
        --     '1' when "1100111", -- JALR
        --     '1' when "1101111", -- JAL
        --     '0' when others;

        -- with s_opcode select
        --     o_Jalr <=
        --     '1' when "1100111", -- JALR
        --     '0' when others;

        -- with s_opcode select
        --     o_Branch_Cond <=
        --     '1' when "1100011", -- BEQ, BNE, BLT, BGE, BLTU, BGEU
        --     '0' when others;
        
        -- with s_opcode select
        --     o_ALUSrcA <=
        --     "01" when "0010111", -- AUIPC
        --     "01" when "1100111", -- JALR
        --     "01" when "1101111", -- JAL
        --     "00" when others;

        -- with s_opcode select
        --     o_ALUSrcB <=
        --     "01" when "0000011", -- LW, LB, LH, LBU, LHU
        --     "01" when "0010011", -- ADDI, ANDI, ORI, XORI
        --     "01" when "0010111", -- AUIPC, SLTI, SLTIU
        --     "01" when "0100011", -- SW
        --     "01" when "0110111", -- LUI, SLT
        --     "10" when "1100111", -- JALR
        --     "10" when "1101111", -- JAL
        --     "00" when others;

        -- with s_opcode select
        --     o_MemToReg <=
        --     '1' when "0000011", -- LW, LB, LH, LBU, LHU
        --     '0' when others;

        -- with s_opcode select
        --     o_MemWrite <=
        --     '1' when "0100011", -- SW
        --     '0' when others;

        -- with s_opcode select
        --     o_RegWrite <=
        --     '1' when "0000011", -- LW, LB, LH, LBU, LHU
        --     '1' when "0010011", -- ADDI, ANDI, ORI, XORI
        --     '1' when "0010111", -- AUIPC, SLTI, SLTIU
        --     '1' when "0110011", -- ADD, AND, OR, XOR, SLL, SLLI, SRL, SRLI, SRA, SRAI
        --     '1' when "0110111", -- LUI, SLT
        --     '1' when "1100111", -- JALR
        --     '1' when "1101111", -- JAL
        --     '0' when others;
        -- not (6 or (5 and not 4)) or (6 and 3)

        -- with s_opcode select
        --     o_Halt <=
        --     '1' when "1110011",
        --     '0' when others;
end df;