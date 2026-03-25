-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- mux8t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 8:1 N-bit MUX with a structural architecture.

-- 03/07/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity mux8t1_N is
  generic(N : integer := 32); -- Generic for input/output data width
  port(
    i_S   : in std_logic_vector(3-1 downto 0);
    i_D0  : in std_logic_vector(N-1 downto 0);
    i_D1  : in std_logic_vector(N-1 downto 0);
    i_D2  : in std_logic_vector(N-1 downto 0);
    i_D3  : in std_logic_vector(N-1 downto 0);
    i_D4  : in std_logic_vector(N-1 downto 0);
    i_D5  : in std_logic_vector(N-1 downto 0);
    i_D6  : in std_logic_vector(N-1 downto 0);
    i_D7  : in std_logic_vector(N-1 downto 0);
    o_O   : out std_logic_vector(N-1 downto 0)
  );
end mux8t1_N;

architecture structural of mux8t1_N is

  component mux2t1_N is
    generic(N : integer := 32);
    port(
      i_S  : in std_logic;
      i_D0 : in std_logic_vector(N-1 downto 0);
      i_D1 : in std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- Intermediate signals for each level
  signal l2_0, l2_1, l2_2, l2_3 : std_logic_vector(N-1 downto 0);
  signal l3_0, l3_1 : std_logic_vector(N-1 downto 0);

begin

  -- Level 1: 4 MUXes to select between pairs of inputs
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

  mux_l1_2 : mux2t1_N
    port map(
      i_S => i_S(0),
      i_D0 => i_D4,
      i_D1 => i_D5,
      o_O => l2_2
    );

  mux_l1_3 : mux2t1_N
    port map(
      i_S => i_S(0),
      i_D0 => i_D6,
      i_D1 => i_D7,
      o_O => l2_3
    );

  -- Level 2: 2 MUXes to select between the outputs of level 1
  mux_l2_0 : mux2t1_N
    port map(
      i_S => i_S(1),
      i_D0 => l2_0,
      i_D1 => l2_1,
      o_O => l3_0
    );

  mux_l2_1 : mux2t1_N
    port map(
      i_S => i_S(1),
      i_D0 => l2_2,
      i_D1 => l2_3,
      o_O => l3_1
    );

  -- Level 3: Final MUX to select between the outputs of level 2
  mux_l3 : mux2t1_N
    port map(
      i_S => i_S(2),
      i_D0 => l3_0,
      i_D1 => l3_1,
      o_O => o_O
    );

end structural;