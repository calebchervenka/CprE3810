library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux32to1 is
    port(
        i_D     : in std_logic_vector(32-1 downto 0);
        i_S     : in std_logic_vector(5-1 downto 0);
        o_Q     : out std_logic
    );
end mux32to1;

architecture df of mux32to1 is
begin
    p_mux: process(i_S)
    begin
        o_Q <= i_D(to_integer(unsigned(i_S)));
    end process;
end df;