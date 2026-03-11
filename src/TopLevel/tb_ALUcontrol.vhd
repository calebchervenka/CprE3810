-------------------------------------------------------------------------
-- David Amezcua Santiago
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_ALUcontrol.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file implements a ALU control logic system

-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_ALUcontrol is
end tb_ALUcontrol;

architecture structural of tb_ALUcontrol is

    component ALUcontrol is
        port (
            instruction : in std_logic_vector(31 downto 0);
            aluCtrl : out std_logic_vector(3 downto 0)
        );
    end component;

signal tb_instruction : std_logic_vector(31 downto 0);
signal tb_aluCtrl : std_logic_vector(3 downto 0);

begin

    DUT: ALUcontrol
        port map (
            instruction => tb_instruction,
            aluCtrl => tb_aluCtrl
        );

stim_process : process
begin

        -- Test ADD (R-type)
        -- opcode=0110011 funct3=000 funct7=0000000
        tb_instruction <= x"00000033"; -- R-type ADD encoding
        wait for 20 ns;

        -- Test SUB (R-type)
        -- opcode=0110011 funct3=000 funct7=0100000
        tb_instruction <= x"40000033"; -- R-type SUB encoding
        wait for 20 ns;

        -- Test SLL (R-type)
        -- opcode=0110011 funct3=001 funct7=0000000
        tb_instruction <= x"00001033"; 
        wait for 20 ns;

        -- Test SRL (R-type)
        -- opcode=0110011 funct3=101 funct7=0000000
        tb_instruction <= x"00005033"; 
        wait for 20 ns;

        -- Test SRA (R-type)
        -- opcode=0110011 funct3=101 funct7=0100000
        tb_instruction <= x"40005033"; 
        wait for 20 ns;

        -- Test AND (R-type)
        -- opcode=0110011 funct3=111 funct7=0000000
        tb_instruction <= x"00007033"; 
        wait for 20 ns;

        -- Test OR (R-type)
        -- opcode=0110011 funct3=110 funct7=0000000
        tb_instruction <= x"00006033"; 
        wait for 20 ns;

        -- Test XOR (R-type)
        -- opcode=0110011 funct3=100 funct7=0000000
        tb_instruction <= x"00004033"; 
        wait for 20 ns;

        wait;

    end process;
    end structural;