-------------------------------------------------------------------------
-- David Amezcua Santiago
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_controlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file implements a test bench for the control logic system
-- 03/10/2026 by DS::Design created.
-- 03/11/2026 by CC::JAL Test cases corrected.
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_controlLogic is
end tb_controlLogic;

architecture structural of tb_controlLogic is

    component controlLogic is
        port (
            imem : in std_logic_vector(31 downto 0);
            branch : out std_logic;
            aluSrc : out std_logic;
            memToReg : out std_logic;
            memWrite : out std_logic;
            regWrite : out std_logic
        );
    end component;

signal tb_imem : std_logic_vector(31 downto 0);
signal tb_branch : std_logic;
signal tb_aluSrc : std_logic;
signal tb_memToReg : std_logic;
signal tb_memWrite : std_logic;
signal tb_regWrite : std_logic;


begin

    DUT: controlLogic
        port map (
            imem => tb_imem,
            branch => tb_branch,
            aluSrc => tb_aluSrc,
            memToReg => tb_memToReg,
            memWrite => tb_memWrite,
            regWrite => tb_regWrite
        );


stim_process : process
begin

    tb_imem <= x"00000033"; -- R (0110011)
    wait for 20 ns;

    tb_imem <= x"00000013"; -- I (0010011)
    wait for 20 ns;
    tb_imem <= x"00000023"; -- S (0100011)

    tb_imem <= x"00000063"; -- SB (1100011)
    wait for 20 ns;

    tb_imem <= x"0000006F"; -- JAL (1101111)
    wait for 20 ns;

    wait;
end process;
end structural;