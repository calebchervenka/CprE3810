library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity reg_EX_MEM is
    generic( N : integer := 32);
    port(i_CLK : in std_logic;
         i_RST : in std_logic;
         i_LD  : in std_logic;

         i_PC : in std_logic_vector(N-1 downto 0); -- PC input
         i_ALU_B : in std_logic_vector(N-1 downto 0); -- ALU B input for store instructions
         i_ALUResult : in std_logic_vector(N-1 downto 0); -- ALU result input
         i_rd : in std_logic_vector(4 downto 0); -- register destination input for write back

         -- Control signal inputs
         i_MemWrite : in std_logic; -- control signal input for memory write
         i_RegWrite : in std_logic; -- control signal input for register write
         i_MemToReg : in std_logic; -- contorl signal input for memory to register

         o_PC : out std_logic_vector(N-1 downto 0);
         o_ALU_B : out std_logic_vector(N-1 downto 0);
         o_ALUResult : out std_logic_vector(N-1 downto 0);

         -- Control signal outputs
         o_MemWrite : out std_logic;
         o_RegWrite : out std_logic; 
         o_MemToReg : out std_logic;
         o_rd : out std_logic_vector(4 downto 0)

        );
end reg_EX_MEM;

architecture structure of reg_EX_MEM is
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
    reg_PC : reg_N -- PC register
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_PC,
        o_Q     => o_PC
    );

    reg_ALU_B : reg_N -- ALU B register
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALU_B,
        o_Q     => o_ALU_B
    );

    reg_ALUResult : reg_N -- ALU result register
    generic map(
        N => 32
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_ALUResult,
        o_Q     => o_ALUResult
    );

    reg_rd : reg_N -- rd register
    generic map(
        N => 5
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D     => i_rd,
        o_Q     => o_rd
    );

    reg_MemWrite : reg_N -- MemWrite register
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)     => i_MemWrite, -- supposedly have to aggregate the 1 bit control signal into a vector to use the reg_N component
        o_Q(0)     => o_MemWrite
    );

    reg_RegWrite : reg_N -- RegWrite register
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)     => i_RegWrite,
        o_Q(0)     => o_RegWrite
    );

    reg_MemToReg : reg_N -- MemToReg register
    generic map(
        N => 1
    )
    port map(
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        i_WE    => '1',
        i_D(0)     => i_MemToReg,
        o_Q(0)     => o_MemToReg
    );

end structure;
