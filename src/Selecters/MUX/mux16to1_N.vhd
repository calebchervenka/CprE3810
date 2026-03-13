library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux16to1_N is
    generic(N : integer := 32);
    port(
        i_S     : in std_logic_vector(3 downto 0);
        i_D0     : in std_logic_vector(N-1 downto 0);
        i_D1     : in std_logic_vector(N-1 downto 0);
        i_D2     : in std_logic_vector(N-1 downto 0);
        i_D3     : in std_logic_vector(N-1 downto 0);
        i_D4     : in std_logic_vector(N-1 downto 0);
        i_D5     : in std_logic_vector(N-1 downto 0);
        i_D6     : in std_logic_vector(N-1 downto 0);
        i_D7     : in std_logic_vector(N-1 downto 0);
        i_D8     : in std_logic_vector(N-1 downto 0);
        i_D9     : in std_logic_vector(N-1 downto 0);
        i_D10    : in std_logic_vector(N-1 downto 0);
        i_D11    : in std_logic_vector(N-1 downto 0);
        i_D12    : in std_logic_vector(N-1 downto 0);
        i_D13    : in std_logic_vector(N-1 downto 0);
        i_D14    : in std_logic_vector(N-1 downto 0);
        i_D15    : in std_logic_vector(N-1 downto 0);
        o_Q     : out std_logic_vector(N-1 downto 0)
    );
end mux16to1_N;

architecture structural of mux16to1_N is
    component decoder4to16 is
        port(
            i_S     : in std_logic_vector(3 downto 0);
            o_Q     : out std_logic_vector(32-1 downto 0)
        );
    end component;

    component mux32to1 is
        port(
            i_D     : in std_logic_vector(32-1 downto 0);
            i_S     : in std_logic_vector(3 downto 0);
            o_Q     : out std_logic
        );
    end component;

    signal s_dec_out : std_logic_vector(32-1 downto 0);
    signal s_mux_out : std_logic_vector(N-1 downto 0);
begin
    U_DECODER: decoder4to16
        port map(
            i_S => i_S,
            o_Q => s_dec_out
        );
    U_MUX: mux32to1
        port map(
            i_D => s_dec_out,
            i_S => i_S,
            o_Q => s_mux_out(0)
        );
    o_Q <= (others => 'Z');
    o_Q <= i_D0 when s_dec_out(0) = '1' else
           i_D1 when s_dec_out(1) = '1' else
           i_D2 when s_dec_out(2) = '1' else
           i_D3 when s_dec_out(3) = '1' else
           i_D4 when s_dec_out(4) = '1' else
           i_D5 when s_dec_out(5) = '1' else
           i_D6 when s_dec_out(6) = '1' else
           i_D7 when s_dec_out(7) = '1' else
           i_D8 when s_dec_out(8) = '1' else
           i_D9 when s_dec_out(9) = '1' else
           i_D10 when s_dec_out(10) = '1' else
           i_D11 when s_dec_out(11) = '1' else
           i_D12 when s_dec_out(12) = '1' else
           i_D13 when s_dec_out(13) = '1' else
           i_D14 when s_dec_out(14) = '1' else
           i_D15 when s_dec_out(15) = '1' else
           (others => 'Z');
end structural;