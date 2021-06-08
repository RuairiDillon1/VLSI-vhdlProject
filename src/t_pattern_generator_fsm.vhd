-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "pattern_generator_fsm"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_pattern_generator_fsm IS

END ENTITY t_pattern_generator_fsm;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_pattern_generator_fsm IS

  COMPONENT pattern_generator_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      tc_pm              : IN  std_ulogic;
      pm_control_changed : IN  std_ulogic;
      pm_control         : IN  std_ulogic_vector(1 DOWNTO 0);
      en_pm              : OUT std_ulogic;
      en_pm_cnt          : OUT std_ulogic;
      clr_pm_cnt         : OUT std_ulogic;
      pm_checked         : OUT std_ulogic);
  END COMPONENT pattern_generator_fsm;

  -- component ports
  SIGNAL clk                : std_ulogic;
  SIGNAL rst_n              : std_ulogic;
  SIGNAL rxd_rec            : std_ulogic;
  SIGNAL tc_pm              : std_ulogic;
  SIGNAL pm_control_changed : std_ulogic;
  SIGNAL pm_control         : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL en_pm              : std_ulogic;
  SIGNAL en_pm_cnt          : std_ulogic;
  SIGNAL clr_pm_cnt         : std_ulogic;
  SIGNAL pm_checked         : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: pattern_generator_fsm
    PORT MAP (
      clk                => clk,
      rst_n              => rst_n,
      rxd_rec            => rxd_rec,
      tc_pm              => tc_pm,
      pm_control_changed => pm_control_changed,
      pm_control         => pm_control,
      en_pm              => en_pm,
      en_pm_cnt          => en_pm_cnt,
      clr_pm_cnt         => clr_pm_cnt,
      pm_checked         => pm_checked);

-- clock generation
clock_p : PROCESS
BEGIN
  WHILE clken_p LOOP
    clk_i <= '0'; WAIT FOR period/2;
    clk_i <= '1'; WAIT FOR period/2;
  END LOOP;
  WAIT;
END PROCESS;
  
-- initial reset, always necessary at the beginning OF a simulation
reset : rst_ni <= '0', '1' AFTER period;

-- process for stimuli generation
stimuli_p : PROCESS
  
  
BEGIN
  
  WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
                                       -- ... is deactivated
  



  -- add your stimuli here ...
  
  
  
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
