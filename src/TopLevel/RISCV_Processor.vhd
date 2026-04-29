-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  ------------------------------
  --    Signals
  ------------------------------

  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  -- signal s_PC : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  -- signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  signal s_Halt         : std_logic;
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated


  -- Instruction Fetch
  signal s_PC_IF        : std_logic_vector(N-1 downto 0);
  signal s_Inst_IF      : std_logic_vector(N-1 downto 0);

  -- Instruction Decode
  signal s_PC_ID        : std_logic_vector(N-1 downto 0);
  signal s_Imm_ID       : std_logic_vector(N-1 downto 0);
  signal s_Inst_ID      : std_logic_vector(N-1 downto 0);
  signal s_DMemData_ID   : std_logic_vector(N-1 downto 0);

  signal s_DMemWr_ID    : std_logic;
  signal c_ALUSrcA_ID   : std_logic_vector(1 downto 0);
  signal c_ALUSrcB_ID   : std_logic_vector(1 downto 0);
  signal c_ALUCtrl_ID   : std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
  signal c_Branch_ID    : std_logic_vector(1 downto 0);
  signal c_Branch_Cd_ID : std_logic;
  signal c_MemToReg_ID  : std_logic;
  signal c_RegWr_ID     : std_logic;
  signal c_Halt_ID      : std_logic;

  signal s_Reg1Data_ID        : std_logic_vector(N-1 downto 0);
  signal s_Reg2Data_ID        : std_logic_vector(N-1 downto 0);

  -- Execute
  signal s_PC_EX        : std_logic_vector(N-1 downto 0);
  signal s_Imm_EX       : std_logic_vector(N-1 downto 0);
  signal s_Inst_EX      : std_logic_vector(N-1 downto 0);
  signal s_DMemData_EX   : std_logic_vector(N-1 downto 0);
  signal s_RD0_EX       : std_logic_vector(N-1 downto 0);
  signal s_RD1_EX       : std_logic_vector(N-1 downto 0);

  signal s_DMemWr_EX    : std_logic;
  signal c_ALUSrcA_EX   : std_logic_vector(1 downto 0);
  signal c_ALUSrcB_EX   : std_logic_vector(1 downto 0);
  signal c_ALUCtrl_EX   : std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
  signal s_ALUResult_EX : std_logic_vector(N-1 downto 0);
  signal c_Branch_EX    : std_logic_vector(1 downto 0);
  signal c_Branch_Cd_EX : std_logic;
  signal c_MemToReg_EX  : std_logic;
  signal c_RegWr_EX     : std_logic;
  signal c_Halt_EX      : std_logic;

  signal s_ImmU_EX      : std_logic_vector(N-1 downto 0);
  signal s_ALU_A_EX     : std_logic_vector(N-1 downto 0);
  signal s_ALU_B_EX     : std_logic_vector(N-1 downto 0);
  signal s_ALU_A        : std_logic_vector(N-1 downto 0);
  signal s_ALU_B        : std_logic_vector(N-1 downto 0);

  -- Memory
  signal s_PC_MEM       : std_logic_vector(N-1 downto 0);
  -- signal s_Imm_MEM      : std_logic_vector(N-1 downto 0);
  signal s_Inst_MEM       : std_logic_vector(N-1 downto 0);
  signal s_DMemData_MEM    : std_logic_vector(N-1 downto 0);
  signal s_ALUResult_MEM  : std_logic_vector(N-1 downto 0);
  signal s_LoadData_MEM   : std_logic_vector(N-1 downto 0);
  signal s_RegWrData_MEM  : std_logic_vector(N-1 downto 0);

  signal s_DMemWr_MEM   : std_logic;
  signal c_MemToReg_MEM : std_logic;
  signal c_RegWr_MEM    : std_logic;
  signal c_Halt_MEM     : std_logic;

  -- Writeback
  -- signal s_PC_WB        : std_logic_vector(N-1 downto 0);
  signal s_Inst_WB      : std_logic_vector(N-1 downto 0);
  signal s_DMemData_WB  : std_logic_vector(N-1 downto 0);
  signal s_ALUResult_WB : std_logic_vector(N-1 downto 0);
  signal s_LoadData_WB  : std_logic_vector(N-1 downto 0);
  signal s_RegWrData_WB : std_logic_vector(N-1 downto 0);

  signal s_DMemWr_WB    : std_logic;
  signal c_MemToReg_WB  : std_logic;
  signal c_RegWr_WB     : std_logic;
  signal c_Halt_WB     : std_logic;

  -- Forwarding Controls
  signal c_FW_DMemData : std_logic;
  -- signal c_FW_RegData1 : std_logic;
  -- signal c_FW_RegData2 : std_logic;

  signal c_Fwd_Rd1_from_mem : std_logic;
  signal c_Fwd_Rd1_from_wb  : std_logic;
  signal c_Fwd_Rd2_from_mem : std_logic;
  signal c_Fwd_Rd2_from_wb  : std_logic;

  
  -- Control signals
  -- signal c_Branch   : std_logic_vector(1 downto 0);
  -- signal c_Branch_Cond : std_logic; -- Branch
  -- signal c_Jalr     : std_logic; -- JALR
  -- signal c_ALUSrcA  : std_logic_vector(1 downto 0);
  -- signal c_ALUSrcB  : std_logic_vector(1 downto 0);
  -- signal c_MemToReg : std_logic;
  -- signal c_ALUCtrl         : std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);


  -- Data signals
  -- signal s_Imm             : std_logic_vector(N-1 downto 0);
  -- signal s_ImmU            : std_logic_vector(N-1 downto 0); -- Upper Immediate
  -- signal s_ALUResult       : std_logic_vector(N-1 downto 0);
  -- signal s_ALUZero         : std_logic;
  -- signal s_PCJ              : std_logic_vector(N-1 downto 0); -- Program Cursor with bit 22 set
  -- signal s_LoadData        : std_logic_vector(N-1 downto 0); -- output of load data mux that accounts for lb and lh instructions

  ------------------------------
  --    Components
  ------------------------------
  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  component control_unit is
    generic(DATA_WIDTH : integer);
    port(
      i_Inst      : in std_logic_vector(DATA_WIDTH-1 downto 0);
      o_Branch    : out std_logic_vector(1 downto 0);
      -- o_Branch_Cond   : out std_logic;
      o_ALUSrcA   : out std_logic_vector(1 downto 0);
      o_ALUSrcB   : out std_logic_vector(1 downto 0);
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_RegWrite  : out std_logic;
      -- o_Jalr      : out std_logic;
      o_Halt      : out std_logic
    );
  end component;
  
  component pc_reg is
    generic(DATA_WIDTH : integer);
    port(
      i_Branch : in std_logic_vector(1 downto 0);
      i_BranchCondition : in std_logic;
      i_Imm  : in std_logic_vector(DATA_WIDTH-1 downto 0);
      i_Reg1Data  : in std_logic_vector(DATA_WIDTH-1 downto 0);
      i_Rst     : in std_logic;
      i_Clk     : in std_logic;
      i_PC_EX : in std_logic_vector(DATA_WIDTH - 1 downto 0);
      o_PC      : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;

  component imm_gen is
    generic(DATA_WIDTH : integer);
    port(
      i_Instr    : in std_logic_vector(DATA_WIDTH-1 downto 0);
      o_Imm     : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component reg_file is
    generic(address_width : integer;
            reg_count     : integer;
            data_width    : integer);
    port(
      i_WD    : in std_logic_vector(data_width-1 downto 0);
      o_RD0   : out std_logic_vector(data_width-1 downto 0);
      o_RD1   : out std_logic_vector(data_width-1 downto 0);
      i_RS0   : in std_logic_vector(address_width-1 downto 0);
      i_RS1   : in std_logic_vector(address_width-1 downto 0);
      i_RD    : in std_logic_vector(address_width-1 downto 0);
      i_CLK   : in std_logic;
      i_RST   : in std_logic;
      i_WE    : in std_logic
    );
  end component;

  component ACU is
    generic(DATA_WIDTH : integer);
    port(i_Inst     : in std_logic_vector(DATA_WIDTH-1 downto 0);
         o_ALUCtrl  : out std_logic_vector(ALU_CTRL_WIDTH-1 downto 0)
    );
  end component;

  component ALU is
    generic(DATA_WIDTH : integer);
    port(i_A          : in std_logic_vector(DATA_WIDTH-1 downto 0);
         i_B          : in std_logic_vector(DATA_WIDTH-1 downto 0);
         i_ALUCtrl    : in std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
         o_ALUResult  : out std_logic_vector(DATA_WIDTH-1 downto 0);
         o_Zero       : out std_logic);
  end component;

  component reg_IF_ID is
    generic(N : integer);
    port(i_CLK        : in std_logic;
         i_Rst        : in std_logic;
         i_LD         : in std_logic;
         i_stall      : in std_logic;
         i_flush      : in std_logic;
         i_PC         : in std_logic_vector(N-1 downto 0);
         o_PC         : out std_logic_vector(N-1 downto 0);
         i_Inst       : in std_logic_vector(N-1 downto 0);
         o_Inst       : out std_logic_vector(N-1 downto 0));
  end component;

  component reg_ID_EX is
    generic(N : integer);
    port(i_CLK        : in std_logic;
         i_Rst        : in std_logic;
         i_LD         : in std_logic;
         i_stall      : in std_logic;
         i_flush      : in std_logic;
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
  end component;

  component reg_EX_MEM is
    generic(N : integer);
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
  end component;

  component reg_MEM_WB is
    generic(N : integer);
    port(i_CLK        : in std_logic;
         i_Rst        : in std_logic;
         i_LD         : in std_logic;
        --  i_PC         : in std_logic_vector(N-1 downto 0);
        --  o_PC         : out std_logic_vector(N-1 downto 0);
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
        --  i_MemToReg   : in std_logic;
        --  o_MemToReg   : out std_logic;
         i_RegWrData  : in std_logic_vector(N-1 downto 0);
         o_RegWrData  : out std_logic_vector(N-1 downto 0);
         i_Halt       : in std_logic;
         o_Halt       : out std_logic
         );
  end component;

  component mem_ext is
    generic(DATA_WIDTH : integer);
    port(
        i_MemData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_func3   : in std_logic_vector(3-1 downto 0);
        i_ALUResult : in std_logic_vector(DATA_WIDTH-1 downto 0); -- assuming ALUResult is available as an input to this module for byte/half-word selection
        o_ExtData  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component mux2t1_N is
    generic(N : integer);
    port(i_S  : in std_logic;
         i_D0 : in std_logic_vector(N-1 downto 0);
         i_D1 : in std_logic_vector(N-1 downto 0);
         o_O  : out std_logic_vector(N-1 downto 0));
  end component;

  component ripple_adder is
    generic(N : integer);
    port(
        i_A     : in std_logic_vector(N-1 downto 0);
        i_B     : in std_logic_vector(N-1 downto 0);
        i_Cin   : in std_logic;
        o_Sum   : out std_logic_vector(N-1 downto 0);
        o_Cout  : out std_logic
    );
  end component;

  component mux4t1_N is
    generic(N : integer);
    port(i_S  : in std_logic_vector(1 downto 0);
         i_D0 : in std_logic_vector(N-1 downto 0);
         i_D1 : in std_logic_vector(N-1 downto 0);
         i_D2 : in std_logic_vector(N-1 downto 0);
         i_D3 : in std_logic_vector(N-1 downto 0);
         o_O  : out std_logic_vector(N-1 downto 0));
  end component;

  component FU is
    generic(DATA_WIDTH : integer);
    port (
        i_inst_EX     : in std_logic_vector(31 downto 0);
        i_inst_MEM    : in std_logic_vector(31 downto 0);
        i_inst_WB     : in std_logic_vector(31 downto 0);
        o_FW_DMemData : out std_logic;
        o_Fwd_Rd1_from_mem : out std_logic;
        o_Fwd_Rd1_from_wb  : out std_logic;
        o_Fwd_Rd2_from_mem : out std_logic;
        o_Fwd_Rd2_from_wb  : out std_logic
    );
    end component;

begin
  s_Ovfl <= '0';

  with iInstLd select
    s_IMemAddr <= s_PC_IF when '0',
      iInstAddr when others;


  -------------------------------
  --  Instruction Fetch
  -------------------------------

  PCReg : pc_reg
    generic map(DATA_WIDTH => N)
    port map(
      i_Branch    => c_Branch_EX,
      i_BranchCondition => s_ALUResult_EX(0),
      i_Imm       => s_Imm_EX,
      i_Reg1Data  => s_RD0_EX,
      i_Rst     => iRst,
      i_Clk     => iClk,
      i_PC_EX   => s_PC_EX,
      o_PC      => s_PC_IF);

  IMem : mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst_IF);

  IF_ID : reg_IF_ID
    generic map(N => DATA_WIDTH)
    port map(
      i_Clk   => iClk,
      i_Rst   => iRst,
      i_LD    => '1',
      i_stall => '0',
      i_flush => s_ALUResult_EX(0), -- changed this
      i_PC    => s_PC_IF,
      i_Inst  => s_Inst_IF,
      o_PC    => s_PC_ID,
      o_Inst  => s_Inst_ID
    );


  -------------------------------
  --  Instruction Decode
  -------------------------------

  controls : control_unit
  generic map(DATA_WIDTH => N)
  port map(
    i_Inst  => s_Inst_ID,
    o_Branch  => c_Branch_ID,
    -- o_Branch_Cond => c_Branch_Cond_ID,
    o_ALUSrcA  => c_ALUSrcA_ID,
    o_ALUSrcB  => c_ALUSrcB_ID,
    o_MemToReg  => c_MemToReg_ID,
    o_MemWrite  => s_DMemWr_ID,
    o_RegWrite  => c_RegWr_ID,
    -- o_Jalr      => c_Jalr_ID,
    o_Halt      => c_Halt_ID
  );
  s_RegWr <= c_RegWr_WB;

  alu_control : acu
    generic map(DATA_WIDTH => N)
    port map(i_Inst     => s_Inst_ID,
             o_ALUCtrl  => c_ALUCtrl_ID);

  immediate_generator : imm_gen
    generic map(DATA_WIDTH => N)
    port map(
      i_Instr   => s_Inst_ID,
      o_Imm     => s_Imm_ID
    );

  s_RegWrAddr <= s_Inst_WB(11 downto 7);

  register_file : reg_file
    generic map(address_width => REG_ADDR_WIDTH,
                reg_count     => REG_COUNT,
                data_width    => N)
    port map(
        i_WD    => s_RegWrData_WB,
        o_RD0   => s_Reg1Data_ID,
        o_RD1   => s_Reg2Data_ID,
        i_RS0   => s_Inst_ID(19 downto 15),
        i_RS1   => s_Inst_ID(24 downto 20),
        i_RD    => s_RegWrAddr,
        i_CLK   => iClk,
        i_RST   => iRst,
        i_WE    => c_RegWr_WB);
  s_DMemData_ID  <= s_Reg2Data_ID;

  ID_EX : reg_ID_EX
    generic map(N   => DATA_WIDTH)
    port map(
      i_Clk   =>  iClk,
      i_Rst   =>  iRst,
      i_LD    =>  '1',
      i_stall =>  '0',
      i_flush =>  s_ALUResult_EX(0), --- changed from
      i_PC    =>  s_PC_ID,
      o_PC    =>  s_PC_EX,

      i_Imm => s_Imm_ID,      o_Imm => s_Imm_EX,
      i_RD0 => s_Reg1Data_ID, o_RD0 => s_RD0_EX,
      i_RD1 => s_Reg2Data_ID, o_RD1 => s_RD1_EX,
      i_Inst => s_Inst_ID,    o_Inst => s_Inst_EX,
      i_DMemData  => s_DMemData_ID, o_DMemData => s_DMemData_EX,

      i_DMemWr => s_DMemWr_ID,        o_DMemWr => s_DMemWr_EX,
      i_ALUSrcA => c_ALUSrcA_ID,      o_ALUSrcA => c_ALUSrcA_EX,
      i_ALUSrcB => c_ALUSrcB_ID,      o_ALUSrcB => c_ALUSrcB_EX,
      i_ALUCtrl => c_ALUCtrl_ID,      o_ALUCtrl => c_ALUCtrl_EX,
      i_RegWr => c_RegWr_ID,          o_RegWr => c_RegWr_EX,
      i_Branch => c_Branch_ID,        o_Branch  => c_Branch_EX,
      i_Branch_Cd => c_Branch_Cd_ID,  o_Branch_Cd => c_Branch_Cd_EX,
      i_MemToReg => c_MemToReg_ID,    o_MemToReg => c_MemToReg_EX,
      i_Halt => c_Halt_ID,            o_Halt => c_Halt_EX
    );


  -------------------------------
  --  EXECUTE
  -------------------------------

  mux_alu_a_fw : mux4t1_N
    generic map(N => N)
    port map(
      i_S   => c_Fwd_Rd1_from_wb & c_Fwd_Rd1_from_mem,
      i_D0  => s_RD0_EX,
      i_D1  => s_ALUResult_MEM,
      i_D2  => s_ALUResult_WB,
      i_D3  => s_ALUResult_WB,
      o_O   => s_ALU_A
    );

  mux_alu_a : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcA_EX,
             i_D0 => s_ALU_A,
             i_D1 => (s_PC_EX or x"00400000"),
             i_D2 => x"00000000",
             i_D3 => x"00000000",
             o_O  => s_ALU_A_EX);

  s_ImmU_EX(31 downto 12) <= s_Imm_EX(19 downto 0);
  s_ImmU_EX(11 downto 0) <= (others => '0');

  mux_alu_b_fw : mux4t1_N
    generic map(N => N)
    port map(
      i_S   => c_Fwd_Rd2_from_wb & c_Fwd_Rd2_from_mem,
      i_D0  => s_RD1_EX,
      i_D1  => s_RegWrData_MEM,
      i_D2  => s_ALUResult_WB,
      i_D3  => s_ALUResult_WB,
      o_O   => s_ALU_B
    );

  mux_alu_b : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcB_EX,
             i_D0 => s_ALU_B,
             i_D1 => s_Imm_EX,
             i_D2 => x"00000004",
             i_D3 => s_ImmU_EX,
             o_O  => s_ALU_B_EX);

  alu_inst : alu
    generic map(DATA_WIDTH => N)
    port map(i_A      => s_ALU_A_EX,
             i_B      => s_ALU_B_EX,
             i_ALUCtrl  => c_ALUCtrl_EX,
             o_ALUResult  => s_ALUResult_EX,
            --  o_Zero    => s_ALUZero);
             o_Zero    => open);
  oALUOut <= s_ALUResult_EX;

  EX_MEM : reg_EX_MEM
    generic map(N => DATA_WIDTH)
    port map(
      i_Clk   =>  iClk,
      i_Rst   =>  iRst,
      i_LD    =>  '1',
      i_PC    =>  s_PC_EX, o_PC    =>  s_PC_Mem,
      i_Inst => s_Inst_EX, o_Inst => s_Inst_MEM,
      i_DMemData  => s_DMemData_EX, o_DMemData => s_DMemData_MEM,
      i_DMemWr => s_DMemWr_EX, o_DMemWr => s_DMemWr_MEM,
      i_ALUResult => s_ALUResult_EX, o_ALUResult => s_ALUResult_MEM,
      -- i_LoadData  => s_LoadData_EX, o_LoadData  => s_LoadData_MEM,
      i_RegWr => c_RegWr_EX, o_RegWr => c_RegWr_MEM,
      i_MemToReg => c_MemToReg_EX, o_MemToReg => c_MemToReg_MEM,
      i_Halt => c_Halt_EX, o_Halt => c_Halt_MEM
    );

  forwarding_unit : FU
    generic map(DATA_WIDTH => N)
    port map(
      i_inst_ex     => s_Inst_EX,
      i_inst_mem    => s_Inst_MEM,
      i_inst_wb     => s_Inst_WB,
      o_fw_dmemdata => c_FW_DMemData,
      o_Fwd_Rd1_from_mem  => c_Fwd_Rd1_from_mem,
      o_Fwd_Rd1_from_wb   => c_Fwd_Rd1_from_wb,
      o_Fwd_Rd2_from_mem  => c_Fwd_Rd2_from_mem,
      o_Fwd_Rd2_from_wb   => c_Fwd_Rd2_from_wb
    );


  -------------------------------
  --  MEMORY
  -------------------------------

  dmem_forward_mux : mux2t1_N
    generic map(N => N)
    port map(
      i_S  => c_FW_DMemData,
      i_D0 => s_DMemData_MEM,
      i_D1 => s_RegWrData_WB,
      -- i_D1 => s_ALUResult_WB,
      o_O  => s_DMemData
    );

  DMem : mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2), -- Address pulled from instruction in memory cycle
             data => s_DMemData,  -- Data pulled from instruction in decode cycle
             we   => s_DMemWr_MEM,    -- Write pulled from instruction in decode cycle
             q    => s_DMemOut);

  mem_ext_inst : mem_ext
    generic map(DATA_WIDTH => N)
    port map(
      i_MemData => s_DMemOut,
      i_func3   => s_Inst_MEM(14 downto 12),
      i_ALUResult => s_ALUResult_MEM,
      o_ExtData  => s_LoadData_MEM
    );

  reg_data_mux : mux2t1_N
    generic map(N => N)
    port map(
      i_S  => c_MemToReg_MEM,
      i_D0 => s_ALUResult_MEM,
      i_D1 => s_LoadData_MEM,
      o_O  => s_RegWrData_MEM
    );

  MEM_WB : reg_MEM_WB
    generic map(N   => DATA_WIDTH)
    port map(
      i_Clk   =>  iClk,
      i_Rst   =>  iRst,
      i_LD    =>  '1',
      -- i_PC    =>  s_PC_MEM,             o_PC    => s_PC_WB,
      i_Inst  =>  s_Inst_MEM,           o_Inst  => s_Inst_WB,
      i_DMemData  => s_DMemData_MEM, o_DMemData => s_DMemData_WB,
      i_DMemWr => s_DMemWr_MEM, o_DMemWr => s_DMemWr_WB,
      i_ALUResult =>  s_ALUResult_MEM,  o_ALUResult =>  s_ALUResult_WB,
      -- i_LoadData  =>  s_LoadData_MEM,   o_LoadData  =>  s_LoadData_WB,
      -- i_MemToReg  =>  c_MemToReg_MEM,   o_MemToReg  =>  c_MemToReg_WB,
      i_RegWr => c_RegWr_MEM, o_RegWr => c_RegWr_WB,
      i_RegWrData =>  s_RegWrData_MEM,  o_RegWrData =>  s_RegWrData_WB,
      i_Halt => c_Halt_MEM,             o_Halt => c_Halt_WB
    );

  s_DMemWr <= s_DMemWr_MEM;
  s_DMemAddr <= s_ALUResult_MEM;


  -------------------------------
  --  WRITEBACK
  -------------------------------

  s_RegWrData <= s_RegWrData_WB;
  s_Halt <= c_Halt_WB;

end structure;

