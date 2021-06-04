-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   Leo Hillinger
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   Leo Hillinger
-------------------------------------------------------------------------------
-- Description: Testbench for design "noise_generator"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_noise_generator IS

END ENTITY t_noise_generator;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_noise_generator IS

  COMPONENT noise_generator IS
    PORT (
      clk_i                : IN  std_ulogic;
      rst_ni               : IN  std_ulogic;
      en_pi                : IN  std_ulogic;
      noise_prbsg_length_i : IN  std_ulogic_vector(7 DOWNTO 0);
      prbs_o               : OUT std_ulogic_vector(22 DOWNTO 0);
      noise_o              : OUT std_ulogic;
      eoc_o                : OUT std_ulogic);
  END COMPONENT noise_generator;

  -- component ports
  SIGNAL clk_i                : std_ulogic;
  SIGNAL rst_ni               : std_ulogic;
  SIGNAL en_pi                : std_ulogic;
  SIGNAL noise_prbsg_length_i : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL prbs_o               : std_ulogic_vector(22 DOWNTO 0);
  SIGNAL noise_o              : std_ulogic;
  SIGNAL eoc_o                : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: noise_generator
    PORT MAP (
      clk_i                => clk_i,
      rst_ni               => rst_ni,
      en_pi                => en_pi,
      noise_prbsg_length_i => noise_prbsg_length_i,
      prbs_o               => prbs_o,
      noise_o              => noise_o,
      eoc_o                => eoc_o);

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
  en_pi <= '1';
  noise_prbsg_length_i <= (OTHERS => '0');
  WAIT FOR 30*period;



  -- add your stimuli here ...
  
  
  
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
