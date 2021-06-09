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

  COMPONENT pattern_generator_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      tc_pm              : IN  std_ulogic;
      pm_control_changed : IN  std_ulogic;
      pm_control         : IN  std_ulogic_vector(1 DOWNTO 0);
      addr_cnt_enabled: IN std_ulogic;
      en_pm              : OUT std_ulogic;
      en_pm_cnt          : OUT std_ulogic;
      clr_pm_cnt         : OUT std_ulogic;
      pm_checked         : OUT std_ulogic);
  END COMPONENT pattern_generator_fsm;

  COMPONENT pattern_generator IS
    PORT (
      en_pi      : IN  std_ulogic;
      clk_i      : IN  std_ulogic;
      pm_control_i : IN std_ulogic_vector(1 downto 0);
      addr_cnt_i : IN  std_ulogic_vector(7 DOWNTO 0);
      rxd_data_i : IN  std_ulogic_vector(7 DOWNTO 0);
      pattern_o  : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT pattern_generator;

  COMPONENT cntup_addr IS
    PORT (
      clk_i  : IN  std_ulogic;
      clr_i  : IN  std_ulogic;
      rst_ni : IN  std_ulogic;
      en_pi  : IN  std_ulogic;
      len_i  : IN  std_ulogic_vector(7 DOWNTO 0);
      q_o    : OUT std_ulogic_vector(7 DOWNTO 0);
      tc_o   : OUT std_ulogic);
  END COMPONENT cntup_addr;

  COMPONENT cntdnmodm IS
    GENERIC (
      n : natural;
      m : natural);
    PORT (
      clk_i   : IN  std_ulogic;
      rst_ni  : IN  std_ulogic;
      en_pi   : IN  std_ulogic;
      count_o : OUT std_ulogic_vector(n-1 DOWNTO 0);
      tc_o    : OUT std_ulogic);
  END COMPONENT cntdnmodm;

  -- component ports
  SIGNAL en_pi                : std_ulogic;
  SIGNAL rst_ni               : std_ulogic;
  SIGNAL clk_i                : std_ulogic;
  SIGNAL tc_addr_cnt_i        : std_ulogic;
  SIGNAL addr_cnt_i           : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL pattern_control_i    : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL rxd_valid_i          : std_ulogic;
  SIGNAL rxd_data_i           : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL pm_control_changed_i : std_ulogic;
  SIGNAL pm_checked_o         : std_ulogic;
  SIGNAL en_addr_cnt_o        : std_ulogic;
  SIGNAL en_pm_i              : std_ulogic;
  SIGNAL clr_addr_cnt_o       : std_ulogic;
  SIGNAL pattern_o            : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL freq_div_10mhz : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT : pattern_generator
    PORT MAP (
      en_pi      => en_pm_i,
      clk_i      => clk_i,
      pm_control_i => pattern_control_i,
      addr_cnt_i => addr_cnt_i,
      rxd_data_i => rxd_data_i,
      pattern_o  => pattern_o);

  addr_counter : cntup_addr
    PORT MAP (
      clk_i  => clk_i,
      clr_i  => clr_addr_cnt_o,
      rst_ni => rst_ni,
      en_pi  => en_addr_cnt_o AND freq_div_10mhz,
      len_i  => "00000010",             -- sequence of 2 numbers
      q_o    => addr_cnt_i,
      tc_o   => tc_addr_cnt_i);

  state_machine : pattern_generator_fsm
    PORT MAP (
      clk                => clk_i,
      rst_n              => rst_ni,
      rxd_rec            => rxd_valid_i,
      tc_pm              => tc_addr_cnt_i,
      pm_control_changed => pm_control_changed_i,
      pm_control         => pattern_control_i,
      addr_cnt_enabled => en_addr_cnt_o AND freq_div_10mhz,
      en_pm              => en_pm_i,
      en_pm_cnt          => en_addr_cnt_o,
      clr_pm_cnt         => clr_addr_cnt_o,
      pm_checked         => pm_checked_o);

  freq_10mhz: cntdnmodm
    GENERIC MAP (
      n => 4,
      m => 5)
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => en_pi,
      count_o => open,
      tc_o    => freq_div_10mhz);

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

    en_pi                <= '1';
    pm_control_changed_i <= '1';
    rxd_data_i           <= "00000001";
    rxd_valid_i          <= '0';
    pattern_control_i    <= "00";       -- stop
    WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
    -- ... is deactivated
    WAIT UNTIL rising_edge(pm_checked_o);
    pm_control_changed_i <= '0';

    WAIT FOR 2*period;
    pm_control_changed_i <= '1';
    pattern_control_i <= "11"; -- load

    WAIT FOR 5*period;
    rxd_valid_i <= '0', '1' AFTER period;
    rxd_valid_i <= '1', '0' AFTER 2* period;
    rxd_data_i <= "00001000";
    WAIT FOR 5*period;
    rxd_valid_i <= '0', '1' AFTER period;
    rxd_valid_i <= '1', '0' AFTER 2* period;
    rxd_data_i <= "00000100";

    WAIT UNTIL rising_edge(pm_checked_o);
    pm_control_changed_i <= '0';

    WAIT FOR 2*period;
    pm_control_changed_i <= '1';
    pattern_control_i <= "01"; -- single burst
    WAIT FOR period;
    pm_control_changed_i <= '0';
    WAIT FOR 10*period;

    pm_control_changed_i <= '1';
    pattern_control_i <= "10"; -- continous burst
    WAIT FOR 2*period;
    pm_control_changed_i <= '0';
    WAIT FOR 20*period;
    pm_control_changed_i <= '1';
    WAIT FOR 1*period;
    pm_control_changed_i <= '0';
    WAIT FOR 20*period;



    clken_p <= false;                   -- switch clock generator off

    WAIT;
  END PROCESS;



END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
