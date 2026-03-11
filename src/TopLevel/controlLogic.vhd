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
        imem : in std_logic_vector(31 downto 0); -- input for Imem
        --aluCtrl : out std_logic_vector(2 downto 0); -- output for ALUCtrl | IMPLEMENTED AS A SEPARATE COMPONENT
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

    opcode <= imem(6 downto 0); -- extracts the specific opcode from the instruction memory

    -- aluCtrl not accounted for here, refer to ALUcontrol

    with opcode select
        branch <=
        '1' when "0010111", -- auipc | U type
        '1' when "1100011", -- SB
        '1' when "1100111", -- jalr | I type
        '1' when "1101111", -- jal | J type
        '0' when others;
    
    with opcode select
        aluSrc <=
        '1' when "0000011", -- load
        '1' when "0010011", -- I type
        '1' when "0100011", -- store
        '1' when "0110111", -- load upper imm
        '0' when others;
    
    with opcode select
        memToReg <=
        '1' when "0000011", -- load
        '0' when others;
    
    with opcode select
        memWrite <=
        '1' when "0100011", -- store
        '0' when others;
    
    with opcode select
        regwrite <=
        '1' when "0000011", -- load
        '1' when "0010011", -- I type
        '1' when "0110011", -- R type
        '1' when "0110111", -- load upper imm
        '1' when "1100111", -- jalr | I type
        '1' when "1101111", -- jal | J type
        '0' when others;
    
    end dataflow;
