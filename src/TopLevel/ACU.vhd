library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.RISCV_types.all;

entity ACU is
    generic(
        DATA_WIDTH : integer
    );
    port(
        i_Inst      : in std_logic_vector(DATA_WIDTH-1 downto 0);
        o_ALUCtrl   : out std_logic_vector(ALU_CTRL_WIDTH-1 downto 0)
    );
end ACU;

architecture df of ACU is
    signal s_func3  : std_logic_vector(3-1 downto 0);
    signal s_func7  : std_logic_vector(7-1 downto 0);
    signal opcode   : std_logic_vector(7-1 downto 0);

    begin
        opcode  <= i_inst(6 downto 0);
        s_func3 <= i_inst(14 downto 12);
        s_func7 <= i_inst(31 downto 25);
 
        o_ALUCtrl <=
        x"0" when opcode = "0110011" and s_func3 = "000" and s_func7 = "0000000" else  -- ADD
        x"0" when opcode = "0010011" and s_func3 = "000" else   -- ADDI
        x"0" when opcode = "0000011" and s_func3 = "010" else   -- LW
        x"0" when opcode = "0000011" and s_func3 = "000" else   -- LB
        x"0" when opcode = "0000011" and s_func3 = "001" else   -- LH
        x"0" when opcode = "0000011" and s_func3 = "100" else   -- LBU
        x"0" when opcode = "0000011" and s_func3 = "101" else   -- LHU
        x"0" when opcode = "0100011" and s_func3 = "010" else   -- SW
        x"0" when opcode = "1101111" else                       -- JAL
        x"0" when opcode = "0010111" else                       -- AUIPC
        x"1" when opcode = "0110011" and s_func3 = "000" and s_func7(5) = '1' else  -- SUB
        x"2" when opcode = "0110011" and s_func3 = "001" else   -- SLL
        x"2" when opcode = "0010011" and s_func3 = "001" else   -- SLLI
        x"3" when opcode = "0010011" and s_func3 = "111" else   -- ANDI
        x"3" when opcode = "0110011" and s_func3 = "111" else   -- AND
        x"4" when opcode = "0010011" and s_func3 = "110" else   -- ORI
        x"4" when opcode = "0110011" and s_func3 = "110" else   -- OR
        x"5" when opcode = "0010011" and s_func3 = "100" else   -- XORI
        x"5" when opcode = "0110011" and s_func3 = "100" else   -- XOR
        x"6" when opcode = "0110111" else                       -- LUI
        x"7" when opcode = "0110011" and s_func3 = "010" and s_func7 = "0000000" else -- SLT
        x"7" when opcode = "0010011" and s_func3 = "010" else   -- SLTI
        x"8" when opcode = "0010011" and s_func3 = "011" else   -- SLTIU
        x"A" when opcode = "0110011" and s_func3 = "101" and s_func7(5) = '1' else   -- SRA
        x"A" when opcode = "0010011" and s_func3 = "101" and s_func7(5) = '1' else   -- SRAI
        
        -- MUST BE CHECKED AFTER SRA/SRAI BECAUSE OF FUNC7 VALUE
        x"9" when opcode = "0110011" and s_func3 = "101" else   -- SRL
        x"9" when opcode = "0010011" and s_func3 = "101" else   -- SRLI

        x"B" when opcode = "1100011" and s_func3 = "000" else   -- BEQ

        "0000";
end df;