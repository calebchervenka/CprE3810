-------------------------------------------------------------------------
-- Caleb Chervenka
-- Created 1/28/2025
-------------------------------------------------------------------------

-- mux2t1.vhd
-------------------------------------------------------------------------
-- Implementation of a 2:1 MUX
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
    port(
        i_S     :   in std_logic;
        i_D0    :   in std_logic;
        i_D1    :   in std_logic;
        o_O     :   out std_logic);
end mux2t1;

architecture structural of mux2t1 is
    component andg2
        port(
            i_A     :   in std_logic;
            i_B     :   in std_logic;
            o_F     :   out std_logic);
    end component;

    component org2
        port(
            i_A     :   in std_logic;
            i_B     :   in std_logic;
            o_F     :   out std_logic);
    end component;

    component invg
        port(
            i_A     :   in std_logic;
            o_F     :   out std_logic);
    end component;   


    -- Signal to store result of first and gate
    signal s_a0 :   std_logic;

    -- Signal to store result of not gate
    signal s_n  :   std_logic;

    -- Signal to store result of second and gate
    signal s_a1 :   std_logic;

begin
    g_and1 : andg2 port map(
        i_A     =>  i_S,
        i_B     =>  i_D1,
        o_F     =>  s_a0);
    
    g_not : invg port map(
        i_A     =>  i_S,
        o_F     =>  s_n);
    
    g_and2 : andg2 port map(
        i_A     =>  s_n,
        i_B     =>  i_D0,
        o_F     =>  s_a1);
    
    g_or2 : org2 port map(
        i_A     =>  s_a0,
        i_B     =>  s_a1,
        o_F     =>  o_O);

end structural;