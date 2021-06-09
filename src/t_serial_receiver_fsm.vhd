-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "serial_receiver_fsm"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_serial_receiver_fsm IS

END ENTITY t_serial_receiver_fsm;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_serial_receiver_fsm IS

  COMPONENT serial_receiver_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      addr               : IN  std_ulogic_vector(3 DOWNTO 0);
      pm_checked         : IN  std_ulogic;
      en_addr_reg        : OUT std_ulogic;
      en_data_reg        : OUT std_ulogic;
      en_regfile_wr      : OUT std_ulogic;
      pm_control_changed : OUT std_ulogic);
  END COMPONENT serial_receiver_fsm;

  -- component ports
  SIGNAL clk                : std_ulogic;
  SIGNAL rst_n              : std_ulogic;
  SIGNAL rxd_rec            : std_ulogic;
  SIGNAL addr               : std_ulogic_vector(3 DOWNTO 0);
  SIGNAL pm_checked         : std_ulogic;
  SIGNAL en_addr_reg        : std_ulogic;
  SIGNAL en_data_reg        : std_ulogic;
  SIGNAL en_regfile_wr      : std_ulogic;
  SIGNAL pm_control_changed : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: serial_receiver_fsm
    PORT MAP (
      clk                => clk,
      rst_n              => rst_n,
      rxd_rec            => rxd_rec,
      addr               => addr,
      pm_checked         => pm_checked,
      en_addr_reg        => en_addr_reg,
      en_data_reg        => en_data_reg,
      en_regfile_wr      => en_regfile_wr,
      pm_control_changed => pm_control_changed);

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
  
  -- test when new data arrives - need signal that data is valid etc (difficult)
  -- two things arrive sequentially, addr and data - which is which


  -- add your stimuli here ...
  
  
  
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
