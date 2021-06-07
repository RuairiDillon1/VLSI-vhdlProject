-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "pattern_generator"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_pattern_generator IS

END ENTITY t_pattern_generator;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_pattern_generator IS

  COMPONENT pattern_generator IS
    PORT (
      en_pi                : IN  std_ulogic;
      rst_ni               : IN  std_ulogic;
      clk_i                : IN  std_ulogic;
      tc_addr_cnt_i        : IN  std_ulogic;
      addr_cnt_i           : IN  std_ulogic_vector(7 downto 0);
      pattern_length_i     : IN  std_ulogic_vector(7 DOWNTO 0);
      pattern_control_i    : IN  std_ulogic_vector(1 DOWNTO 0);
      rxd_valid_i          : IN  std_ulogic;
      rxd_data_i           : IN  std_ulogic_vector(7 DOWNTO 0);
      pm_control_changed_i : IN  std_ulogic;
      pm_checked_o         : OUT std_ulogic;
      en_addr_cnt_o        : OUT std_ulogic;
      clr_addr_cnt_o       : OUT std_ulogic;
      pattern_o            : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT pattern_generator;

  COMPONENT cntup_addr IS
    PORT (
      clk_i  : in  std_ulogic;
      clr_i  : in  std_ulogic;
      rst_ni : in  std_ulogic;
      en_pi  : in  std_ulogic;
      len_i  : in  std_ulogic_vector(7 downto 0);
      q_o    : out std_ulogic_vector(7 downto 0);
      tc_o   : out std_ulogic);
  END COMPONENT cntup_addr;

  -- component ports
  SIGNAL en_pi                : std_ulogic;
  SIGNAL rst_ni               : std_ulogic;
  SIGNAL clk_i                : std_ulogic;
  SIGNAL tc_addr_cnt_i        : std_ulogic;
  SIGNAL addr_cnt_i           : std_ulogic_vector(7 downto 0);
  SIGNAL pattern_control_i    : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL rxd_valid_i          : std_ulogic;
  SIGNAL rxd_data_i           : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL pm_control_changed_i : std_ulogic;
  SIGNAL pm_checked_o         : std_ulogic;
  SIGNAL en_addr_cnt_o        : std_ulogic;
  SIGNAL clr_addr_cnt_o       : std_ulogic;
  SIGNAL pattern_o            : std_ulogic_vector(7 DOWNTO 0);


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: pattern_generator
    PORT MAP (
      en_pi                => en_pi,
      rst_ni               => rst_ni,
      clk_i                => clk_i,
      tc_addr_cnt_i        => tc_addr_cnt_i,
      addr_cnt_i           => addr_cnt_i,
      pattern_length_i     => "00000100", -- sequence of 4 numbers
      pattern_control_i    => pattern_control_i,
      rxd_valid_i          => rxd_valid_i,
      rxd_data_i           => rxd_data_i,
      pm_control_changed_i => pm_control_changed_i,
      pm_checked_o         => pm_checked_o,
      en_addr_cnt_o        => en_addr_cnt_o,
      clr_addr_cnt_o       => clr_addr_cnt_o,
      pattern_o            => pattern_o);

  addr_counter: cntup_addr
    PORT MAP (
      clk_i  => clk_i,
      clr_i  => clr_addr_cnt_o,
      rst_ni => rst_ni,
      en_pi  => en_addr_cnt_o,
      len_i  => "00000100", -- sequence of 4 numbers
      q_o    => addr_cnt_i,
      tc_o   => tc_addr_cnt_i);

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

  en_pi <= '1';
  pm_control_changed_i <= '1';
  rxd_data_i <= "00000001";
  rxd_valid_i <= '0';
  pattern_control_i <= "00"; -- stop
  WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
                                       -- ... is deactivated
  WAIT FOR 10*period;
  -- WAIT UNTIL rising_edge(pm_checked_o);
  -- pm_control_changed_i <= '0';
  
  -- WAIT FOR 2*period;
  -- pm_control_changed_i <= '1';
  -- pattern_control_i <= "11"; -- load
                       
  -- WAIT FOR 5*period;
  -- rxd_valid_i <='0';
  -- rxd_data_i <= "00001000";
  -- WAIT FOR period;
  -- rxd_valid_i <= '1';

  -- WAIT UNTIL rising_edge(pm_checked_o);
  -- pm_control_changed_i <= '0';

  -- WAIT FOR 2*period;
  -- pm_control_changed_i <= '1';
  -- pattern_control_i <= "01"; -- single burst
  -- WAIT FOR period;
  -- pm_control_changed_i <= '0';
  -- WAIT FOR 10*period;

  -- pm_control_changed_i <= '1';
  -- pattern_control_i <= "10"; -- continous burst
  -- WAIT FOR 2*period;
  -- pm_control_changed_i <= '0';
  -- WAIT FOR 20*period;
  -- pm_control_changed_i <= '1';
  -- WAIT FOR 2*period;
  
  
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
