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
        i_rs1_EX        : in std_logic_vector(4 downto 0);
        i_rs2_EX        : in std_logic_vector(4 downto 0);
        i_rs2_MEM       : in std_logic_vector(4 downto 0);
        i_rd_MEM        : in std_logic_vector(4 downto 0);
        i_rd_WB         : in std_logic_vector(4 downto 0);
        o_FW_DMemData   : out std_logic;
        o_FW_RegData1   : out std_logic;
        o_FW_RegData2   : out std_logic
    );
end FU;

architecture structure of FU is
    signal s_opcode_EX  : std_logic_vector(6 downto 0);
    signal s_opcode_MEM : std_logic_vector(6 downto 0);
    signal s_opcode_WB  : std_logic_vector(6 downto 0);
begin
    s_opcode_EX <= i_inst_EX(6 downto 0);
    s_opcode_MEM <= i_inst_MEM(6 downto 0);
    s_opcode_WB  <= i_inst_WB(6 downto 0);

    -- Protects against add/addi immediately before lw
    o_FW_DMemData <= '1' when (s_opcode_MEM = "0100011") and (s_opcode_WB(4 downto 0) = "10011") and (i_rs2_MEM = i_rd_WB) else '0';


    -- Protects against add/addi immediately before R-type instruction
    o_FW_RegData1 <= '0';
    -- o_FW_RegData1 <= '1' when 
    --     (s_opcode_EX(4 downto 0) = "10011") and 
    --     (s_opcode_MEM(4 downto 0) = "10011") and 
    --     (i_rs1_EX = i_rd_MEM) and
    --     not (i_rd_MEM = "00000")
    -- else '0';

    o_FW_RegData2 <= '0';
    -- o_FW_RegData2 <= '1' when 
    --     (s_opcode_EX(4 downto 0) = "10011") and 
    --     (s_opcode_MEM(4 downto 0) = "10011") and 
    --     (i_rs2_EX = i_rd_MEM) and
    --     not (i_rd_MEM = "00000")
    -- else '0';

end structure;