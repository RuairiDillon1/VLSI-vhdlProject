-------------------------------------------------------------------------------
-- Module     : 
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "tsg"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

-------------------------------------------------------------------------------

ENTITY t_tsg IS

END ENTITY t_tsg;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_tsg IS

  COMPONENT tsg IS
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
      prbs_o          : OUT std_ulogic_vector(22 DOWNTO 0);
      eoc_o           : OUT std_ulogic;
      pattern_o       : OUT std_ulogic_vector(7 DOWNTO 0);
      pattern_valid_o : OUT std_ulogic;
      tc_pm_count_o   : OUT std_ulogic;
      regfile_o       : OUT std_ulogic_vector(7 DOWNTO 0);
      addr_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0);
      data_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT tsg;

  -- component ports
  SIGNAL clk_i           : std_ulogic;
  SIGNAL rst_ni          : std_ulogic;
  SIGNAL en_tsg_pi       : std_ulogic;
  SIGNAL en_serial_i     : std_ulogic;
  SIGNAL serial_data_i   : std_ulogic;
  SIGNAL rxd_rdy_o       : std_ulogic;
  SIGNAL ext_trig_i      : std_ulogic;
  SIGNAL pwm_o           : std_ulogic;
  SIGNAL noise_o         : std_ulogic;
  SIGNAL prbs_o          : std_ulogic_vector(22 DOWNTO 0);
  SIGNAL eoc_o           : std_ulogic;
  SIGNAL pattern_o       : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL pattern_valid_o : std_ulogic;
  SIGNAL tc_pm_count_o   : std_ulogic;
  SIGNAL regfile_o       : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL addr_reg_o      : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL data_reg_o      : std_ulogic_vector(7 DOWNTO 0);

  signal      DIN    : std_ulogic_vector(7 DOWNTO 0);
  signal    DIN_VLD   : std_ulogic;
  signal    DIN_RDY   : std_ulogic;

  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

  -- inspired by: https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html
  -- PROCEDURE sent_serial
  --   (CONSTANT data_i : IN std_ulogic_vector(7 DOWNTO 0);
  --    SIGNAL serial_o : OUT std_ulogic) IS -- integer because input is hex
  --   constant baud : time := 1041166 ns; -- baudrate 9600
  -- BEGIN

  --   -- startbit
  --   serial_o <= '0';
  --   WAIT FOR baud;

  --   FOR idx IN 0 TO 7 LOOP
  --     serial_o <= data_i(idx);
  --     WAIT FOR baud;
  --   END loop;

  --   -- stopbit
  --   serial_o <= '1';
  --   WAIT FOR baud;
    
  -- END sent_serial;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  DUT: tsg
    PORT MAP (
      clk_i           => clk_i,
      rst_ni          => rst_ni,
      en_tsg_pi       => en_tsg_pi,
      en_serial_i     => en_serial_i,
      serial_data_i   => serial_data_i,
      rxd_rdy_o       => rxd_rdy_o,
      ext_trig_i      => ext_trig_i,
      pwm_o           => pwm_o,
      noise_o         => noise_o,
      prbs_o          => prbs_o,
      eoc_o           => eoc_o,
      pattern_o       => pattern_o,
      pattern_valid_o => pattern_valid_o,
      tc_pm_count_o   => tc_pm_count_o,
      regfile_o       => regfile_o,
      addr_reg_o      => addr_reg_o,
      data_reg_o      => data_reg_o);

  -- -------------------------------------------------------------------------
  --  Oversampling Generator(~16X)
  -- -------------------------------------------------------------------------
  baud_oversample_en : ENTITY work.cntdnmodm(rtl)
    GENERIC MAP (                       -- clk = 50 MHz
      n => 9,                           -- Baud rate = 9600, Oversampling 16x
      m => 326)                         -- m = 326, n = 9
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => '1',
      count_o => OPEN,
      tc_o    => en_serial_i);

  base_time : ENTITY work.cntdnmodm(rtl)
    GENERIC MAP (                       -- clk = 50 MHz
      n => 4,                           -- 10 MHz
      m => 5)                        
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => '1',
      count_o => OPEN,
      tc_o    => en_tsg_pi);

    -- -------------------------------------------------------------------------
  --  Serial Transmitter
  -- -------------------------------------------------------------------------
  serial_transmitter : ENTITY work.UART_TX 
    GENERIC MAP (
      CLK_DIV_VAL => 16,
      PARITY_BIT  => "none")
    PORT MAP (
      CLK         => clk_i,
      RST         => NOT rst_ni,
      UART_CLK_EN => en_serial_i,
      UART_TXD    => serial_data_i,
      DIN         => DIN,
      DIN_VLD     => DIN_VLD,
      DIN_RDY     => DIN_RDY); 

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
  ext_trig_i <= '0';
  WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
                                       -- ... is deactivated

  -- system enable
  DIN     <= X"01";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"01";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  -- noise
  -- --  noise period
  -- DIN     <= X"09";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"01";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;

  -- -- noise prbs length
  -- DIN     <= X"08";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"00"; 4bit
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;

  -- -- noise control
  -- DIN     <= X"0b";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"01"; -- 01 intern trig 03 ext trig
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- WAIT FOR 40*period;

  -- -- noise prbs length
  -- DIN     <= X"08";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"01"; 7 bit
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- WAIT FOR 40*period;

  
  -- ext_trig_i <= '1';
  -- WAIT FOR period;
  -- ext_trig_i <= '0';
  -- WAIT FOR 10*period;
  -- ext_trig_i <= '1';
  -- WAIT FOR period;
  -- ext_trig_i <= '0';
  -- WAIT FOR 10*period;

  -- pattern
 -- pattern period 
  DIN     <= X"0e";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"06";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  -- pattern length
  DIN     <= X"0c";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"03";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  -- pattern load
  DIN     <= X"0f";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"03";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  -- patterns
  DIN     <= X"02";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"08";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"04";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  -- pattern continous run
  DIN     <= X"0f";
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;
  DIN     <= X"06"; -- 06 continous run with ext trigger, 02 contionus run, 01
                    -- single run, 05 single run ext trigger
  DIN_VLD <= '1';
  WAIT FOR period;
  DIN_VLD <= '0';
  WAIT UNTIL rising_edge(DIN_RDY);
  WAIT UNTIL falling_edge(rxd_rdy_o);
  WAIT FOR 2*period;

  WAIT FOR 30*period;
  
  ext_trig_i <= '1';
  WAIT FOR period;
  ext_trig_i <= '0';
  WAIT FOR 10*period;
  ext_trig_i <= '1';
  WAIT FOR period;
  ext_trig_i <= '0';
  WAIT FOR 10*period;

  -- -- pwm
  -- pwm period
  -- DIN     <= X"05";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"01";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;

  -- -- pwm width
  -- DIN     <= X"04";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"01";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;

  -- -- pwm enable
  -- DIN     <= X"06";
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;
  -- DIN     <= X"03"; -- 3 ext trigger and enable, 1 only enable
  -- DIN_VLD <= '1';
  -- WAIT FOR period;
  -- DIN_VLD <= '0';
  -- WAIT UNTIL rising_edge(DIN_RDY);
  -- WAIT UNTIL falling_edge(rxd_rdy_o);
  -- WAIT FOR 2*period;

  --  WAIT FOR 10*period;

  -- ext_trig_i <= '1';
  -- WAIT FOR period;
  -- ext_trig_i <= '0';
  -- WAIT FOR 10*period;
  -- ext_trig_i <= '1';
  -- WAIT FOR period;
  -- ext_trig_i <= '0';
  -- WAIT FOR 10*period;


  
  
  clken_p <= false;                   -- switch clock generator off
  
  WAIT;
END PROCESS;

  

END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
