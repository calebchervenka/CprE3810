-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- decoder5to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 5:32 decoder.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder5to32 is
    port(
        i_S     : in std_logic_vector(5-1 downto 0);
        o_Q     : out std_logic_vector(32-1 downto 0)
    );
end decoder5to32;

architecture df of decoder5to32 is
begin
    p_decode: process(i_S)
    begin
        o_Q <= (others => '0');
        o_Q(to_integer(unsigned(i_S))) <= '1';
    end process;
end df;