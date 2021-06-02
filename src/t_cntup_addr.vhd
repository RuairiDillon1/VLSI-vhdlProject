-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   Leo Hillinger
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   Leo Hillinger
-------------------------------------------------------------------------------
-- Description: Testbench for design "cntup_addr"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_cntup_addr IS

END ENTITY t_cntup_addr;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_cntup_addr IS

  COMPONENT cntup_addr IS
    PORT (
      clk_i : in std_ulogic;
      clr_i : in std_ulogic; -- synchronous clear
      rst_ni : in std_ulogic; -- asynchronous reset
      en_pi : in std_ulogic;
      len_i : in std_ulogic_vector(7 downto 0);
      q_o : out std_ulogic_vector(7 downto 0);
      tc_o : out std_ulogic); -- one at end of cycle 
  END COMPONENT cntup_addr;

  -- component ports
  SIGNAL clk_i : std_ulogic;
  SIGNAL clr_i : std_ulogic;
  SIGNAL rst_ni : std_ulogic;
  SIGNAL en_pi : std_ulogic;
  SIGNAL len_i : std_ulogic_vector(7 downto 0);
  SIGNAL q_o   : std_ulogic_vector(7 downto 0);
  SIGNAL tc_o  : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: cntup_addr
    PORT MAP (
      clk_i => clk_i,
      clr_i => clr_i,
      en_pi => en_pi,
      rst_ni => rst_ni,
      len_i => len_i,
      q_o   => q_o,
      tc_o  => tc_o);

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
  
  len_i <= "00001000";
  en_pi <= '1';
  clr_i <= '0';
  WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
                                       -- ... is deactivated

  WAIT FOR 10*period;
  clr_i <= '1';
  WAIT FOR 1*period;
  clr_i <= '0';
  WAIT FOR 10*period;
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
