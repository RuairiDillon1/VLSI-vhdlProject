-------------------------------------------------------------------------------
-- Module     : t_serial_rx
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "serial_rx"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------
ENTITY t_serial_rx IS
END ENTITY t_serial_rx;
-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_serial_rx IS

  COMPONENT serial_rx IS
    GENERIC (
      CLK_DIV_VAL : integer;
      PARITY_BIT  : string);
    PORT (
      CLK          : IN  std_ulogic;
      RST          : IN  std_ulogic;
      UART_CLK_EN  : IN  std_ulogic;
      UART_RXD     : IN  std_ulogic;
      DOUT         : OUT std_ulogic_vector(7 DOWNTO 0);
      DOUT_VLD     : OUT std_ulogic;
      FRAME_ERROR  : OUT std_ulogic;
      PARITY_ERROR : OUT std_ulogic);
  END COMPONENT serial_rx;

  -- component generics
  CONSTANT CLK_DIV_VAL : integer := 16;
  CONSTANT PARITY_BIT  : string  := "none";

  -- component ports
  SIGNAL clk_i        : std_ulogic;
  SIGNAL rst_ni       : std_ulogic;
  SIGNAL UART_CLK_EN  : std_ulogic;
  SIGNAL UART_RXD     : std_ulogic;
  SIGNAL DOUT         : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL DOUT_VLD     : std_ulogic;
  SIGNAL FRAME_ERROR  : std_ulogic;
  SIGNAL PARITY_ERROR : std_ulogic;

  SIGNAL UART_TXD : std_ulogic;
  SIGNAL DIN      : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL DIN_VLD  : std_ulogic;
  SIGNAL DIN_RDY  : std_ulogic;

  SIGNAL en_baud : std_ulogic;
  SIGNAL txd_o   : std_ulogic := '1';


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- -------------------------------------------------------------------------
  --  Module Under Test: Serial Receiver
  -- -------------------------------------------------------------------------
  MUT : serial_rx
    GENERIC MAP (
      CLK_DIV_VAL => CLK_DIV_VAL,
      PARITY_BIT  => PARITY_BIT)
    PORT MAP (
      CLK          => clk_i,
      RST          => NOT rst_ni,
      UART_CLK_EN  => UART_CLK_EN,
      UART_RXD     => UART_RXD,
      DOUT         => DOUT,
      DOUT_VLD     => DOUT_VLD,
      FRAME_ERROR  => FRAME_ERROR,
      PARITY_ERROR => PARITY_ERROR);

  -- -------------------------------------------------------------------------
  --  Transfer Channel
  -- -------------------------------------------------------------------------
  serial_transfer_channel : UART_RXD <= UART_TXD;


  -- -------------------------------------------------------------------------
  --  Baud Rate Generator
  -- -------------------------------------------------------------------------
  baud_rate_en : ENTITY work.cntdnmodm(rtl)
    GENERIC MAP (                       -- clk = 50 MHz
      n => 13,                          -- Baud rate = 9600
      m => 5209)                        -- m = 5209, n = 13
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => '1',
      count_o => OPEN,
      tc_o    => en_baud);


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
      tc_o    => UART_CLK_EN);

  -- -------------------------------------------------------------------------
  --  Serial Transmitter
  -- -------------------------------------------------------------------------
  serial_transmitter : ENTITY work.UART_TX
    GENERIC MAP (
      CLK_DIV_VAL => CLK_DIV_VAL,
      PARITY_BIT  => PARITY_BIT)
    PORT MAP (
      CLK         => clk_i,
      RST         => NOT rst_ni,
      UART_CLK_EN => UART_CLK_EN,
      UART_TXD    => UART_TXD,
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
    DIN_VLD <= '0';                     -- initial value

    WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
    -- ... is deactivated

    ---------------------------------------------------------------------------
    -- BEGIN: Transfer Cycle
    ---------------------------------------------------------------------------
    DIN     <= "00001111";
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(DOUT_VLD);
    ---------------------------------------------------------------------------
    -- Observer: Check received data
    ---------------------------------------------------------------------------
    ASSERT DOUT = DIN
      REPORT "Error: Received data_o is not equal to transmitted data_i !"
      SEVERITY failure;
    -- END: Transfer Cycle
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- BEGIN: Transfer Cycle
    ---------------------------------------------------------------------------
    DIN     <= "11110000";
    DIN_VLD <= '1';
    WAIT FOR 2*period; -- at least 2 clock periods necessary !!!
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(DOUT_VLD);
    ---------------------------------------------------------------------------
    -- Observer: Check received data
    ---------------------------------------------------------------------------
    ASSERT DOUT = DIN
      REPORT "Error: Received data_o is not equal to transmitted data_i !"
      SEVERITY failure;
    -- END: Transfer Cycle
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- BEGIN: Transfer Cycle
    ---------------------------------------------------------------------------
    DIN     <= "01010101";
    DIN_VLD <= '1';
    WAIT FOR 2*period; -- at least 2 clock periods necessary !!!
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(DOUT_VLD);
    ---------------------------------------------------------------------------
    -- Observer: Check received data
    ---------------------------------------------------------------------------
    ASSERT DOUT = DIN
      REPORT "Error: Received data_o is not equal to transmitted data_i !"
      SEVERITY failure;
    -- END: Transfer Cycle
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- BEGIN: Transfer Cycle
    ---------------------------------------------------------------------------
    DIN     <= "10101010";
    DIN_VLD <= '1';
    WAIT FOR 2*period; -- at least 2 clock periods necessary !!!
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(DOUT_VLD);
    ---------------------------------------------------------------------------
    -- Observer: Check received data
    ---------------------------------------------------------------------------
    ASSERT DOUT = DIN
      REPORT "Error: Received data_o is not equal to transmitted data_i !"
      SEVERITY failure;
    -- END: Transfer Cycle
    ---------------------------------------------------------------------------





    clken_p <= false;                   -- switch clock generator off

    WAIT;
  END PROCESS;



END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
