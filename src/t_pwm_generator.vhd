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

  COMPONENT pwm_generator
    PORT(
    en_pi     : IN  std_ulogic;         -- enable pin
    rst_ni    : IN  std_ulogic;         -- reset
    pwm_period_i : IN std_ulogic_vector(7 downto 0);
    pwm_width_i : IN  std_ulogic_vector(7 DOWNTO 0);  -- size of the pwm total signal 
    clk_i     : IN  std_ulogic;         -- clock in
    pwm_o     : OUT std_ulogic);         -- output signal from module
   END COMPONENT;
 
  -- definition of a clock period
  CONSTANT period : time := 20 ns; --50Mhz
 -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

  -- component ports
  SIGNAL en_pi          : std_ulogic;
  SIGNAL rst_ni         : std_ulogic;
  SIGNAL pwm_period_i   : std_ulogic_vector(7 downto 0);
  SIGNAL pwm_width_i    : std_ulogic_vector(7 downto 0);
  SIGNAL clk_i          : std_ulogic;
  SIGNAL pwm_o          : std_ulogic;

BEGIN --tbench
  -- component instantiation
  MUV : ENTITY work.pwm_generator(rtl)
    PORT Map(
    en_pi         => en_pi 
    rst_ni        => rst_ni  
    pwm_period_i  => pwm_period_i
    pwm_width_i   => pwm_width_i
    clk_i         => clk_i
    pwm_o         => pwm_o
    );
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

END;
