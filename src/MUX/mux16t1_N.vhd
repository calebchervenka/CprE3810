-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- mux16t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 16:1 N-bit MUX with a structural architecture.

-- 03/07/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity mux16t1_N is
  generic(N : integer := 32); -- Generic for input/output data width
  port(
    i_S   : in std_logic_vector(3 downto 0);
    i_D0  : in std_logic_vector(N-1 downto 0);
    i_D1  : in std_logic_vector(N-1 downto 0);
    i_D2  : in std_logic_vector(N-1 downto 0);
    i_D3  : in std_logic_vector(N-1 downto 0);
    i_D4  : in std_logic_vector(N-1 downto 0);
    i_D5  : in std_logic_vector(N-1 downto 0);
    i_D6  : in std_logic_vector(N-1 downto 0);
    i_D7  : in std_logic_vector(N-1 downto 0);
    i_D8  : in std_logic_vector(N-1 downto 0);
    i_D9  : in std_logic_vector(N-1 downto 0);
    i_D10 : in std_logic_vector(N-1 downto 0);
    i_D11 : in std_logic_vector(N-1 downto 0);
    i_D12 : in std_logic_vector(N-1 downto 0);
    i_D13 : in std_logic_vector(N-1 downto 0);
    i_D14 : in std_logic_vector(N-1 downto 0);
    i_D15 : in std_logic_vector(N-1 downto 0);
    o_O   : out std_logic_vector(N-1 downto 0)
  );
end mux16t1_N;

architecture structural of mux16t1_N is

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
  signal l1_0, l1_1, l1_2, l1_3, l1_4, l1_5, l1_6, l1_7 : std_logic_vector(N-1 downto 0);
  signal l2_0, l2_1, l2_2, l2_3 : std_logic_vector(N-1 downto 0);
  signal l3_0, l3_1 : std_logic_vector(N-1 downto 0);

begin

  -- Level 1: Select based on i_S(3)
  mux_l1_0: mux2t1_N generic map(N) port map(i_S(3), i_D0, i_D1, l1_0);
  mux_l1_1: mux2t1_N generic map(N) port map(i_S(3), i_D2, i_D3, l1_1);
  mux_l1_2: mux2t1_N generic map(N) port map(i_S(3), i_D4, i_D5, l1_2);
  mux_l1_3: mux2t1_N generic map(N) port map(i_S(3), i_D6, i_D7, l1_3);
  mux_l1_4: mux2t1_N generic map(N) port map(i_S(3), i_D8, i_D9, l1_4);
  mux_l1_5: mux2t1_N generic map(N) port map(i_S(3), i_D10, i_D11, l1_5);
  mux_l1_6: mux2t1_N generic map(N) port map(i_S(3), i_D12, i_D13, l1_6);
  mux_l1_7: mux2t1_N generic map(N) port map(i_S(3), i_D14, i_D15, l1_7);

  -- Level 2: Select based on i_S(2)
  mux_l2_0: mux2t1_N generic map(N) port map(i_S(2), l1_0, l1_1, l2_0);
  mux_l2_1: mux2t1_N generic map(N) port map(i_S(2), l1_2, l1_3, l2_1);
  mux_l2_2: mux2t1_N generic map(N) port map(i_S(2), l1_4, l1_5, l2_2);
  mux_l2_3: mux2t1_N generic map(N) port map(i_S(2), l1_6, l1_7, l2_3);

  -- Level 3: Select based on i_S(1)
  mux_l3_0: mux2t1_N generic map(N) port map(i_S(1), l2_0, l2_1, l3_0);
  mux_l3_1: mux2t1_N generic map(N) port map(i_S(1), l2_2, l2_3, l3_1);

  -- Level 4: Select based on i_S(0)
  mux_l4: mux2t1_N generic map(N) port map(i_S(0), l3_0, l3_1, o_O);

end structural;