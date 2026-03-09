library IEEE;
use IEEE.std_logic_1164.all;

package bus_32 is
    type t_bus_32x32 is array (0 to 31) of std_logic_vector(31 downto 0);
end package bus_32;