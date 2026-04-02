-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- mux4t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 4:1 N-bit MUX with a structural architecture.

-- 03/11/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity mux4t1_N is
  generic(N : integer := 32); -- Generic for input/output data width
  port(
    i_S   : in std_logic_vector(2-1 downto 0);
    i_D0  : in std_logic_vector(N-1 downto 0);
    i_D1  : in std_logic_vector(N-1 downto 0);
    i_D2  : in std_logic_vector(N-1 downto 0);
    i_D3  : in std_logic_vector(N-1 downto 0);
    o_O   : out std_logic_vector(N-1 downto 0)
  );
end mux4t1_N;

architecture structural of mux4t1_N is

  component mux2t1_N is
    generic(N : integer := N);
    port(
      i_S  : in std_logic;
      i_D0 : in std_logic_vector(N-1 downto 0);
      i_D1 : in std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- Intermediate signals for each level
  signal l2_0, l2_1 : std_logic_vector(N-1 downto 0);

  begin
  mux_l1_0 : mux2t1_N
    port map(
      i_S => i_S(0),
      i_D0 => i_D0,
      i_D1 => i_D1,
      o_O => l2_0
    );
  mux_l1_1 : mux2t1_N
    port map(
      i_S => i_S(0),
      i_D0 => i_D2,
      i_D1 => i_D3,
      o_O => l2_1
    );
  -- Level 2: 1 MUX to select between the outputs of the first level
  mux_l2_0 : mux2t1_N
    port map(
      i_S => i_S(1),
      i_D0 => l2_0,
      i_D1 => l2_1,
      o_O => o_O
    );

end structural;