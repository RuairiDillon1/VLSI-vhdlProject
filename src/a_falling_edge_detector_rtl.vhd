-------------------------------------------------------------------------------
-- Module     : rtl
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: detects a falling edge of input signal x_i
--              and produces a high-active signal for one clock period at
--              output fall_o
--              clk_i  __|--|__|--|__|--|__|--|__|--|__|--|__|--|__|--|__|--|
--                x_i  -----|___________________________________|-----------
--              fall_o ________|-----|______________________________________
--
--              rtl model based on two flip flops with output logic
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ARCHITECTURE rtl OF falling_edge_detector IS

  SIGNAL q0, q1 : std_ulogic;           -- D-Type Flip-Flop outputs
  
BEGIN

  dflipflop_0 : q0 <= '0' WHEN (rst_ni = '0') ELSE
                      x_i WHEN rising_edge(clk_i);
  
  dflipflop_1 : q1 <= '0' WHEN (rst_ni = '0') ELSE
                      q0 WHEN rising_edge(clk_i);
  
  output_logic : fall_o <= NOT q0 AND q1;

END rtl;

-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------

