-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_df.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2:1 MUX with a dataflow architecture.

-- 01/28/2026 by CC::Design created.
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