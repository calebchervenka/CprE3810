library IEEE;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ext is
    generic(DATA_WIDTH : integer);
    port(
        i_MemData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_func3   : in std_logic_vector(3-1 downto 0);
        i_ALUResult : in std_logic_vector(DATA_WIDTH-1 downto 0);
        o_ExtData  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end mem_ext;

architecture structural of mem_ext is
    component mux4t1_N is
        generic(N : integer);
        port(
            i_S   : in std_logic_vector(2-1 downto 0);
            i_D0  : in std_logic_vector(N-1 downto 0);
            i_D1  : in std_logic_vector(N-1 downto 0);
            i_D2  : in std_logic_vector(N-1 downto 0);
            i_D3  : in std_logic_vector(N-1 downto 0);
            o_O   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component mux2t1_N is
        generic(N : integer);
        port(
            i_S   : in std_logic;
            i_D0  : in std_logic_vector(N-1 downto 0);
            i_D1  : in std_logic_vector(N-1 downto 0);
            o_O   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal DMemSelectedByte : std_logic_vector(7 downto 0);
    signal DMemSelectedHalfWord : std_logic_vector(15 downto 0);
    signal s_DMemLBExtended, s_DMemLHExtended, s_DMEMLBUExtended, s_DMEMLHUExtended : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_adjusted : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
    ---------------------------------------
    -- MUXES FOR OUTPUT
    ---------------------------------------
    mux_adj : mux4t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S     => i_func3(2) & i_func3(0),
            i_D0    => s_DMemLBExtended,
            i_D1    => s_DMemLHExtended,
            i_D2    => s_DMEMLBUExtended,
            i_D3    => s_DMEMLHUExtended,
            o_O     => s_adjusted
        );
    
    mux_out : mux2t1_N
        generic map(N => DATA_WIDTH)
        port map(
            i_S  => i_func3(1),
            i_D0 => s_adjusted,
            i_D1 => i_MemData,
            o_O  => o_ExtData
        );

    --------------------------------------
    -- BYTE SELECTORS
    --------------------------------------
    mux_byte : mux4t1_N
        generic map(N => 8)
        port map(
            i_S => i_ALUResult(1 downto 0),
            i_D0 => i_MemData(7 downto 0),
            i_D1 => i_MemData(15 downto 8),
            i_D2 => i_MemData(23 downto 16),
            i_D3 => i_MemData(31 downto 24),
            o_O => DMemSelectedByte
        );
    
    mux_halfword : mux2t1_N
        generic map(N => 16)
        port map(
            i_S => i_ALUResult(1),
            i_D0 => i_MemData(15 downto 0),
            i_D1 => i_MemData(31 downto 16),
            o_O => DMemSelectedHalfWord
        );

    ----------------------------------
    --    EXTENDERS
    ----------------------------------
    s_DMemLBExtended(7 downto 0) <= DmemSelectedByte; -- assigns selected byte to the least significant byte
    s_DMemLBExtended(31 downto 8) <= (others => DMemSelectedByte(7)); -- sign extend the byte for lb instruction

    s_DMemLHExtended(15 downto 0) <= DmemSelectedHalfWord; -- assigns selected half-word to the least significant half-word
    s_DMemLHExtended(31 downto 16) <= (others => DMemSelectedHalfWord(15)); -- sign extend the half-word for lh instruction

    s_DMEMLBUExtended(7 downto 0) <= DmemSelectedByte; -- assigns selected byte to the least significant byte
    s_DMEMLBUExtended(31 downto 8) <= (others => '0'); -- zero extend the byte for lbu instruction

    s_DMEMLHUExtended(15 downto 0) <= DmemSelectedHalfWord; -- assigns selected half-word to the least significant half-word
    s_DMEMLHUExtended(31 downto 16) <= (others => '0'); -- zero extend the half-word for lhu instruction

end structural;