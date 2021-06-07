-------------------------------------------------------------------------------
-- Module     : t_pwm_generator
-------------------------------------------------------------------------------
-- Author     :   David.Cunningham@HS-Augsburg.DE
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2011   <haf@fh-augsburg.de>
-------------------------------------------------------------------------------
-- Description:Testbench for mini porject "Test Signal Generator(pwm generator)"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-------------------------------------------------------------------------------

ENTITY t_pwm_generator IS
END t_pwm_generator;

-------------------------------------------------------------------------------
ARCHITECTURE tbench OF t_pwm_generator IS

  COMPONENT pwm_generator IS
    PORT (
      en_pi       : IN  std_ulogic;
      rst_ni      : IN  std_ulogic;
      pwm_width_i : IN  std_ulogic_vector(7 DOWNTO 0);
      clk_i       : IN  std_ulogic;
      pwm_o       : OUT std_ulogic);
  END COMPONENT pwm_generator;

  COMPONENT freq_control IS
    PORT (
      clk_i    : IN  std_ulogic;
      rst_ni   : IN  std_ulogic;
      en_pi    : IN  std_ulogic;
      count_o  : OUT std_ulogic_vector(7 DOWNTO 0);
      freq_o   : OUT std_ulogic;
      period_i : IN  std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT freq_control;

  -- definition of a clock period
  CONSTANT period : time    := 20 ns;   --50Mhz
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

  -- component ports
  SIGNAL en_pi        : std_ulogic;
  SIGNAL rst_ni       : std_ulogic;
  SIGNAL pwm_period_i : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL pwm_width_i  : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL clk_i        : std_ulogic;
  SIGNAL pwm_o        : std_ulogic;
  SIGNAL freq_div : std_ulogic;

BEGIN  --tbench
  -- component instantiation
  pwm_gen : pwm_generator
    PORT MAP (
      en_pi       => freq_div,
      rst_ni      => rst_ni,
      pwm_width_i => pwm_width_i,
      clk_i       => clk_i,
      pwm_o       => pwm_o);

  freq_controller : freq_control
    PORT MAP (
      clk_i    => clk_i,
      rst_ni   => rst_ni,
      en_pi    => en_pi,
      count_o  => OPEN,
      freq_o   => freq_div,
      period_i => pwm_period_i);

  -- clock generation
  clock_p : PROCESS
  BEGIN
    WHILE clken_p LOOP
      clk_i <= '0'; WAIT FOR period/2;
      clk_i <= '1'; WAIT FOR period/2;
    END LOOP;
    WAIT;
  END PROCESS;

  -- initial reset, always necessary at the beginning of a simulation
  -----------------------------------------------------------------------------
  -- Following a verification plan:
  -- ------------------------------
  -- 1. t = 0 ns: activate asynchronous reset
  -- 2. t = 20 ns: deactivate asynchronous reset
  -----------------------------------------------------------------------------
  reset : rst_ni <= '0', '1' AFTER period;

  stimuli_p : PROCESS

  BEGIN
    en_pi <= '1';
    pwm_period_i <= "00000001";
    pwm_width_i <= "00000001";
    WAIT UNTIL rst_ni = '1';

    WAIT until rising_edge(pwm_o);
    WAIT FOR period;
    
    pwm_period_i <= "00001000";
    pwm_width_i <= "00000010";
    WAIT until rising_edge(pwm_o);
    WAIT FOR 10*period;

    
    clken_p <= false;                   -- switch clock generator off

    WAIT;
  END PROCESS;

END;
