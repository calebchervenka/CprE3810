library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.RISCV_types.all;

entity pc_reg is
    generic(
        DATA_WIDTH  : integer := 32
    );
    port(
        i_Imm : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        i_Branch : in std_logic;
        i_WrPC : in std_logic;
        i_Rst : in std_logic;
        i_Clk : in std_logic;
        o_PC    : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end pc_reg;

architecture structural of pc_reg is
    component reg_N is
        generic(N : integer := DATA_WIDTH);
        port(
            i_Clk   : in std_logic;
            i_Rst   : in std_logic;
            i_WE    : in std_logic;
            i_D     : in std_logic_vector(N-1 downto 0);
            o_Q     : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component ripple_adder is
        generic(N : integer := DATA_WIDTH);
        port(
            i_A     : in std_logic_vector(N-1 downto 0);
            i_B     : in std_logic_vector(N-1 downto 0);
            i_Cin   : in std_logic;
            o_Sum   : out std_logic_vector(N-1 downto 0);
            o_Cout  : out std_logic
        );
    end component;

    component mux2t1_N is
        generic(N : integer := DATA_WIDTH);
        port(
            i_S          : in std_logic;
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal s_PC         : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC_next    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC_plus4   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC_branch  : std_logic_vector(DATA_WIDTH - 1 downto 0);

    begin
        reg : reg_N
        port map(
            i_Clk   => i_Clk,
            i_Rst   => i_Rst,
            i_D     => s_PC_next,
            i_WE    => i_WrPC,
            o_Q     => s_PC
        );

        add4 : ripple_adder
        port map(
            i_A     => s_PC,
            i_B     => x"00000004",
            i_Cin   => '0',
            o_Sum   => s_PC_plus4,
            o_Cout  => open
        );

        branch_add : ripple_adder
        port map(
            i_A     => s_PC,
            i_B     => i_Imm,
            i_Cin   => '0',
            o_Sum   => s_PC_branch,
            o_Cout  => open
        );

        mux_add_branch : mux2t1_N
        port map(
            i_S     => i_Branch,
            i_D0    => s_PC_plus4,
            i_D1    => s_PC_branch,
            o_O     => s_PC_next
        );

        o_PC <= s_PC;
end structural;