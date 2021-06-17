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
    en_tsg_pi       : IN  std_ulogic; -- tsg enable, used with external time base
    en_serial_i     : IN  std_ulogic; -- enable for serial data: oversample of 16 with expected baudrate 9600
    serial_data_i   : IN  std_ulogic; -- serial data with baudrate 9600
    rxd_rdy_o       : OUT std_ulogic; -- debugging signal, output of serial_rx if serial data is ready to be read
    ext_trig_i      : IN  std_ulogic; -- external trigger for triggering test equipment
    pwm_o           : OUT std_ulogic; -- pulse width modulated signal
    noise_o         : OUT std_ulogic; -- 1 bit pseudo random noise
    prbs_o          : OUT std_ulogic_vector(22 DOWNTO 0);  -- pseudo random noise up to 23 bit
    eoc_o           : OUT std_ulogic; -- end of cycle when pseudo random noise repeats
    pattern_o       : OUT std_ulogic_vector(7 DOWNTO 0); -- configurable changing pattern output
    pattern_valid_o : OUT std_ulogic; -- pattern valid, not currently implemented! (see improvements)
    tc_pm_count_o   : OUT std_ulogic; -- debugging signal, end of cycle for pattern memory upcounter
    regfile_o       : OUT std_ulogic_vector(7 DOWNTO 0); -- debugging signal, data input of register file
    addr_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0); -- debugging signal, address output of serial_receiver registers
    data_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0) -- debugging signal, data output of serial_receiver registers
    );
END tsg;

-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------
