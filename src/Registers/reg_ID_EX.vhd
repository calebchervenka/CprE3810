library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

-- inputs control unit, acu, imm, and register file

entity reg_ID_EX is
    generic (N : integer := DATA_WIDTH);
    port(i_CLK        : in std_logic;
         i_Rst        : in std_logic;
         i_LD         : in std_logic;
         i_stall      : in std_logic; -- stall
         i_flush      : in std_logic; -- flush

         i_PC         : in std_logic_vector(N-1 downto 0);
         o_PC         : out std_logic_vector(N-1 downto 0);
         i_Imm        : in std_logic_vector(N-1 downto 0);
         o_Imm        : out std_logic_vector(N-1 downto 0);
         i_RD0        : in std_logic_vector(N-1 downto 0);
         o_RD0        : out std_logic_vector(N-1 downto 0);
         i_RD1        : in std_logic_vector(N-1 downto 0);
         o_RD1        : out std_logic_vector(N-1 downto 0);
         i_Inst       : in std_logic_vector(N-1 downto 0);
         o_Inst       : out std_logic_vector(N-1 downto 0);
         i_DMemData   : in std_logic_vector(N-1 downto 0);
         o_DMemData   : out std_logic_vector(N-1 downto 0);
         i_DMemWr     : in std_logic;
         o_DMemWr     : out std_logic;
         i_ALUSrcA    : in std_logic_vector(1 downto 0);
         o_ALUSrcA    : out std_logic_vector(1 downto 0);
         i_ALUSrcB    : in std_logic_vector(1 downto 0);
         o_ALUSrcB    : out std_logic_vector(1 downto 0);
         i_ALUCtrl    : in std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
         o_ALUCtrl    : out std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
         i_Branch     : in std_logic_vector(1 downto 0);
         o_Branch     : out std_logic_vector(1 downto 0);
         i_Branch_Cd  : in std_logic;
         o_Branch_Cd  : out std_logic;
         i_RegWr      : in std_logic;
         o_RegWr      : out std_logic;
         i_MemToReg   : in std_logic;
         o_MemToReg   : out std_logic;
         i_Halt       : in std_logic;
         o_Halt       : out std_logic
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

    component mux2t1_N is 
        generic(N : integer);
        port(
            i_S : in std_logic;
            i_D0 : in std_logic_vector(N-1 downto 0);
            i_D1 : in std_logic_vector(N-1 downto 0);
            o_O : out std_logic_vector(N-1 downto 0)
        );
    end component;


    ------------
    -- Signals
    ------------
    signal s_Inst_stall            : std_logic_vector(N-1 downto 0); -- output of stall mux, input to flush mux
    signal s_Inst_stall_final      : std_logic_vector(N-1 downto 0); -- output of flush mux
    signal s_PC_stall              : std_logic_vector(N-1 downto 0);
    signal s_PC_stall_final        : std_logic_vector(N-1 downto 0);
    
    signal s_RegWr_stall           : std_logic;
    signal s_RegWr_stall_final     : std_logic;
    signal s_MemToReg_stall        : std_logic;
    signal s_MemToReg_stall_final  : std_logic;
    signal s_DMemWr_stall          : std_logic;
    signal s_DMemWr_stall_final    : std_logic;
    signal s_Halt_stall            : std_logic;
    signal s_Halt_stall_final      : std_logic;
    signal s_Branch_Cd_stall       : std_logic;
    signal s_Branch_Cd_stall_final : std_logic;
    signal s_Branch_stall          : std_logic_vector(1 downto 0);
    signal s_Branch_stall_final    : std_logic_vector(1 downto 0);

begin

    -----------------------------------------------
    -- Instructions Logic for Stalling and Flushing
    -----------------------------------------------

    -- stall : 1 = keep previous instruction, stall : 0 = load new instruction
    mux_stall : mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_stall,
        i_D0 => i_Inst, -- new instruction
        i_D1 => o_Inst, -- previous instruction
        o_O => s_Inst_stall -- output to instruction register
    );

    -- flush : 1 = insert NOP, flush : 0 = keep instruction from stall mux
    mux_flush : mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_flush,
        i_D0 => s_Inst_stall, -- instruction from stall mux
        i_D1 => (others => '0'), -- NOP instruction
        o_O => s_Inst_stall_final -- output to instruction register
    );

    -- RegWr

    mux_RegWr_stall : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_stall,
        i_D0(0) => i_RegWr,
        i_D1(0) => o_RegWr,
        o_O(0) => s_RegWr_stall
    );

    mux_RegWr_flush : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_flush,
        i_D0(0) => s_RegWr_stall,
        i_D1(0) => '0', -- flush turns off RegWr
        o_O(0) => s_RegWr_stall_final
    );

    -- MemToReg

    mux_MemToReg_stall : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_stall,
        i_D0(0) => i_MemToReg,
        i_D1(0) => o_MemToReg,
        o_O(0) => s_MemToReg_stall
    );

    mux_MemToReg_flush : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_flush,
        i_D0(0) => s_MemToReg_stall,
        i_D1(0) => '0', -- flush turns off MemToReg
        o_O(0) => s_MemToReg_stall_final
    );

    -- DMEMWr

    mux_DMemWr_stall : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_stall,
        i_D0(0) => i_DMemWr,
        i_D1(0) => o_DMemWr,
        o_O(0) => s_DMemWr_stall
    );

    mux_DMemWr_flush : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_flush,
        i_D0(0) => s_DMemWr_stall,
        i_D1(0) => '0', -- flush turns off DMemWr
        o_O(0) => s_DMemWr_stall_final
    );

    -- HALT

    mux_Halt_stall : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_stall,
        i_D0(0) => i_Halt,
        i_D1(0) => o_Halt,
        o_O(0) => s_Halt_stall
    );

    mux_Halt_flush : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_flush,
        i_D0(0) => s_Halt_stall,
        i_D1(0) => '0', -- flush turns off Halt
        o_O(0) => s_Halt_stall_final
    );

    -- BRANCH CD

    mux_Branch_Cd_stall : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_stall,
        i_D0(0) => i_Branch_Cd,
        i_D1(0) => o_Branch_Cd,
        o_O(0) => s_Branch_Cd_stall
    );

    mux_Branch_Cd_flush : mux2t1_N
    generic map(
        N => 1
    )
    port map(
        i_S => i_flush,
        i_D0(0) => s_Branch_Cd_stall,
        i_D1(0) => '0', -- flush turns off Branch_Cd
        o_O(0) => s_Branch_Cd_stall_final
    );

    -- BRANCH

    mux_Branch_stall : mux2t1_N
    generic map(
        N => 2
    )
    port map(
        i_S => i_stall,
        i_D0 => i_Branch,
        i_D1 => o_Branch,
        o_O => s_Branch_stall
    );

    mux_Branch_flush : mux2t1_N
    generic map(
        N => 2
    )
    port map(
        i_S => i_flush,
        i_D0 => s_Branch_stall,
        i_D1 => "00",
        o_O => s_Branch_stall_final
    );

    ---------------------------------------
    -- PC Logic for Stalling and Flushing
    ----------------------------------------

    mux_stall_PC : mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_stall,
        i_D0 => i_PC,
        i_D1 => o_PC,
        o_O => s_PC_stall
    );

    mux_flush_PC : mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_flush,
        i_D0 => s_PC_stall,
        i_D1 => (others => '0'),
        o_O => s_PC_stall_final
    );


    ----------------------------------------
    -- PC, Instruction, and other Registers
    -----------------------------------------

    reg_PC : reg_N -- PC register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => s_PC_stall_final, -- resulting output from mux logic
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
        i_D     => s_Inst_stall_final, -- resulting output from mux logic
        o_Q     => o_Inst
    );

    reg_imm : reg_N -- immediate register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_imm,
        o_Q     => o_imm
    );

    reg_RD0 : reg_N -- RD0 register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_RD0,
        o_Q     => o_RD0
    );

    reg_RD1 : reg_N -- RD1 register
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_RD1,
        o_Q     => o_RD1
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
        i_D(0)  => s_DMemWr_stall_final, -- output from stall and flush mux logic
        o_Q(0)  => o_DMemWr
    );

    reg_ALUSrcA : reg_N
    generic map(
        N => 2
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALUSrcA,
        o_Q     => o_ALUSrcA
    );

    reg_ALUSrcB : reg_N
    generic map(
        N => 2
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALUSrcB,
        o_Q     => o_ALUSrcB
    );

    reg_ALUCtrl : reg_N
    generic map(
        N => ALU_CTRL_WIDTH
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALUCtrl,
        o_Q     => o_ALUCtrl
    );

    reg_Branch : reg_N
    generic map(
        N => 2
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => s_Branch_stall_final, -- changed from i_Branch
        o_Q     => o_Branch
    );

    reg_Branch_Cd : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => s_Branch_Cd_stall_final, -- output from stall and flush mux logic
        o_Q(0)  => o_Branch_Cd
    );

    reg_RegWr : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => s_RegWr_stall_final, -- output from stall and flush mux logic
        o_Q(0)  => o_RegWr
    );

    reg_MemToReg : reg_N
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)  => s_MemToReg_stall_final, -- output from stall and flush mux logic
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
        i_D(0)  => s_Halt_stall_final, -- output from stall and flush mux logic
        o_Q(0)  => o_Halt
    );

end structure;
