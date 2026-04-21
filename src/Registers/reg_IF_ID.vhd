library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity reg_IF_ID is
    generic (N : integer := DATA_WIDTH);
    port(i_CLK      : in std_logic; -- clock
         i_RST      : in std_logic; -- reset 
         i_LD       : in std_logic; -- load

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

begin
    reg_PC : reg_N
    generic map(
        N => N
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_PC,
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
        i_D     => i_Inst,
        o_Q     => o_Inst
    );

end structure;