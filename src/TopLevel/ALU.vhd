library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    -- add/sub, addi/subi, slt, and, or, xor, nor, sll, srl, sra, slli, srli, srai
    port(
        i_a : in std_logic_vector(31 downto 0);
        i_b : in std_logic_vector(31 downto 0);
        i_ALUCtrl : in std_logic_vector(3 downto 0);
        o_result : out std_logic_vector(31 downto 0)
        );
    end ALU;

architecture Structural of ALU is

  component ripple_adder is
    generic(N : integer := 32);
    port(
      i_A     : in std_logic_vector(N-1 downto 0);
      i_B     : in std_logic_vector(N-1 downto 0);
      i_Cin   : in std_logic;
      o_Sum   : out std_logic_vector(N-1 downto 0);
      o_Cout  : out std_logic
    );
  end component;

  component mux16t1_N is
    generic(N : integer := 32);
    port(
      i_S    : in std_logic_vector(3 downto 0);
      i_D0   : in std_logic_vector(N-1 downto 0);
      i_D1   : in std_logic_vector(N-1 downto 0);
      i_D2   : in std_logic_vector(N-1 downto 0);
      i_D3   : in std_logic_vector(N-1 downto 0);
      i_D4   : in std_logic_vector(N-1 downto 0);
      i_D5   : in std_logic_vector(N-1 downto 0);
      i_D6   : in std_logic_vector(N-1 downto 0);
      i_D7   : in std_logic_vector(N-1 downto 0);
      i_D8   : in std_logic_vector(N-1 downto 0);
      i_D9   : in std_logic_vector(N-1 downto 0);
      i_D10  : in std_logic_vector(N-1 downto 0);
      i_D11  : in std_logic_vector(N-1 downto 0);
      i_D12  : in std_logic_vector(N-1 downto 0);
      i_D13  : in std_logic_vector(N-1 downto 0);
      i_D14  : in std_logic_vector(N-1 downto 0);
      i_D15  : in std_logic_vector(N-1 downto 0);
      o_O    : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- Signals for operation results
  signal s_add_result       : std_logic_vector(31 downto 0);
  signal s_sub_result       : std_logic_vector(31 downto 0);
  signal s_and_result       : std_logic_vector(31 downto 0);
  signal s_or_result        : std_logic_vector(31 downto 0);
  signal s_xor_result       : std_logic_vector(31 downto 0);
  signal s_nor_result       : std_logic_vector(31 downto 0);
  signal s_slt_result       : std_logic_vector(31 downto 0);
  signal s_shift_ll_result  : std_logic_vector(31 downto 0);
  signal s_shift_rl_result  : std_logic_vector(31 downto 0);
  signal s_shift_ra_result  : std_logic_vector(31 downto 0);
  signal s_b_inv            : std_logic_vector(31 downto 0);

begin

  s_b_inv <= not i_b;

  -- Adder for add operation
  add_inst: ripple_adder
    generic map(N => 32)
    port map(
      i_A   => i_a,
      i_B   => i_b,
      i_Cin => '0',
      o_Sum => s_add_result,
      o_Cout => open
    );

  -- Adder for sub operation (using two's complement)
  sub_inst: ripple_adder
    generic map(N => 32)
    port map(
      i_A   => i_a,
      i_B   => s_b_inv,
      i_Cin => '1',
      o_Sum => s_sub_result,
      o_Cout => open
    );

  -- Logic operations
  s_and_result <= i_a and i_b;
  s_or_result  <= i_a or i_b;
  s_xor_result <= i_a xor i_b;
  s_nor_result <= not (i_a or i_b);

  -- SLT operation (set if less than, signed)
  s_slt_result <= (0 => '1', others => '0') when signed(i_a) < signed(i_b) else (others => '0');

  -- Shift operations (using behavioral shifts)
  s_shift_ll_result <= std_logic_vector(shift_left(unsigned(i_a), to_integer(unsigned(i_b(4 downto 0)))));
  s_shift_rl_result <= std_logic_vector(shift_right(unsigned(i_a), to_integer(unsigned(i_b(4 downto 0)))));
  s_shift_ra_result <= std_logic_vector(shift_right(signed(i_a), to_integer(unsigned(i_b(4 downto 0)))));

  mux_select: mux16t1_N
    generic map(N => 32)
    port map(
      i_S   => i_ALUCtrl,
      i_D0  => s_add_result,       -- add/addi
      i_D1  => s_sub_result,       -- sub/subi
      i_D2  => s_slt_result,       -- slt
      i_D3  => s_and_result,       -- and
      i_D4  => s_or_result,        -- or
      i_D5  => s_xor_result,       -- xor
      i_D6  => s_nor_result,       -- nor
      i_D7  => s_shift_ll_result,  -- sll
      i_D8  => s_shift_rl_result,  -- srl
      i_D9  => s_shift_ra_result,  -- sra
      i_D10 => s_shift_ll_result,  -- slli
      i_D11 => s_shift_rl_result,  -- srli
      i_D12 => s_shift_ra_result,  -- srai
      i_D13 => (others => '0'),    -- unused
      i_D14 => (others => '0'),    -- unused
      i_D15 => (others => '0'),    -- unused
      o_O   => o_result
    );

end Structural; 