-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- full_adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 1-bit full adder using structural VHDL.

-- 03/08/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    port(
        i_A   : in std_logic;
        i_B   : in std_logic;
        i_Cin : in std_logic;
        o_Sum : out std_logic;
        o_Cout: out std_logic
    );
end full_adder;

architecture structural of full_adder is
    component andg2 is
        port(
            i_A, i_B : in std_logic; 
            o_F : out std_logic
        );
    end component;

    component org2 is
        port(
            i_A, i_B : in std_logic; 
            o_F : out std_logic
        );
    end component;

    component xorg2 is
        port(
            i_A, i_B : in std_logic; 
            o_F : out std_logic
        );
    end component;

    signal s_1, s_2, s_3, s_4, s_5, s_6 : std_logic;

begin
    -- Sum
    xor1:   xorg2 port map(i_A => i_A, i_B => i_B, o_F => s_1);
    xor2:   xorg2 port map(i_A => s_1, i_B => i_Cin, o_F => o_Sum);

    -- Carry out
    and3:   andg2 port map(i_A => i_A, i_B => i_B, o_F => s_3);
    or4:    org2 port map(i_A => i_A, i_B => i_B, o_F => s_4);
    and5:   andg2 port map(i_A => s_4, i_B => i_Cin, o_F => s_5);
    or6:    org2 port map(i_A => s_3, i_B => s_5, o_F => o_Cout);

end structural;