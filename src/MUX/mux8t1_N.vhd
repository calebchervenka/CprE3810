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

  mux_l2_0: mux2t1_N generic map(N) port map(i_S(2), l1_0, l1_1, l2_0);
  mux_l2_1: mux2t1_N generic map(N) port map(i_S(2), l1_2, l1_3, l2_1);
  mux_l2_2: mux2t1_N generic map(N) port map(i_S(2), l1_4, l1_5, l2_2);
  mux_l2_3: mux2t1_N generic map(N) port map(i_S(2), l1_6, l1_7, l2_3);

  mux_l3_0: mux2t1_N generic map(N) port map(i_S(1), l2_0, l2_1, l3_0);
  mux_l3_1: mux2t1_N generic map(N) port map(i_S(1), l2_2, l2_3, l3_1);

  mux_l4: mux2t1_N generic map(N) port map(i_S(0), l3_0, l3_1, o_O);

end structural;