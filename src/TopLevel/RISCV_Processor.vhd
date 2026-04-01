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
  
  -- Control signals
  signal c_Branch   : std_logic;
  signal c_Branch_Cond : std_logic; -- Branch
  signal c_Jalr     : std_logic; -- JALR
  signal c_ALUSrcA  : std_logic_vector(1 downto 0);
  signal c_ALUSrcB  : std_logic_vector(1 downto 0);
  signal c_MemToReg : std_logic;


  -- Data signals
  signal s_Imm             : std_logic_vector(N-1 downto 0);
  signal s_Reg1Data        : std_logic_vector(N-1 downto 0);
  signal s_Reg2Data        : std_logic_vector(N-1 downto 0);
  signal s_ALU_A           : std_logic_vector(N-1 downto 0);
  signal s_ALU_B           : std_logic_vector(N-1 downto 0);
  signal s_ALUCtrl         : std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
  signal s_ALUResult       : std_logic_vector(N-1 downto 0);
  signal s_ALUZero         : std_logic;
  signal s_LoadData        : std_logic_vector(N-1 downto 0); -- output of load data mux that accounts for lb and lh instructions
  signal s_ldMux1          : std_logic_vector(N-1 downto 0); -- output of mux that selects between lb and lh data based on opcode and func3
  signal s_ldMux2          : std_logic_vector(N-1 downto 0); -- output of mux that selects between lh and lbu
  signal s_ldMux3          : std_logic_vector(N-1 downto 0); -- output of mux that selects lhu
  signal s_PCreg_Select    : std_logic; -- select for beq

  signal s_ImmU            : std_logic_vector(N-1 downto 0); -- Upper Immediate
  signal s_PCJ              : std_logic_vector(N-1 downto 0); -- Program Cursor OR bit 22

  -- PC Branch Target Signals
  signal s_branch_base          : std_logic_vector(N-1 downto 0);
  signal s_branch_raw_target    : std_logic_vector(N-1 downto 0);
  signal s_branch_final_target  : std_logic_vector(N-1 downto 0);


  -- Load Byte Signals
  signal DMemSelectedByte  : std_logic_vector(7 downto 0); -- outputs the selected byte from the data memory output
  signal s_DMemLBExtended  : std_logic_vector(N-1 downto 0); -- outputs the sign extended byte for lb instructino
  signal s_IsLB            : std_logic; -- signal for lb instruction

  signal s_DMEMLBUExtended : std_logic_vector(N-1 downto 0); -- outputs the zero extended byte for lbu instruction
  signal s_IsLBU           : std_logic;

  -- Load Half-Word Signals
  signal DMemSelectedHalfWord : std_logic_vector(15 downto 0); -- outputs the selected half-word from the data memory output
  signal s_DMemLHExtended     : std_logic_vector(N-1 downto 0); -- outputs the sign extended half-word for lh instruction
  signal s_IsLH               : std_logic;

  signal s_DMEMLHUExtended    : std_logic_vector(N-1 downto 0); -- outputs the zero extended half-word for lhu instruction
  signal s_IsLHU              : std_logic;

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
      o_Branch    : out std_logic;
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
      i_Target  : in std_logic_vector(DATA_WIDTH-1 downto 0);
      i_IncOrSet: in std_logic;
      i_WrPc    : in std_logic;
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
  s_PCreg_Select <= (c_Branch or (c_Branch_Cond and s_ALUResult(0)));

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

  immediate_generator : imm_gen
  generic map(DATA_WIDTH => N)
  port map(
    i_Instr   => s_Inst,
    o_Imm     => s_Imm
  );

  mux_branch_base : mux2t1_N
    generic map(N => N)
    port map(
      i_S  => c_Jalr,
      i_D0 => s_PC,
      i_D1 => s_Reg1Data,
      o_O  => s_branch_base
    );

  branch_adder : ripple_adder
    generic map(N => N)
    port map(
      i_A     => s_branch_base,
      i_B     => s_Imm,
      i_Cin   => '0',
      o_Sum   => s_branch_raw_target,
      o_Cout  => open
    );

  s_branch_final_target <= s_branch_raw_target(N-1 downto 1) & '0' when c_Jalr = '1' else s_branch_raw_target;

  PCReg : pc_reg
    generic map(DATA_WIDTH => N)
    port map(
      i_Target      => s_branch_final_target,
      i_IncOrSet    => s_PCreg_Select,
      i_WrPc    => '1',
      i_Rst     => iRst,
      i_Clk     => iClk,
      o_PC      => s_PC);

  reg_data_mux : mux2t1_N
    generic map(N => N)
    port map(i_S  => c_MemToReg,
             i_D0 => s_ALUResult,
             i_D1 => s_LoadData, -- changed s_DMEMOut to s_LoadData to account for lb, lh, lbu, lhu instructions
             o_O  => s_RegWrData);

  s_DMemAddr <= s_ALUResult;
  
  s_RegWrAddr <= s_Inst(11 downto 7);

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


  -- ALU Inputs
  -- s_ALU_A     <= s_Reg1Data;  

  s_PCJ <= (s_PC or x"00400000");

  mux_alu_a : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcA,
             i_D0 => s_Reg1Data,
             i_D1 => s_PCJ,
             i_D2 => x"00000000",
             i_D3 => x"00000000",
             o_O  => s_ALU_A);

  -- mux_alu_b : mux2t1_N
  --   generic map(N => N)
  --   port map(i_S  => c_ALUSrcB,
  --            i_D0 => s_Reg2Data,
  --            i_D1 => s_Imm,
  --            o_O  => s_ALU_B);
  
  s_ImmU(31 downto 12) <= s_Imm(19 downto 0);
  s_ImmU(11 downto 0) <= (others => '0');

  mux_alu_b : mux4t1_N
    generic map(N => N)
    port map(i_S  => c_ALUSrcB,
             i_D0 => s_Reg2Data,
             i_D1 => s_Imm,
             i_D2 => x"00000004",
             i_D3 => s_ImmU,
             o_O  => s_ALU_B);

  alu_control : acu
    generic map(DATA_WIDTH => N)
    port map(i_Inst     => s_Inst,
             o_ALUCtrl  => s_ALUCtrl);

  alu_inst : alu
    generic map(DATA_WIDTH => N)
    port map(i_A      => s_ALU_A,
             i_B      => s_ALU_B,
             i_ALUCtrl  => s_ALUCtrl,
             o_ALUResult  => s_ALUResult,
             o_Zero    => s_ALUZero);
  oALUOut <= s_ALUResult;

  --------------------------------------------------
  -- Load Instruction Handling (LB, LH, LBU, LHU)
  --------------------------------------------------
  
-- chooses LB, LH, LBU, or LHU instruction based on opcode and func3
  s_IsLB <= '1' when s_Inst(6 downto 0) = "0000011" and s_Inst(14 downto 12) = "000" else '0';
  s_IsLH <= '1' when s_Inst(6 downto 0) = "0000011" and s_Inst(14 downto 12) = "001" else '0';
  s_IsLBU <= '1' when s_Inst(6 downto 0) = "0000011" and s_Inst(14 downto 12) = "100" else '0';
  s_IsLHU <= '1' when s_Inst(6 downto 0) = "0000011" and s_Inst(14 downto 12) = "101" else '0';

  -- BYTE SELECTION (lb)
  with s_ALUResult(1 downto 0) select
    DMemSelectedByte <= s_DMemOut(7 downto 0) when "00",   -- byte 0
                        s_DMemOut(15 downto 8) when "01",  -- byte 1
                        s_DMemOut(23 downto 16) when "10", -- byte 2
                        s_DMemOut(31 downto 24) when "11", -- byte 3
                        (others => '0') when others;

  -- HALF-WORD SELECTION (lh)
  with s_ALUResult(1 downto 0) select
    DMemSelectedHalfWord <= s_DMemOut(15 downto 0) when "00",  -- half-word 0
                            s_DMemOut(31 downto 16) when "10", -- half-word 1
                            (others => '0') when others;

  -- SIGN EXTENDERS FOR LB AND LH                          
  s_DMemLBExtended(7 downto 0) <= DmemSelectedByte; -- assigns selected byte to the least significant byte
  s_DMemLBExtended(31 downto 8) <= (others => DMemSelectedByte(7)); -- sign extend the byte for lb instruction

  s_DMemLHExtended(15 downto 0) <= DmemSelectedHalfWord; -- assigns selected half-word to the least significant half-word
  s_DMemLHExtended(31 downto 16) <= (others => DMemSelectedHalfWord(15)); -- sign extend the half-word for lh instruction

  -- ZERO EXTENDERS FOR LBU AND LHU
  s_DMEMLBUExtended(7 downto 0) <= DmemSelectedByte; -- assigns selected byte to the least significant byte
  s_DMEMLBUExtended(31 downto 8) <= (others => '0'); -- zero extend the byte for lbu instruction

  s_DMEMLHUExtended(15 downto 0) <= DmemSelectedHalfWord; -- assigns selected half-word to the least significant half-word
  s_DMEMLHUExtended(31 downto 16) <= (others => '0'); -- zero extend the half-word for lhu instruction

  load_byte_mux : mux2t1_N
    generic map(N => N)
    port map(i_S  => s_IsLB,
             i_D0 => s_DMemOut,
             i_D1 => s_DMemLBExtended,
             o_O  => s_ldMux1); -- output of this mux goes to another mux that selects between lb and lh data based on opcode and func3

  load_halfword_mux : mux2t1_N
    generic map(N => N)
    port map(i_S => s_IsLH,
             i_D0 => s_ldMux1, -- output of lb mux goes to this mux as the input for the case when it's not an lh instruction
             i_D1 => s_DMemLHExtended,
             o_O  => s_ldMux2); -- reusing s_LoadData as the output of this mux since lb and lh are mutually exclusive instructions

  load_lbu_mux : mux2t1_N
    generic map(N => N)
    port map(i_S => s_IsLBU,
             i_D0 => s_ldMux2,
             i_D1 => s_DMEMLBUExtended,
             o_O  => s_ldMux3);
    
  load_lhu_mux : mux2t1_N
    generic map(N => N)
    port map(i_S => s_IsLHU,
             i_D0 => s_ldMux3,
             i_D1 => s_DMEMLHUExtended,
             o_O  => s_LoadData);


  

    
end structure;

