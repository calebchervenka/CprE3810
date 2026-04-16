library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

-- inputs control unit, acu, imm, and register file

entity reg_ID_EX is
    generic (N : integer := DATA_WIDTH);
    port (i_CLK         : in std_logic;
          i_RST         : in std_logic;
          i_LD          : in std_logic;


          -- Data Decode inputs
          i_PC : in std_logic_vector(N-1 downto 0); -- PC input
          i_imm : in std_logic_vector(N-1 downto 0); -- immediate input
          i_RD0 : in std_logic_vector(N-1 downto 0); -- RS0 Data input
          i_RD1 : in std_logic_vector(N-1 downto 0); -- RS1 Data input
          i_ALUCtrl : in std_logic_vector(3 downto 0); -- ALU control input | THIS MIGHT BE WRONG


          -- control signal inputs
          i_Branch       : in std_logic_vector(1 downto 0);
          i_Branch_Cond  : in std_logic;
          i_ALUSrcA      : in std_logic_vector(1 downto 0);
          i_ALUSrcB      : in std_logic_vector(1 downto 0);
          i_MemToReg     : in std_logic;
          i_MemWrite     : in std_logic;
          i_RegWrite     : in std_logic;
          i_Jalr         : in std_logic;
          i_Halt         : in std_logic;

        -- Data Decode outputs
          o_PC          : out std_logic_vector(N-1 downto 0); -- PC output
          o_imm         : out std_logic_vector(N-1 downto 0); -- immediate output
          o_RD0         : out std_logic_vector(N-1 downto 0); -- RS0 Data output
          o_RD1         : out std_logic_vector(N-1 downto 0);
          o_ALUCtrl : out std_logic_vector(3 downto 0); -- ALU control input | THIS MIGHT BE WRONG


          -- control signal outputs
          o_Branch      : out std_logic_vector(1 downto 0); 
          o_Branch_Cond : out std_logic;
          o_ALUSrcA     : out std_logic_vector(1 downto 0);
          o_ALUSrcB     : out std_logic_vector(1 downto 0);
          o_MemToReg    : out std_logic;
          o_MemWrite    : out std_logic;
          o_RegWrite    : out std_logic;
          o_Jalr        : out std_logic;
          o_Halt        : out std_logic
          );
end reg_ID_EX;

architecture structure of reg_ID_EX is
    ---------------------------
    --      Components
    ---------------------------
    component reg_N is
        generic(N : integer);
        port(
            i_CLK   : in std_logic; -- Clock input
            i_RST   : in std_logic; -- Reset input
            i_WE    : in std_logic; -- Write enable input
            i_D     : in std_logic_vector(N-1 downto 0); -- Data value input
            o_Q     : out std_logic_vector(N-1 downto 0) -- Data value output
        );
    end component;

begin
    reg_PC : reg_N
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_PC,
        o_Q     => o_PC
    );

    reg_imm : reg_N
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_imm,
        o_Q     => o_imm
    );

    reg_RD0 : reg_N
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_RD0,
        o_Q     => o_RD0
    );

    reg_RD1 : reg_N
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_RD1,
        o_Q     => o_RD1
    );

    end structure;

    