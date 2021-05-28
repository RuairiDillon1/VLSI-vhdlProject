-------------------------------------------------------------------------------
-- Module     : tsg
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: Test Signal Generator
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY tsg IS
  PORT (
    clk_i           : IN  std_ulogic;
    rst_ni          : IN  std_ulogic;
    en_tsg_pi       : IN  std_ulogic;
    en_serial_i     : IN  std_ulogic;
    serial_data_i   : IN  std_ulogic;
    rxd_rdy_o       : OUT std_ulogic;
    ext_trig_i      : IN  std_ulogic;
    pwm_o           : OUT std_ulogic;
    noise_o         : OUT std_ulogic;
    prbs_o          : OUT std_ulogic_vector(23 DOWNTO 0);  -- parallel random word
    eoc_o           : OUT std_ulogic;
    pattern_o       : OUT std_ulogic_vector(7 DOWNTO 0);
    pattern_valid_o : OUT std_ulogic;
    tc_pm_count_o   : OUT std_ulogic;
    regfile_o       : OUT std_ulogic_vector(7 DOWNTO 0);
    addr_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0);
    data_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0)
    );
END tsg;

-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------
