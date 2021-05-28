-------------------------------------------------------------------------------
-- Module     : de1_serial_rx
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: Test environment of 'serial_rx' on DE1 Prototype Board
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY de1_serial_rx IS
  PORT (
    CLOCK_50 : IN std_ulogic;           -- 50 MHz Clock

    KEY : IN std_ulogic_vector(1 DOWNTO 0);  -- KEY[0] = rst_ni
                                             -- KEY[1] = ext_trig

    UART_RXD : IN std_ulogic;           -- UART_RXD = rxd_i

    LEDR  : OUT std_ulogic_vector(9 DOWNTO 0);  -- LEDR[7:0] = pattern_o
    LEDG  : OUT std_ulogic_vector(7 DOWNTO 0);  -- LEDG[7:0] = regfile_o
    HEX0  : OUT std_ulogic_vector(6 DOWNTO 0);
    HEX1  : OUT std_ulogic_vector(6 DOWNTO 0);
    HEX2  : OUT std_ulogic_vector(6 DOWNTO 0);
    HEX3  : OUT std_ulogic_vector(6 DOWNTO 0);
    GPO_1 : OUT std_ulogic_vector(5 DOWNTO 0)   -- Output Connector GPO_1
                                                -- GPO_1[0] = clk_i
                                                -- GPO_1[1] = en_oversample_i
                                                -- GPO_1[2] = rxd_i
                                                -- GPO_1[3] = rxd_rdy_o
                                                -- GPO_1[4] = frame_err_o 
                                                -- GPO_1[5] = parity_err_o
    );
END de1_serial_rx;

ARCHITECTURE structure OF de1_serial_rx IS

  SIGNAL clk_i  : std_ulogic;
  SIGNAL rst_ni : std_ulogic;

  SIGNAL sync_reg : std_ulogic_vector(1 DOWNTO 0);

  SIGNAL en_oversample : std_ulogic;
  SIGNAL serial_data   : std_ulogic;
  SIGNAL rxd           : std_ulogic;
  SIGNAL rx_data       : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL rx_data_vld   : std_ulogic;
  SIGNAL rxd_rdy       : std_ulogic;
  SIGNAL parity_err    : std_ulogic;
  SIGNAL frame_err     : std_ulogic;

  SIGNAL data_reg : std_ulogic_vector(7 DOWNTO 0);

BEGIN

  -- connecting clock generator master clock of synchronous system
  clk_i <= CLOCK_50;

  -- connecting asynchronous system reset to digital system
  rst_ni <= KEY(0);

  -----------------------------------------------------------------------------
  -- Synchroniser: UART_RXD input from 9-pin D-SUB connector
  -----------------------------------------------------------------------------
  synchroniser_reg : sync_reg <= (OTHERS => '0') WHEN rst_ni = '0' ELSE
                                 UART_RXD & sync_reg(1) WHEN rising_edge(clk_i);
  synchroniser_out : serial_data <= sync_reg(0);
  -----------------------------------------------------------------------------


  -- -------------------------------------------------------------------------
  --  Device Under Test: Serial Receiver
  -- -------------------------------------------------------------------------
  DUT : ENTITY work.serial_rx
    GENERIC MAP (
      CLK_DIV_VAL => 16,
      PARITY_BIT  => "none")
    PORT MAP (
      CLK          => clk_i,
      RST          => NOT rst_ni,
      UART_CLK_EN  => en_oversample,
      UART_RXD     => serial_data,
      DOUT         => rx_data,
      DOUT_VLD     => rx_data_vld,
      FRAME_ERROR  => frame_err,
      PARITY_ERROR => parity_err);



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
      tc_o    => en_oversample);

  -----------------------------------------------------------------------------
  -- intermediate storage of data
  -----------------------------------------------------------------------------
  dataregister : data_reg <= (OTHERS => '0') WHEN rst_ni = '0' ELSE
                             rx_data WHEN rising_edge(clk_i) AND rx_data_vld = '1';
  -----------------------------------------------------------------------------

  data_register_lownibble : ENTITY work.binto7segment
    PORT MAP (
      bin_i      => data_reg(3 DOWNTO 0),
      segments_o => HEX0);
  data_register_highnibble : ENTITY work.binto7segment
    PORT MAP (
      bin_i      => data_reg(7 DOWNTO 4),
      segments_o => HEX1);

  HEX2 <= (OTHERS => '1');
  HEX3 <= (OTHERS => '1');

  -----------------------------------------------------------------------------
  -- debugging
  -----------------------------------------------------------------------------
  -- clk_i routed to output port
  GPO_1(0) <= clk_i;

  -- baud rate oversampling
  GPO_1(1) <= en_oversample;

  -- serial data input connected to GPIO
  GPO_1(2) <= serial_data;

  -- finished transfer cyle
  GPO_1(3) <= rxd_rdy;

  -- frame error
  GPO_1(4) <= frame_err;

  -- parity error
  GPO_1(5) <= parity_err;

END structure;
-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------

