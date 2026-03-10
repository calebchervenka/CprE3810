-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- fetch_logic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of a fetch logic unit that calculates the next PC value based on the current PC, an immediate value, and a branch signal.

-- 03/07/2026 by CC::Design created.
-------------------------------------------------------------------------


library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch_logic is
  port(
    i_imm       : std_logic_vector(32-1 downto 0);
    i_Branch    : std_logic;
    i_Clk       : std_logic;
    i_Rst       : std_logic;
    o_PC        : std_logic_vector(32-1 downto 0)
    );

    component Adder is
        generic(
            A_WIDTH : integer := 32;
            B_WIDTH : integer := 32;
            C_WIDTH : integer := 32
        );

        port(
            iCLK           : in std_logic;
            iA              : in std_logic_vector(A_WIDTH-1 downto 0);
            iB              : in std_logic_vector(B_WIDTH-1 downto 0);
            oC              : out std_logic_vector(C_WIDTH-1 downto 0)
        );
    end component;
end fetch_logic;

architecture Structural of fetch_logic is

    signal s_PC : std_logic_vector(32-1 downto 0);
    signal s_PC_plus_4 : std_logic_vector(32-1 downto 0);
    signal s_PC_next : std_logic_vector(32-1 downto 0);

begin
    add4 : Adder
        generic map (
            A_WIDTH => 32,
            B_WIDTH => 32,
            C_WIDTH => 32
        )
        port map (
            i_a => s_PC,
            i_b => std_logic_vector(to_unsigned(4, 32)),
            o_sum => s_PC_plus_4
        );
    
    add_branch : Adder
        generic map (
            A_WIDTH => 32,
            B_WIDTH => 32,
            C_WIDTH => 32
        )
        port map (
            i_a => s_PC,
            i_b => i_imm,
            o_sum => s_PC_next
        );
    
    mux_branch : mux2t1_N
        generic map (
            N => 32
        )
        port map (
            i_S => i_Branch,
            i_D0 => s_PC_plus_4,
            i_D1 => s_PC_next,
            o_O => s_PC
        );
    
    imem : mem
        generic map (
            ADDR_WIDTH => 10,
            DATA_WIDTH => 32
        )
        port map (
            clk => i_Clk,
            addr => s_PC(9 downto 0),
            data => (others => '0'),
            we => '0',
            q => o_PC
        );

end Structural;