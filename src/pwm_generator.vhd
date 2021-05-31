-- Leo Hillinger and Ruairí Dillon 28/05/2021

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pwm_generator IS

  PORT(
    en_pi     : IN  std_ulogic;         -- enable pin
    rst_ni    : IN  std_ulogic;         -- reset
    pwm_period_i : IN std_ulogic_vector(7 downto 0);
    pwm_width_i : IN  std_ulogic_vector(7 DOWNTO 0);  -- size of the pwm total signal 
    clk_i     : IN  std_ulogic;         -- clock in
    pwm_o     : OUT std_ulogic);         -- output signal from module

END pwm_generator;

ARCHITECTURE rtl OF pwm_generator IS

SIGNAL next_state, current_state : unsigned(7 DOWNTO 0);  -- states

BEGIN 

  next_state_logic : next_state <= unsigned(pwm_period_i) WHEN current_state = 0 ELSE
                                   current_state - 1;

  state_register : current_state <= (others => '0') WHEN rst_ni = '0' ELSE
                                    next_state WHEN rising_edge(clk_i) AND (en_pi = '1');


  counter_output : pwm_o <= '1' WHEN current_state < unsigned(pwm_width_i) ELSE
                            '0';

END rtl;
