-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- bus_32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a definition of a 32-bit bus type.

-- 02/18/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package bus_32 is
    type t_bus_32x32 is array (0 to 31) of std_logic_vector(31 downto 0);
end package bus_32;