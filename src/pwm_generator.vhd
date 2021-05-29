-- Leo Hillinger and Ruairí Dillon 28/05/2021

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;




ENTITY pwm_generator IS

  PORT(
    en_pi     : IN  std_ulogic;         -- enable pin
    rst_ni    : IN  std_ulogic;         -- reset
    pwm_width_i : IN  std_ulogic_vector(7 DOWNTO 0);  -- size of the pwm total signal 
    clk_i     : IN  std_ulogic;         -- clock in
    pwm_o     : OUT std_ulogic);         -- output signal from module

END pwm_generator;

SIGNAL next_state, current_state : unsigned(7 DOWNTO 0);  -- states

CONSTANT max_value : unsigned(7 DOWNTO 0) := to_unsigned(255, max_value'length);

ARCHITECTURE rtl OF pwm_generator IS

  next_state_logic : next_state <= max_value WHEN current_state = 0 ELSE
                                   current_state - 1;

  state_register : current_state <= zero WHEN rst_ni = '0' ELSE
                                    next_state WHEN rising_edge(clk_i) AND (en_pi = '1');


  counter_output : pwm_o <= '1' WHEN current_state < unsigned(pwm_width_i) ELSE
                            '0';

END rtl;
