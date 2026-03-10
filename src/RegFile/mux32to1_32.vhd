-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- mux32t1_32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 32:1 32-bit MUX with a dataflow architecture.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.bus_32.all;

entity mux32to1_32 is
    port(
        i_D    : in t_bus_32x32;
        i_s     : in std_logic_vector(5-1 downto 0);
        o_q     : out std_logic_vector(32-1 downto 0)
    );
end mux32to1_32;

architecture df of mux32to1_32 is
begin
    o_q <= i_D(to_integer(unsigned(i_s)));
end df;