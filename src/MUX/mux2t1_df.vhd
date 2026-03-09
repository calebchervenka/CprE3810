-------------------------------------------------------------------------
-- Caleb Chervenka
-- Created 1/28/2025
-------------------------------------------------------------------------

-- mux2t1.vhd
-------------------------------------------------------------------------
-- Implementation of a 2:1 MUX with dataflow
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1_df is
    port(
        i_S     :   in std_logic;
        i_D0    :   in std_logic;
        i_D1    :   in std_logic;
        o_O     :   out std_logic);
end mux2t1_df;

architecture dataflow of mux2t1_df is
begin
    o_O <= i_D1 when (i_S = '1') else i_D0;
end dataflow;