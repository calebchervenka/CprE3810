-------------------------------------------------------------------------
-- Caleb Chervenka
-- Created 1/28/2025
-------------------------------------------------------------------------

-- mux2t1.vhd
-------------------------------------------------------------------------
-- Implementation of a one's complementor
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity one_comp is
    generic(N : integer := 16);
    port(
        i_D     :   in std_logic_vector(N-1 downto 0);
        o_O     :   out std_logic_vector(N-1 downto 0));
end one_comp;

architecture structural of one_comp is
    
    component invg is
        port(
            i_A     : in std_logic;
            o_F     : out std_logic);
    end component;

begin

    G_NBit_OC: for i in 0 to N-1 generate
        inv_inst : invg port map(
            i_A     =>  i_D(i),
            o_F     =>  o_O(i));
    end generate G_NBit_OC;

end structural;