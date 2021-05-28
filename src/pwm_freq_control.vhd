-- THIS IS A DIRECT COPY OF PWM_GENERATOR NEEDS EDITIED 
-- Leo Hillinger and Ruairí Dillon 28/05/2021

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




entity pwm_generator is

	port(

	en_pi : in std_ulogic; -- enable pin
	rst_ni : in std_ulogic; -- reset
	pwm_period : in std_ulogic_vector(7 downto 0); -- size of the pwm total signal 
	clk_i : in std_ulogic;	-- clock in
	pwm_freq_o : out std_ulogic; -- output signal from module
	);

end pwm_generator;

	signal next_state, current_state : unsigned(7 downto 0); -- states


architecture rtl of pwm_generator is

next_state_logic : next_state <= to_unsigned(255, 8) WHEN current_state = 0 ELSE
                                   current_state - 1;

  state_register : current_state <= zero WHEN rst_ni = '0' ELSE
    next_state WHEN rising_edge(clk_i) AND (en_pi = '1');


  counter_output : pwm_freq_o <= '1' when current_state < to_unsigned(255, 8) - unsigned(pwm_period) else
				'0';

end rtl;
