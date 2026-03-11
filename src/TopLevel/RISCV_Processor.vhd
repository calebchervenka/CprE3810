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

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated

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

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  -- Signals
  signal s_ALU_a : std_logic_vector(N-1 downto 0);
  signal s_ALU_b : std_logic_vector(N-1 downto 0);
  signal s_ALU_Result : std_logic_vector(N-1 downto 0);

  signal s_Rs1Data : std_logic_vector(N-1 downto 0);
  signal s_Rs2Data : std_logic_vector(N-1 downto 0);
  signal s_Rs1Addr : std_logic_vector(4 downto 0);
  signal s_Rs2Addr : std_logic_vector(4 downto 0);

  signal s_ImmExt : std_logic_vector(N-1 downto 0); -- TODO: This should be the sign-extended immediate value extracted from the instruction

  -- Control Signals
  signal s_Branch : std_logic; -- TODO: This control signal should be high when the instruction is a branch instruction and the branch condition is met (e.g., for BEQ, when Rs1Data = Rs2Data)
  signal s_ALUSrc : std_logic;
  signal s_MemToReg : std_logic;
  signal s_ALUCtrl  : std_logic_vector(4-1 downto 0);


  -- Components
  component fetch_logic is
    port(
      i_imm    : in std_logic_vector(31 downto 0);
      i_Branch : in std_logic;
      i_Clk    : in std_logic;
      i_WE     : in std_logic;
      i_Rst    : in std_logic;
      i_PC     : in std_logic_vector(31 downto 0);
      o_PC     : out std_logic_vector(31 downto 0)
    );
  end component;

  component ALU is
    port(
      i_a : in std_logic_vector(31 downto 0);
      i_b : in std_logic_vector(31 downto 0);
      i_ALUCtrl : in std_logic_vector(3 downto 0);
      o_result : out std_logic_vector(31 downto 0)
    );
  end component;

  component reg_file is
    port(
      i_Clk : in std_logic;
      i_Rst : in std_logic;
      i_RegWr : in std_logic;
      i_Rs1Addr : in std_logic_vector(4 downto 0);
      i_Rs2Addr : in std_logic_vector(4 downto 0);
      i_RdAddr : in std_logic_vector(4 downto 0);
      i_RdData : in std_logic_vector(31 downto 0);
      o_Rs1Data : out std_logic_vector(31 downto 0);
      o_Rs2Data : out std_logic_vector(31 downto 0)
    );
  end component;

  component imm_gen is
    port(
        i_instr : in std_logic_vector(31 downto 0);
        o_imm   : out std_logic_vector(31 downto 0)
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

  component controlLogic is
    port (
        imem : in std_logic_vector(31 downto 0); -- input for Imem
        --aluCtrl : out std_logic_vector(2 downto 0); -- output for ALUCtrl | IMPLEMENTED AS A SEPARATE COMPONENT
        branch : out std_logic; -- output for Branch
        aluSrc : out std_logic; -- output for ALUSrc
        memToReg : out std_logic; -- output for MemToReg
        memWrite : out std_logic; -- output for MemWrite
        regWrite : out std_logic; -- output for RegWrite
        halt    : out std_logic
    );
  end component;

  component ALUcontrol is
    port(
        instruction: in std_logic_vector(31 downto 0); -- 32 bit instruction input
        aluCtrl : out std_logic_vector(3 downto 0) -- 4 bit ALU control output
    );
  end component;

begin
  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)

  -- TODO: Implement the rest of your processor below this comment! 

  -- Mux for s_RegWrData to select between ALU result and memory (for MemToReg signal)
  mux_reg_file_data : mux2t1_N
  generic map(N => 32)
  port map(
    i_S   => s_MemToReg,
    i_D0  => s_ALU_Result,
    i_D1  => s_DMemOut,
    o_O   => s_RegWrData
  );

  regfile : reg_file
  port map(
    i_Clk => iCLK,
    i_Rst => iRST,
    i_RegWr => s_RegWr,
    i_Rs1Addr => s_Rs1Addr,
    i_Rs2Addr => s_Rs2Addr,
    i_RdAddr => s_RegWrAddr,
    i_RdData => s_RegWrData,
    o_Rs1Data => s_Rs1Data,
    o_Rs2Data => s_Rs2Data
  );
  s_DMemData <= s_Rs2Data;
  s_ALU_a <= s_Rs1Data;

  -- Mux for s_ALU_b to select between register data and immediate value (for I-type instructions)
  mux_alu_b : mux2t1_N
  generic map(N => 32)
  port map(
    i_S => s_ALUSrc,
    i_D0 => s_Rs2Data,
    i_D1 => s_ImmExt,
    o_O => s_ALU_b
  );

  -- ALU instance
  arithmetic_logic_unit : ALU
  port map(
    i_a => s_ALU_a,
    i_b => s_ALU_b,
    i_ALUCtrl => s_ALUCtrl,
    o_result => s_ALU_Result
  );
  oALUOut <= s_ALU_Result; -- Connect ALU result to output port
  s_DMemAddr <= s_ALU_Result;

  -- Fetch Logic
  fetch_logic_inst : fetch_logic
  port map(
    i_imm => s_ImmExt,
    i_Branch => s_Branch,
    i_Clk => iCLK,
    i_WE => '1', -- Always enable writing to the PC register
    i_Rst => iRST,
    i_PC => s_IMemAddr,
    o_PC => s_PC
  );

  -- Get Rs1, Rs2, and Rd addresses from instruction
  s_Rs1Addr <= s_Inst(19 downto 15);
  s_Rs2Addr <= s_Inst(24 downto 20);
  s_RegWrAddr <= s_Inst(11 downto 7);


  -- Immediate Generator
  imm_gen_inst : imm_gen
  port map(
    i_instr => s_Inst,
    o_imm => s_ImmExt
  );


  
  control_unit : controlLogic
  port map(
    imem      => s_Inst,
    branch    => s_Branch,
    aluSrc    => s_ALUSrc,
    memToReg  => s_MemToReg,
    memWrite  => s_DMemWr,
    regWrite  => s_RegWr,
    halt      => s_halt
  );

  alu_control_unit : ALUControl
  port map(
    instruction => s_Inst,
    aluCtrl     => s_ALUCtrl
  );

  -- 4. Implement logic to handle branches and jumps

end structure;

