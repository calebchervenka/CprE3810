library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.RISCV_types.all;

entity ALU is
    generic(DATA_WIDTH : integer := 32);
    port(i_A : in std_logic_vector(DATA_WIDTH-1 downto 0);
         i_B : in std_logic_vector(DATA_WIDTH-1 downto 0);
         i_ALUCtrl : in std_logic_vector(ALU_CTRL_WIDTH-1 downto 0);
         o_ALUResult : out std_logic_vector(DATA_WIDTH-1 downto 0);
         o_Zero : out std_logic
    );
end ALU;

architecture structural of ALU is
    component ripple_adder is
        generic(N : integer);
        port(i_A    : in std_logic_vector(N-1 downto 0);
             i_B    : in std_logic_vector(N-1 downto 0);
             i_Cin  : in std_logic;
             o_Sum  : out std_logic_vector(N-1 downto 0);
             o_Cout : out std_logic 
        );
    end component;

    component one_comp is
        generic(N : integer);
        port(i_D    : in std_logic_vector(N-1 downto 0);
             i_O    : out std_logic_vector(N-1 downto 0));
    end component;

    component barrel_shifter_left is
        Port (i_D       : in  std_logic_vector(31 downto 0);
              i_shift   : in  std_logic_vector(4 downto 0);
              o_Q       : out std_logic_vector(31 downto 0));
    end component;

    component barrel_shifter_right is
        Port (i_D           : in  std_logic_vector(31 downto 0);
              i_shift       : in  std_logic_vector(4 downto 0);
              i_signed      : in  std_logic;
              o_Q           : out std_logic_vector(31 downto 0));
    end component;

    component mux16t1_N is
        generic(N : integer);
        port(i_S    : in std_logic_vector(4-1 downto 0);
             i_D0   : in std_logic_vector(N-1 downto 0);
             i_D1   : in std_logic_vector(N-1 downto 0);
             i_D2   : in std_logic_vector(N-1 downto 0);
             i_D3   : in std_logic_vector(N-1 downto 0);
             i_D4   : in std_logic_vector(N-1 downto 0);
             i_D5   : in std_logic_vector(N-1 downto 0);
             i_D6   : in std_logic_vector(N-1 downto 0);
             i_D7   : in std_logic_vector(N-1 downto 0);
             i_D8   : in std_logic_vector(N-1 downto 0);
             i_D9   : in std_logic_vector(N-1 downto 0);
             i_D10  : in std_logic_vector(N-1 downto 0);
             i_D11  : in std_logic_vector(N-1 downto 0);
             i_D12  : in std_logic_vector(N-1 downto 0);
             i_D13  : in std_logic_vector(N-1 downto 0);
             i_D14  : in std_logic_vector(N-1 downto 0);
             i_D15  : in std_logic_vector(N-1 downto 0);
             o_O    : out std_logic_vector(N-1 downto 0));
    end component;

    signal s_add      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_sub      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_sll      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_and      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_or       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_xor      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_ui       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_slt      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_slt_cout : std_logic; -- slt carry out (important for sltiu)
    signal s_sltiu    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_srl      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_sra      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_eq       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_neq      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_ge       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_geu      : std_logic_vector(DATA_WIDTH-1 downto 0);



begin

    --------------------------------
    --     Component Operations
    --------------------------------
    adder : ripple_adder
        generic map(N => DATA_WIDTH)
        port map(i_A    => i_A,
                 i_B    => i_B,
                 i_Cin  => '0',
                 o_Sum  => s_add,
                 o_Cout => open);
    
    subtract : ripple_adder
        generic map(N => DATA_WIDTH)
        port map(i_A    => i_A,
                 i_B    => not i_B,
                 i_Cin  => '1',
                 o_Sum  => s_sub,
                 o_Cout => s_slt_cout); -- open -> s_slt_cout

    shift_left : barrel_shifter_left
        port map(i_D        => i_A,
                 i_Shift    => i_B(4 downto 0),
                 o_Q        => s_sll);
    
    shift_right_l : barrel_shifter_right
        port map(i_D        => i_A,
                 i_Shift    => i_B(4 downto 0),
                 i_signed   => '0',
                 o_Q        => s_srl);

    shift_right_a : barrel_shifter_right
        port map(i_D        => i_A,
                 i_Shift    => i_B(4 downto 0),
                 i_signed   => '1',
                 o_Q        => s_sra);
            

    --------------------------------
    --     Logical Operations
    --------------------------------
    s_and   <= i_A and  i_B;
    s_or    <= i_A or   i_B;
    s_xor   <= i_A xor  i_B;

    s_ui(31 downto 12)     <= i_B(31 downto 12);
    s_ui(11 downto 0)      <= (others => '0');

    s_eq    <= x"00000001" when i_A = i_B else x"00000000";
    s_neq   <= x"00000000" when i_A = i_B else x"00000001";

    -- essentially checking the 4 conditions of binary subtraction
    -- this will tell us if the rs1 < rs2 is a negative which tells is it is less

    -- signed logic
    s_slt <= x"0000000" & "000" & '1' when (i_A(31) = '1' and i_B(31) = '0') else -- - < +
             x"0000000" & "000" & '0' when (i_A(31) = '0' and i_B(31) = '1') else -- + < -
             x"0000000" & "000" &  s_sub(31);                                     -- same signs (+ < +, - < -)

    -- unsigned logic using carry outs
    s_sltiu <= x"0000000" & "000" & (not s_slt_cout); -- A < B, when carryout is 0

    -- greater than or equal
    s_ge <= x"0000000" & "000" & (not s_slt(0));
    s_geu <= x"0000000" & "000" & (not s_sltiu(0));
    
    
    ------------------------------
    --    Output Selection
    ------------------------------
    final_out : mux16t1_N
        generic map(N => DATA_WIDTH)
        port map(i_S    => i_ALUCtrl,
                 i_D0   => s_add, -- ADD, ADDI, LW, LB, LH, LBU, LHU, SW, JAL, AUIPC
                 i_D1   => s_sub, -- Subtract
                 i_D2   => s_sll, -- Shift left
                 i_D3   => s_and,
                 i_D4   => s_or,
                 i_D5   => s_xor,
                 i_D6   => s_ui,
                 i_D7   => s_srl, -- Shift right (logical)
                 i_D8   => s_sra, -- Shift right (arithmetic)
                 i_D9   => s_slt, -- SLT, SLTI
                 i_D10  => s_sltiu,
                 i_D11  => s_eq,
                 i_D12  => s_neq,
                 i_D13  => s_ge,
                 i_D14  => s_geu,
                 i_D15  => (others => '0'),
                 o_O    => o_ALUResult);
                 
    o_Zero <= '1' when o_ALUResult = x"00000000" else '0';
end structural;