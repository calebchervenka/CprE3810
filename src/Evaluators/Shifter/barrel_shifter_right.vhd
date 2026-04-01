library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barrel_shifter_right is
    Port (
        i_D     : in  std_logic_vector(31 downto 0);
        i_shift : in  std_logic_vector(4 downto 0);
        o_Q     : out std_logic_vector(31 downto 0)
    );
end barrel_shifter_right;

architecture Structural of barrel_shifter_right is
    type mux_inputs_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal mux_in : mux_inputs_array;
begin
    
    G_MUX: for i in 0 to 31 generate
        G_INPUTS: for s in 0 to 31 generate
            MUX_VAL: if (i + s <= 31) generate
                mux_in(i)(s) <= i_D(i + s);
            end generate MUX_VAL;
            
            ZERO_PAD: if (i + s > 31) generate
                mux_in(i)(s) <= '0';
            end generate ZERO_PAD;
        end generate G_INPUTS;
        
        o_Q(i) <= mux_in(i)(to_integer(unsigned(i_shift)));
    end generate G_MUX;

end Structural;