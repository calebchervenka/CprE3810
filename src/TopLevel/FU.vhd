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

begin
    s_opcode_EX <= i_inst_EX(6 downto 0);
    s_opcode_MEM <= i_inst_MEM(6 downto 0);
    s_opcode_WB  <= i_inst_WB(6 downto 0);

    s_rs1_EX <= i_inst_EX(19 downto 15);
    s_rs2_EX <= i_inst_EX(24 downto 20);
    s_rs2_MEM <= i_inst_MEM(24 downto 20);
    s_rd_MEM <= i_inst_MEM(11 downto 7);
    s_rd_WB <= i_inst_WB(11 downto 7);

    o_FW_DMemData <= '1' when (s_opcode_WB(4 downto 0) = "10011") and (s_rs2_MEM = s_rd_WB) else '0';

    o_Fwd_Rd1_from_mem <= '1' when
        ((s_rs1_EX = s_rd_MEM) and 
        not (s_rd_MEM = "00000"))
    else '0';

    o_Fwd_Rd1_from_wb <= '1' when
        ((s_rs1_EX = s_rd_WB) and 
        not (s_rd_WB = "00000"))
    else '0';

    o_Fwd_Rd2_from_mem <= '1' when 
        (s_rs2_EX = s_rd_MEM) and
        not (s_rd_MEM = "00000")
    else '0';

    o_Fwd_Rd2_from_wb <= '1' when
        ((s_rs2_EX = s_rd_WB) and 
        not (s_rd_WB = "00000"))
    else '0';
    

end structure;