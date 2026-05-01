library IEEE;
use IEEE.std_logic_1164.all;

entity FU is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        i_inst_EX       : in std_logic_vector(31 downto 0);
        i_inst_MEM      : in std_logic_vector(31 downto 0);
        i_inst_WB       : in std_logic_vector(31 downto 0);

        o_FW_DMemData       : out std_logic;
        o_Fwd_Rd1_from_mem  : out std_logic;
        o_Fwd_Rd1_from_wb   : out std_logic;
        o_Fwd_Rd2_from_mem  : out std_logic;
        o_Fwd_Rd2_from_wb   : out std_logic
    );
end FU;

architecture structure of FU is
    signal s_opcode_EX  : std_logic_vector(6 downto 0);
    signal s_opcode_MEM : std_logic_vector(6 downto 0);
    signal s_opcode_WB  : std_logic_vector(6 downto 0);

    signal s_rs1_EX     : std_logic_vector(4 downto 0);
    signal s_rs2_EX     : std_logic_vector(4 downto 0);
    signal s_rs2_MEM    : std_logic_vector(4 downto 0);
    signal s_rd_MEM     : std_logic_vector(4 downto 0);
    signal s_rd_WB      : std_logic_vector(4 downto 0);
    signal s_RegWr_MEM  : std_logic;
    signal s_RegWr_WB   : std_logic;

begin
    s_opcode_EX <= i_inst_EX(6 downto 0);
    s_opcode_MEM <= i_inst_MEM(6 downto 0);
    s_opcode_WB  <= i_inst_WB(6 downto 0);

    s_rs1_EX <= i_inst_EX(19 downto 15);
    s_rs2_EX <= i_inst_EX(24 downto 20);
    s_rs2_MEM <= i_inst_MEM(24 downto 20);
    s_rd_MEM <= i_inst_MEM(11 downto 7);
    s_rd_WB <= i_inst_WB(11 downto 7);

    s_RegWr_MEM <= '1' when
        (s_opcode_MEM = "0110011") or  -- R-type ALU
        (s_opcode_MEM = "0010011") or  -- I-type ALU
        (s_opcode_MEM = "0000011") or  -- load
        (s_opcode_MEM = "1101111") or  -- jal
        (s_opcode_MEM = "1100111") or  -- jalr
        (s_opcode_MEM = "0110111") or  -- lui
        (s_opcode_MEM = "0010111")     -- auipc
    else '0';

    s_RegWr_WB <= '1' when
        (s_opcode_WB = "0110011") or
        (s_opcode_WB = "0010011") or
        (s_opcode_WB = "0000011") or
        (s_opcode_WB = "1101111") or
        (s_opcode_WB = "1100111") or
        (s_opcode_WB = "0110111") or
        (s_opcode_WB = "0010111")
    else '0';

    o_FW_DMemData <= '1' when
        (s_rs2_MEM = s_rd_WB) and
        not (s_rd_WB = "00000") and
        (s_RegWr_WB = '1')
    else '0';

    o_Fwd_Rd1_from_mem <= '1' when
        ((s_rs1_EX = s_rd_MEM) and 
        not (s_rd_MEM = "00000")) and
        (s_RegWr_MEM = '1')
    else '0';

    o_Fwd_Rd1_from_wb <= '1' when
        ((s_rs1_EX = s_rd_WB) and 
        not (s_rd_WB = "00000")) and
        (s_RegWr_WB = '1') and
        not ((s_rs1_EX = s_rd_MEM) and not (s_rd_MEM = "00000") and (s_RegWr_MEM = '1'))
    else '0';

    o_Fwd_Rd2_from_mem <= '1' when 
        (s_rs2_EX = s_rd_MEM) and
        not (s_rd_MEM = "00000") and
        (s_RegWr_MEM = '1')
    else '0';

    o_Fwd_Rd2_from_wb <= '1' when
        ((s_rs2_EX = s_rd_WB) and 
        not (s_rd_WB = "00000")) and
        (s_RegWr_WB = '1') and
        not ((s_rs2_EX = s_rd_MEM) and not (s_rd_MEM = "00000") and (s_RegWr_MEM = '1'))
    else '0';
    

end structure;
