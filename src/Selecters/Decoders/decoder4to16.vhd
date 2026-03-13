library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder4to16 is
    port(
        i_S     : in std_logic_vector(3 downto 0);
        o_Q     : out std_logic_vector(32-1 downto 0)
    );
end decoder4to16;

architecture df of decoder4to16 is
begin
    p_decode: process(i_S)
    begin
        o_Q <= (others => '0');
        o_Q(to_integer(unsigned(i_S))) <= '1';
    end process;
end df;