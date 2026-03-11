-------------------------------------------------------------------------
-- David Amezcua Santiago
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ALUcontrol.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: 4-bit code to select specific ALU operations such as (add, sub, etc)

-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ALUcontrol is

    port(
        instruction: in std_logic_vector(31 downto 0); -- 32 bit instruction input
        aluCtrl : out std_logic_vector(3 downto 0) -- 4 bit ALU control output
    );
end ALUcontrol;

architecture dataflow of ALUcontrol is

    signal function3 : std_logic_vector(2 downto 0); -- 3 bit function3
    signal function7: std_logic_vector(6 downto 0); -- 7 bit function7

    begin

        function3 <= instruction(14 downto 12);
        function7 <= instruction(31 downto 25);
        aluCtrl <=
        -- ARITHMETIC
        "0000" when function3 = "000" and function7 = "0000000" else -- ADD
        "0001" when function3 = "000" and function7 = "0100000" else -- SUB
        "0000" when function3 = "000" and function7 = "0001000" else

        "0000"; -- default value








        -- "0000" when function3 = "010" and function7 = "0000000" else
        -- --"0010" when function3 = "" and function7 = "" else -- BGE???
        -- --"0011" when function3 = "" and function7 = "" else -- BLT???
        -- -- SHIFT
        -- "0100" when function3 = "001" and function7 = "0000000" else -- SLL
        -- "0101" when function3 = "101" and function7 = "0000000" else -- SRL
        -- --"0110" when function3 = "" and function7 = "" else -- SLA
        -- "0111" when function3 = "101" and function7 = "0100000" else -- SRA
        -- -- COMPARE
        -- "1000" when function3 = "000" else -- BEQ
        -- "1001" when function3 = "001" else -- BNE
        -- "1010" when function3 = "100" else -- BLT
        -- "1011" when function3 = "101" else -- BGE
        -- -- BITWISE
        -- "1100" when function3 = "111" and function7 = "0000000" else -- AND
        -- "1101" when function3 = "110" and function7 = "0000000" else -- OR
        -- "1110" when function3 = "100" and function7 = "0000000" else -- XOR
        -- --"1111" when function3 = "" and function7 = "" else -- NOR

        -- "0000"; -- default value?
end dataflow;
