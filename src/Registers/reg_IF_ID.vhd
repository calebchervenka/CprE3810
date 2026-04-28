-- library IEEE;
-- use IEEE.std_logic_1164.all;

-- library work;
-- use work.RISCV_types.all;

-- entity reg_IF_ID is
--     generic (N : integer := DATA_WIDTH);
--     port(i_CLK      : in std_logic; -- clock
--          i_RST      : in std_logic; -- reset 
--          i_LD       : in std_logic; -- load
--          i_stall    : in std_logic; -- stall
--          i_flush    : in std_logic; -- flush

--          i_PC       : in std_logic_vector(N-1 downto 0); -- PC input
--          o_PC       : out std_logic_vector(N-1 downto 0); -- output for PC
--          i_Inst     : in std_logic_vector(N-1 downto 0); -- instruction memory input
--          o_Inst     : out std_logic_vector(N-1 downto 0) -- output for instruction memory
--          );
-- end reg_IF_ID;

-- architecture structure of reg_IF_ID is
--     ---------------------------
--     --      Components
--     ---------------------------
--     component reg_N is
--         generic(N : integer);
--         port(
--             i_CLK   : in std_logic; -- Clock input
--             i_RST   : in std_logic; -- Reset input
--             i_WE    : in std_logic; -- Write enable input
--             i_D     : in std_logic_vector(N-1 downto 0); -- Data value input
--             o_Q     : out std_logic_vector(N-1 downto 0) -- Data value output
--         );
--     end component;

--     component andg2 is
--         port (
--             i_A : in std_logic;
--             i_B : in std_logic;
--             o_F : out std_logic
--         );
--     end component;

--     component orgate2 is
--         port (
--             i_A : in std_logic;
--             i_B : in std_logic;
--             o_F : out std_logic
--         );
--     end component;

--     component invg is
--         port (
--             i_A : in std_logic;
--             o_F : out std_logic
--         );
--     end component;


--     ------------
--     -- Signals
--     ------------
--     signal s_WE        : std_logic; -- write enable
--     signal s_RST       : std_logic; -- reset signal
--     signal s_not_stall : std_logic; -- inverted stall



-- begin

--     ------------------------------------
--     -- Logic for Stalling and Flushing
--     ------------------------------------

--     not_stall : invg
--     port map(
--         i_A => i_stall,
--         o_F => s_not_stall
--     );

--     -- STALLING
--     -- if load is enabled AND not stalling, enable write
--     and_gate : andg2
--     port map(
--         i_A => i_LD,
--         i_B => s_not_stall,
--         o_F => s_WE
--     );

--     -- FLUSHING
--     -- if RST OR flush is enabled, reset the pipeline register
--     or_gate : orgate2
--     port map(
--         i_A => i_RST,
--         i_B => i_flush,
--         o_F => s_RST
--     );

--     ---------------------------------
--     -- PC and Instruction Registers
--     ---------------------------------

--         reg_PC : reg_N
--     generic map(
--         N => N
--     )
--     port map(
--         i_Clk   => i_CLK,
--         i_Rst   => s_RST,
--         i_WE    => s_WE,
--         i_D     => i_PC,
--         o_Q     => o_PC
--     );


--     reg_Inst : reg_N
--     generic map(
--         N => N
--     )
--     port map(
--         i_Clk   => i_CLK,
--         i_Rst   => s_RST,
--         i_WE    => s_WE,
--         i_D     => i_Inst,
--         o_Q     => o_Inst
--     );

-- end structure;






--------------------------------
-- OLD WORKING VERSION
--------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity reg_IF_ID is
    generic (N : integer := DATA_WIDTH);
    port(i_CLK      : in std_logic; -- clock
         i_RST      : in std_logic; -- reset 
         i_LD       : in std_logic; -- load
         i_stall    : in std_logic; -- stall
         i_flush    : in std_logic; -- flush

         i_PC       : in std_logic_vector(N-1 downto 0); -- PC input
         o_PC       : out std_logic_vector(N-1 downto 0); -- output for PC
         i_Inst     : in std_logic_vector(N-1 downto 0); -- instruction memory input
         o_Inst     : out std_logic_vector(N-1 downto 0) -- output for instruction memory
         );
end reg_IF_ID;

architecture structure of reg_IF_ID is
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
    signal s_Inst_stall       : std_logic_vector(N-1 downto 0); -- output of stall mux, input to flush mux
    signal s_Inst_stall_final : std_logic_vector(N-1 downto 0); -- output of flush mux
    signal s_PC_stall         : std_logic_vector(N-1 downto 0);
    signal s_PC_stall_final   : std_logic_vector(N-1 downto 0);


begin

    ----------------------------------------------
    -- Instruction Logic for Stalling and Flushing
    ----------------------------------------------

    --stall : 1 = keep previous instruction, stall : 0 = load new instruction
    mux_stall: mux2t1_N 
    generic map( 
        N => N
    )
    port map( 
        i_S => i_stall,
        i_D0 => i_Inst, -- new instruction
        i_D1 => o_Inst, -- instruction from previous cycle
        o_O => s_Inst_stall -- output to instruction register
    );
    
    -- flush : 1 = insert NOP, flush : 0 = keep instruction from stall mux
    mux_flush: mux2t1_N
    generic map(
        N => N
    )
    port map( 
        i_S => i_flush,
        i_D0 => s_Inst_stall, -- instruction from stall mux
        i_D1 => (others => '0'), -- NOP instruction
        o_O => s_Inst_stall_final -- output to instruction register
    );

    -------------------------------------
    -- PC Logic for Stalling and Flushing
    -------------------------------------

    mux_stall_PC: mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_stall,
        i_D0 => i_PC,
        i_D1 => o_PC, -- PC from previous cycle
        o_O => s_PC_stall
    );

    mux_flush_PC: mux2t1_N
    generic map(
        N => N
    )
    port map(
        i_S => i_flush,
        i_D0 => s_PC_stall,
        i_D1 => (others => '0'),
        o_O => s_PC_stall_final
    );

    ---------------------------------
    -- PC and Instruction Registers
    ---------------------------------

        reg_PC : reg_N
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

end structure;





