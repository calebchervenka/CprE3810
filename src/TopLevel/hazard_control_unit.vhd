library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_control_unit is
    generic(DATA_WIDTH : integer);
    port(
        i_CLK : in std_logic;
        i_RST : in std_logic;
        i_Inst_ID : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_Inst_EX : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_Inst_MEM : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_Inst_WB : in std_logic_vector(DATA_WIDTH-1 downto 0);
        o_PC_WE : out std_logic;
        o_IF_ID_WE : out std_logic;
        o_ID_EX_WE : out std_logic;
        o_EX_MEM_WE : out std_logic;
        o_MEM_WB_WE : out std_logic;
        o_IF_ID_Rst : out std_logic;
        o_ID_EX_Rst : out std_logic;
        o_EX_MEM_Rst : out std_logic;
        o_MEM_WB_Rst : out std_logic;
        i_reg_write_enable_EX : in std_logic;
        i_mem_to_reg_EX : in std_logic
    );
end hazard_control_unit;

architecture structure of hazard_control_unit is
    signal s_load_use_hazard : std_logic;

    signal s_rs1_ID : std_logic_vector(4 downto 0);
    signal s_rs2_ID : std_logic_vector(4 downto 0);
    signal s_rd_EX : std_logic_vector(4 downto 0);


begin
    s_rs1_ID <= i_Inst_ID(19 downto 15);
    s_rs2_ID <= i_Inst_ID(24 downto 20);
    s_rd_EX <= i_Inst_WB(11 downto 7);

    s_load_use_hazard <= '1' when 
        (i_reg_write_enable_EX = '1') and 
        (i_mem_to_reg_EX = '1') and -- It's a LOAD
        ((s_rs1_ID = s_rd_EX) or (s_rs2_ID = s_rd_EX)) 
    else '0';

    o_PC_WE <= '0' when 
        s_load_use_hazard = '1' 
    else '1';

    o_IF_ID_WE <= '0' when
        s_load_use_hazard = '1'
    else '1';

    o_ID_EX_WE <= '1';
    o_EX_MEM_WE <= '1';
    o_MEM_WB_WE <= '1';

    o_IF_ID_Rst <= i_RST;
    o_ID_EX_Rst <= '1' when
        s_load_use_hazard = '1'
    else i_RST;
    o_EX_MEM_Rst <= i_RST;
    o_MEM_WB_Rst <= i_RST;

end structure;