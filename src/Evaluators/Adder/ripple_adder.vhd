library IEEE;
use IEEE.std_logic_1164.all;

entity ripple_adder is
    generic(N : integer := 32);
    port(
        i_A     : in std_logic_vector(N-1 downto 0);
        i_B     : in std_logic_vector(N-1 downto 0);
        i_Cin   : in std_logic;
        o_Sum   : out std_logic_vector(N-1 downto 0);
        o_Cout  : out std_logic
    );
end ripple_adder;

architecture structural of ripple_adder is
    component full_adder is
        port(
            i_A     : in std_logic;
            i_B     : in std_logic;
            i_Cin   : in std_logic;
            o_Sum   : out std_logic;
            o_Cout  : out std_logic
        );
    end component;

    -- carry(0) is i_Cin, carry(N) is o_Cout
    signal carry : std_logic_vector(N downto 0);
begin
    carry(0) <= i_Cin;
    gen_adders: for i in 0 to N-1 generate
        FA: full_adder port map(
            i_A     => i_A(i),
            i_B     => i_B(i),
            i_Cin   => carry(i),
            o_Sum   => o_Sum(i),
            o_Cout  => carry(i+1)
        );
    end generate;
    o_Cout <= carry(N);
end structural;
