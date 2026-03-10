-------------------------------------------------------------------------
-- David Amezcua Santiago
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- controlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file implements a control logic system for the RISC-V processor.
-- The control logic ill essentially work to input a Imem input, and output a 7 bit output based
-- on the instruction

-- Instruction types for clarity
-- R-type:  0110011
-- I-type:  0010011
-- S-type:  0100011
-- SB-type: 1100011
-- U-type:  0010111
-- J-type:  1101111

-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity controlLogic is
    port (
        iMem : in std_logic_vector(31 downto 0); -- input for Imem
        aluCtrl : out std_logic_vector(2 downto 0); -- output for ALUCtrl
        branch : out std_logic; -- output for Branch
        aluSrc : out std_logic; -- output for ALUSrc
        memToReg : out std_logic; -- output for MemToReg
        memWrite : out std_logic; -- output for MemWrite
        regWrite : out std_logic -- output for RegWrite
    );
end controlLogic;

architecture dataflow of controlLogic is
    signal opcode : std_logic_vector(6 downto 0);
begin

    opcode <= iMem(6 downto 0);

    -- add function3 and function7 here?

    -- combinational control logic based on opcode
    process(opcode)
    begin
        
        case opcode is
            when "0110011" => -- R-type
                branch <= '0';
                aluSrc <= '0';
                memToReg <= '0';
                memWrite <= '0';
                regWrite <= '1';

            when "0010011" => -- I-type
                branch <= '0';
                aluSrc <= '1';
                memToReg <= '0';
                memWrite <= '0';
                regWrite <= '1';

            when "0100011" => -- S-type
                branch <= '0';
                aluSrc <= '1';
                memToReg <= '0';
                memWrite <= '1';
                regWrite <= '0';

            when "1100011" => -- SB-type (branch)
                branch <= '1';
                aluSrc <= '0';
                memToReg <= '0';
                memWrite <= '0';
                regWrite <= '0';

            when "0010111" => -- U-type
                branch <= '0';
                aluSrc <= '1';
                memToReg <= '0';
                memWrite <= '0';
                regWrite <= '1';

            when "1101111" => -- J-type
                branch <= '1';
                aluSrc <= '0';
                memToReg <= '0';
                memWrite <= '0';
                regWrite <= '1';

        end case;
    end process;
end dataflow;









