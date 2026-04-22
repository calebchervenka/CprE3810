library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity reg_EX_MEM is
    generic( N : integer := 32);
    port(i_CLK        : in std_logic;
         i_Rst        : in std_logic;
         i_LD         : in std_logic;
         i_PC         : in std_logic_vector(N-1 downto 0);
         o_PC         : out std_logic_vector(N-1 downto 0);
        --  i_Imm        : in std_logic_vector(N-1 downto 0);
        --  o_Imm        : out std_logic_vector(N-1 downto 0);
        --  i_RD0        : in std_logic_vector(N-1 downto 0);
        --  o_RD0        : out std_logic_vector(N-1 downto 0);
        --  i_RD1        : in std_logic_vector(N-1 downto 0);
        --  o_RD1        : out std_logic_vector(N-1 downto 0);
         i_Inst       : in std_logic_vector(N-1 downto 0);
         o_Inst       : out std_logic_vector(N-1 downto 0);
         i_DMemData   : in std_logic_vector(N-1 downto 0);
         o_DMemData   : out std_logic_vector(N-1 downto 0);
         i_DMemWr     : in std_logic;
         o_DMemWr     : out std_logic;
        --  i_ALUSrcA    : in std_logic_vector(1 downto 0);
        --  o_ALUSrcA    : out std_logic_vector(1 downto 0);
        --  i_ALUSrcB    : in std_logic_vector(1 downto 0);
        --  o_ALUSrcB    : out std_logic_vector(1 downto 0);
        --  i_ALUCtrl    : in std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
        --  o_ALUCtrl    : out std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
        --  i_Branch     : in std_logic_vector(1 downto 0);
        --  o_Branch     : out std_logic_vector(1 downto 0);
        --  i_Branch_Cd  : in std_logic;
        --  o_Branch_Cd  : out std_logic;
         i_ALUResult  : in std_logic_vector(N-1 downto 0);
         o_ALUResult  : out std_logic_vector(N-1 downto 0);
        --  i_LoadData   : in std_logic_vector(N-1 downto 0);
        --  o_LoadData   : out std_logic_vector(N-1 downto 0);
         i_RegWr      : in std_logic;
         o_RegWr      : out std_logic;
         i_MemToReg   : in std_logic;
         o_MemToReg   : out std_logic;
         i_Halt       : in std_logic;
         o_Halt       : out std_logic
         );
end reg_EX_MEM;

architecture structure of reg_EX_MEM is
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
    reg_PC : reg_N -- PC register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_PC,
        o_Q     => o_PC
    );

    reg_Inst : reg_N
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_Inst,
        o_Q     => o_Inst
    );

    reg_DMemData : reg_N
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_DMemData,
        o_Q     => o_DMemData
    );

    reg_DMemWr : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => i_DMemWr,
        o_Q(0)  => o_DMemWr
    );

    reg_ALUResult : reg_N -- ALU result register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALUResult,
        o_Q     => o_ALUResult
    );

    -- reg_LoadData : reg_N
    -- generic map(
    --     N => N
    -- )
    -- port map(
    --     i_Clk   => i_Clk,
    --     i_Rst   => i_Rst,
    --     i_WE    => '1',
    --     i_D     => i_LoadData,
    --     o_Q     => o_LoadData
    -- );

    reg_RegWr : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => i_RegWr,
        o_Q(0)  => o_RegWr
    );

    reg_MemToReg : reg_N -- MemToReg register
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => i_MemToReg,
        o_Q(0)  => o_MemToReg
    );

    reg_Halt : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => i_Halt,
        o_Q(0)  => o_Halt
    );

end structure;
