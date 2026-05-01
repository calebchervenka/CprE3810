library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.RISCV_types.all;

entity pc_reg is
    generic(
        DATA_WIDTH  : integer := 32
    );
    port(
        i_Branch : in std_logic_vector(1 downto 0);
        i_BranchCondition : std_logic;
        i_Imm   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        i_Reg1Data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        i_Rst : in std_logic;
        i_Clk : in std_logic;
        i_PC_EX : in std_logic_vector(DATA_WIDTH - 1 downto 0);
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

    signal s_PC_base    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC         : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC_next    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_PC_reg     : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_4_Imm      : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_redirect   : std_logic;
    signal s_jalr       : std_logic;
    signal s_not_branch0 : std_logic;
    signal s_cond_branch : std_logic;
    signal s_taken_branch : std_logic;

    begin
        not_branch0 : entity work.invg(dataflow)
            port map(i_A => i_Branch(0),
                     o_F => s_not_branch0);

        cond_branch : entity work.andg2(dataflow)
            port map(i_A => i_Branch(1),
                     i_B => s_not_branch0,
                     o_F => s_cond_branch);

        taken_branch : entity work.andg2(dataflow)
            port map(i_A => s_cond_branch,
                     i_B => i_BranchCondition,
                     o_F => s_taken_branch);

        redirect : entity work.org2(dataflow)
            port map(i_A => i_Branch(0),
                     i_B => s_taken_branch,
                     o_F => s_redirect);

        jalr_branch : entity work.andg2(dataflow)
            port map(i_A => i_Branch(1),
                     i_B => i_Branch(0),
                     o_F => s_jalr);

        reg : reg_N
        port map(
            i_Clk   => i_Clk,
            i_Rst   => i_Rst,
            i_D     => s_PC_next,
            i_WE    => '1',
            o_Q     => s_PC
        );

        mux_pc_reg : mux2t1_N
        port map(
            i_S     => s_jalr,
            i_D0    => i_PC_EX,
            i_D1    => i_Reg1Data,
            o_O     => s_PC_reg
        );

        mux_pc_ex : mux2t1_N
        port map(
            i_S     => s_redirect,
            i_D0    => s_PC,
            i_D1    => s_PC_reg,
            o_O     => s_PC_base
        );

        mux_4_Imm : mux2t1_N
        port map(
            i_S     => s_redirect,
            i_D0    => x"00000004",
            i_D1    => i_Imm,
            o_O     => s_4_Imm
        );

        adder_pc : ripple_adder
        port map(
            i_A     => s_PC_base,
            i_B     => s_4_Imm,
            i_Cin   => '0',
            o_Sum   => s_PC_next,
            o_Cout  => open
        );

        o_PC <= s_PC;
end structural;
