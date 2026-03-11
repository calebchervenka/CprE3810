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
    i_imm       : in std_logic_vector(32-1 downto 0);
    i_Branch    : in std_logic;
    i_Clk       : in std_logic;
    i_Rst       : in std_logic;
    i_WE        : in std_logic;
    i_PC        : in std_logic_vector(32-1 downto 0);
    o_PC        : out std_logic_vector(32-1 downto 0)
    );
end fetch_logic;

architecture Structural of fetch_logic is

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

    component Mux2t1_N is
        generic(N : integer);
        port(
            i_S : in std_logic;
            i_D0 : in std_logic_vector(N-1 downto 0);
            i_D1 : in std_logic_vector(N-1 downto 0);
            o_O : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component reg_N is
        generic(N : integer);
        port(
            i_Clk : in std_logic;
            i_Rst : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal s_PC : std_logic_vector(32-1 downto 0);
    signal s_PC_imm : std_logic_vector(32-1 downto 0);
    signal s_PC_plus_4 : std_logic_vector(32-1 downto 0);
    signal s_next_PC : std_logic_vector(32-1 downto 0);

    signal s_temp_PC : std_logic_vector(32-1 downto 0);

begin
    -- PC Register - feeds back computed next PC value
    PC_reg : reg_N
        generic map (
            N => 32
        )
        port map (
            i_Clk   => i_Clk,
            i_Rst   => i_Rst,
            i_WE    => '1',
            i_D     => s_temp_PC,
            o_Q     => s_PC
        );

    -- add4 : ripple_adder
    add4 : ripple_adder
        generic map (
            N => 32
        )
        port map (
            i_A     => s_PC,
            i_B     => x"00000004",
            i_Cin   => '0',
            o_Sum   => s_PC_plus_4
        );
    
    -- add_imm : ripple_adder
    add_imm : ripple_adder
        generic map (
            N => 32
        )
        port map (
            i_A     => s_PC,
            i_B     => i_imm,
            i_Cin   => '0',
            o_Sum   => s_PC_imm
        );

    -- mux_branch : Mux2t1_N
    mux_branch : Mux2t1_N
        generic map (
            N => 32
        )
        port map (
            i_S => i_Branch,
            i_D0 => s_PC_plus_4,
            i_D1 => s_PC_imm,
            o_O => s_temp_PC --o_PC
        );

        o_PC <= s_PC;

end Structural;