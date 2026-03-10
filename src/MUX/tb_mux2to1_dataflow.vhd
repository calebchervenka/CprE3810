-------------------------------------------------------------------------
-- Caleb Chervenka
-- Computer Engineering Undergraduate
-- Iowa State University
-------------------------------------------------------------------------


-- tb_mux2t1_dataflow.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2:1 MUX with a dataflow architecture.

-- 01/28/2026 by CC::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux2t1_df is
end tb_mux2t1_df;

architecture mixed of tb_mux2t1_df is
    component mux2t1_df is
        port(
            i_S     :   in std_logic;
            i_D0    :   in std_logic;
            i_D1    :   in std_logic;
            o_O     :   out std_logic);
    end component;

    signal s_iS     :   std_logic;
    signal s_iD0     :   std_logic;
    signal s_iD1     :   std_logic;
    signal s_oO     :   std_logic;

begin
    MUX2TO1: mux2t1_df
    port map(
        i_S     =>  s_iS,
        i_D0    =>  s_iD0,
        i_D1    =>  s_iD1,
        o_O     =>  s_oO);

    p_tb: process
    begin
        s_iS     <=  '0';
        s_iD0    <=  '0';
        s_iD1    <=  '0';
        wait for 1 ns;

        s_iS     <=  '1';
        s_iD0    <=  '0';
        s_iD1    <=  '0';
        wait for 1 ns;

        s_iS     <=  '0';
        s_iD0    <=  '0';
        s_iD1    <=  '1';
        wait for 1 ns;

        s_iS     <=  '1';
        s_iD0    <=  '0';
        s_iD1    <=  '1';
        wait for 1 ns;

        s_iS     <=  '0';
        s_iD0    <=  '1';
        s_iD1    <=  '0';
        wait for 1 ns;

        s_iS     <=  '1';
        s_iD0    <=  '1';
        s_iD1    <=  '0';
        wait for 1 ns;

        s_iS     <=  '0';
        s_iD0    <=  '1';
        s_iD1    <=  '1';
        wait for 1 ns;

        s_iS     <=  '1';
        s_iD0    <=  '1';
        s_iD1    <=  '1';
        wait for 1 ns;
    end process;
end mixed;
