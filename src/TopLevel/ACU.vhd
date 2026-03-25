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
        x"0" when s_func3 = "000" and s_func7 = "0000000" else  -- ADD
        x"0" when opcode = "0010011" and s_func3 = "000" else   -- ADDI
        x"0" when opcode = "0000011" and s_func3 = "010" else   -- LW
        x"0" when opcode = "0100011" and s_func3 = "010" else   -- SW
        x"1" when s_func3 = "000" and s_func7 = "0100000" else  -- SUB
        x"2" when opcode =  "0010011" and s_func3 = "001" else  -- SLLI

        "0000";
end df;