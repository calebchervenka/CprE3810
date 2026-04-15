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
  signal s_PC : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  signal s_Halt         : std_logic;
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated


  -- Instruction Fetch
  signal s_PC_IF        : std_logic_vector(N-1 downto 0);
  signal s_Inst_IF      : std_logic_vector(N-1 downto 0);

  -- Instruction Decode
  signal s_PC_ID        : std_logic_vector(N-1 downto 0);
  signal s_Inst_ID      : std_logic_vector(N-1 downto 0);

  -- Execute
  signal s_Inst_EX      : std_logic_vector(N-1 downto 0);

  -- Memory
  signal s_Inst_MEM     : std_logic_vector(N-1 downto 0);

  -- Writeback
  signal s_Inst_WB      : std_logic_vector(N-1 downto 0);

  
  -- Control signals
  signal c_Branch   : std_logic_vector(1 downto 0);
  signal c_Branch_Cond : std_logic; -- Branch
  signal c_Jalr     : std_logic; -- JALR
  signal c_ALUSrcA  : std_logic_vector(1 downto 0);
  signal c_ALUSrcB  : std_logic_vector(1 downto 0);
  signal c_MemToReg : std_logic;
  signal c_ALUCtrl         : std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);


  -- Data signals
  signal s_Imm             : std_logic_vector(N-1 downto 0);
  signal s_ImmU            : std_logic_vector(N-1 downto 0); -- Upper Immediate
  signal s_Reg1Data        : std_logic_vector(N-1 downto 0);
  signal s_Reg2Data        : std_logic_vector(N-1 downto 0);
  signal s_ALU_A           : std_logic_vector(N-1 downto 0);
  signal s_ALU_B           : std_logic_vector(N-1 downto 0);
  signal s_ALUResult       : std_logic_vector(N-1 downto 0);
  signal s_ALUZero         : std_logic;
  -- signal s_PCJ              : std_logic_vector(N-1 downto 0); -- Program Cursor with bit 22 set
  signal s_LoadData        : std_logic_vector(N-1 downto 0); -- output of load data mux that accounts for lb and lh instructions

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
      o_Branch_Cond   : out std_logic;
      o_ALUSrcA   : out std_logic_vector(1 downto 0);
      o_ALUSrcB   : out std_logic_vector(1 downto 0);
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_RegWrite  : out std_logic;
      o_Jalr      : out std_logic;
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
         i_PC         : in std_logic_vector(N-1 downto 0);
         i_Inst       : in std_logic_vector(N-1 downto 0);
         o_PC         : out std_logic_vector(N-1 downto 0);
         o_Inst       : out std_logic_vector(N-1 downto 0));
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

begin
  s_Ovfl <= '0';

  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;


  -------------------------------
  --  Instruction Fetch
  -------------------------------

  PCReg : pc_reg
    generic map(DATA_WIDTH => N)
    port map(
      i_Branch    => c_Branch,
      i_BranchCondition => s_ALUResult(0),
      i_Imm       => s_Imm,
      i_Reg1Data  => s_Reg1Data,
      i_Rst     => iRst,
      i_Clk     => iClk,
      o_PC      => s_PC);

  IMem : mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  -- IF_ID : reg_IF_ID
  --   generic map(
  --     N   => N
  --   )
  --   port map(
  --     i_Clk   => iClk,
  --     i_Rst   => iRst,
  --     i_Ld    => '1',
  --     i_PC    => s_PC_IF,
  --     i_Inst  => s_Inst_IF,
  --     o_PC    => s_PC_ID,
  --     o_Inst  => s_Inst_ID
  --   );
  

  -------------------------------
  --  Instruction Decode
  -------------------------------

  controls : control_unit
  generic map(DATA_WIDTH => N)
  port map(
    i_Inst  => s_Inst,
    o_Branch  => c_Branch,
    o_Branch_Cond => c_Branch_Cond,
    o_ALUSrcA  => c_ALUSrcA,
    o_ALUSrcB  => c_ALUSrcB,
    o_MemToReg  => c_MemToReg,
    o_MemWrite  => s_DMemWr,
    o_RegWrite  => s_RegWr,
    o_Jalr      => c_Jalr,
    o_Halt      => s_Halt
  );

  alu_control : acu
    generic map(DATA_WIDTH => N)
    port map(i_Inst     => s_Inst,
             o_ALUCtrl  => c_ALUCtrl);

  immediate_generator : imm_gen
    generic map(DATA_WIDTH => N)
    port map(
      i_Instr   => s_Inst,
      o_Imm     => s_Imm
    );

  s_ImmU(31 downto 12) <= s_Imm(19 downto 0);
  s_ImmU(11 downto 0) <= (others => '0');

  register_file : reg_file
    generic map(address_width => REG_ADDR_WIDTH,
                reg_count     => REG_COUNT,
                data_width    => N)
    port map(
        i_WD    => s_RegWrData,
        o_RD0   => s_Reg1Data,
        o_RD1   => s_Reg2Data,
        i_RS0   => s_Inst(19 downto 15),
        i_RS1   => s_Inst(24 downto 20),
        i_RD    => s_RegWrAddr,
        i_CLK   => iClk,
        i_RST   => iRst,
        i_WE    => s_RegWr);
  s_DMemData  <= s_Reg2Data;


  -------------------------------
  --  EXECUTE
  -------------------------------

  -- s_PCJ <= (s_PC or x"00400000");

  mux_alu_a : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcA,
             i_D0 => s_Reg1Data,
             i_D1 => (s_PC or x"00400000"),
             i_D2 => x"00000000",
             i_D3 => x"00000000",
             o_O  => s_ALU_A);

  mux_alu_b : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcB,
             i_D0 => s_Reg2Data,
             i_D1 => s_Imm,
             i_D2 => x"00000004",
             i_D3 => s_ImmU,
             o_O  => s_ALU_B);

  alu_inst : alu
    generic map(DATA_WIDTH => N)
    port map(i_A      => s_ALU_A,
             i_B      => s_ALU_B,
             i_ALUCtrl  => c_ALUCtrl,
             o_ALUResult  => s_ALUResult,
             o_Zero    => s_ALUZero);
  oALUOut <= s_ALUResult;


  -------------------------------
  --  MEMORY
  -------------------------------

  s_DMemAddr <= s_ALUResult;

  DMem : mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  mem_ext_inst : mem_ext
    generic map(DATA_WIDTH => N)
    port map(
      i_MemData => s_DMemOut,
      i_func3   => s_Inst(14 downto 12),
      i_ALUResult => s_ALUResult,
      o_ExtData  => s_LoadData
    );


  -------------------------------
  --  WRITEBACK
  -------------------------------

  reg_data_mux : mux2t1_N
    generic map(N => N)
    port map(i_S  => c_MemToReg,
             i_D0 => s_ALUResult,
             i_D1 => s_LoadData, -- changed s_DMEMOut to s_LoadData to account for lb, lh, lbu, lhu instructions
             o_O  => s_RegWrData);
  
  s_RegWrAddr <= s_Inst(11 downto 7);

end structure;

