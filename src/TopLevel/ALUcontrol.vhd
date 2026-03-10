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

            case function3 is
                when "000" => -- add or sub
                    if function7 = "0000000" then
                        aluCtrl <= "0000"; -- add
                    else
                        aluCtrl <= "0001"; -- sub

                when "001" => -- sll
                        aluCtrl <= "0100";

                when "010" => -- slt
                        aluCtrl <= "1011";

                when "011" => -- sltu

                when "100" >= -- xor
                        aluCtrl <= "1110"

                when "101" >= -- srl or sra
                    if function7 = "0000000" then
                        aluCtrl <= "0101"; -- srl
                    else
                        aluCtrl <= "0111" -- sra
                
                when "110" >= -- or
                        aluCtrl <= "1101"

                when "111" >= -- and
                        aluCtrl <= "1100"
                
