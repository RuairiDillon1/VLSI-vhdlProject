-------------------------------------------------------------------------------
-- Module     : t_de1_tsg
-------------------------------------------------------------------------------
-- Author     :   <johann.faerber@hs-augsburg.de>
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2021   <johann.faerber@hs-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for design "de1_tsg"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_de1_tsg IS

END ENTITY t_de1_tsg;

-------------------------------------------------------------------------------

ARCHITECTURE tbench OF t_de1_tsg IS

  COMPONENT de1_tsg IS
    PORT (
      CLOCK_50 : IN  std_ulogic;
      KEY0     : IN  std_ulogic;
      KEY2     : IN  std_ulogic;
      SW0      : IN  std_ulogic;
      UART_RXD : IN  std_ulogic;
      LEDR     : OUT std_ulogic_vector(9 DOWNTO 0);
      LEDG     : OUT std_ulogic_vector(7 DOWNTO 0);
      HEX0     : OUT std_ulogic_vector(6 DOWNTO 0);
      HEX1     : OUT std_ulogic_vector(6 DOWNTO 0);
      HEX2     : OUT std_ulogic_vector(6 DOWNTO 0);
      HEX3     : OUT std_ulogic_vector(6 DOWNTO 0);
      GPO_1    : OUT std_ulogic_vector(8 DOWNTO 0));
  END COMPONENT de1_tsg;

  -- component ports
  -- SIGNAL CLOCK_50 : std_ulogic;
  -- SIGNAL KEY      : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL KEY2  : std_ulogic;
  SIGNAL SW0   : std_ulogic;
  SIGNAL LEDR  : std_ulogic_vector(9 DOWNTO 0);
  SIGNAL LEDG  : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL HEX0  : std_ulogic_vector(6 DOWNTO 0);
  SIGNAL HEX1  : std_ulogic_vector(6 DOWNTO 0);
  SIGNAL HEX2  : std_ulogic_vector(6 DOWNTO 0);
  SIGNAL HEX3  : std_ulogic_vector(6 DOWNTO 0);
  SIGNAL GPO_1 : std_ulogic_vector(8 DOWNTO 0);


  -- additional signals in test bench
  SIGNAL clk_i  : std_ulogic;
  SIGNAL rst_ni : std_ulogic;

  SIGNAL UART_CLK_EN : std_ulogic;
  SIGNAL UART_TXD    : std_ulogic;
  SIGNAL DIN         : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL DIN_VLD     : std_ulogic;
  SIGNAL DIN_RDY     : std_ulogic;


  -- definition of a clock period
  CONSTANT period : time    := 20 ns;
  -- switch for clock generator
  SIGNAL clken_p  : boolean := true;

BEGIN  -- ARCHITECTURE tbench

  -- component instantiation
  MUT : de1_tsg
    PORT MAP (
      CLOCK_50 => clk_i,
      KEY0     => rst_ni,
      SW0      => SW0,
      KEY2     => KEY2,
      UART_RXD => UART_TXD,
      LEDR     => LEDR,
      LEDG     => LEDG,
      HEX0     => HEX0,
      HEX1     => HEX1,
      HEX2     => HEX2,
      HEX3     => HEX3,
      GPO_1    => GPO_1);

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
      CLK_DIV_VAL => 16,
      PARITY_BIT  => "none")
    PORT MAP (
      CLK         => clk_i,
      RST         => NOT rst_ni,
      UART_CLK_EN => UART_CLK_EN,
      UART_TXD    => UART_TXD,
      DIN         => DIN,
      DIN_VLD     => DIN_VLD,
      DIN_RDY     => DIN_RDY);

  -- -------------------------------------------------------------------------
  --  Transfer Channel
  -- -------------------------------------------------------------------------
  -- serial_transfer_channel : UART_RXD <= UART_TXD;

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


    PROCEDURE external_trigger (
      CONSTANT no_of_periods : IN positive) IS
    BEGIN
      KEY2 <= '1';
      WAIT FOR period;
      KEY2 <= '0';
      WAIT FOR no_of_periods * period;
      KEY2 <= '1';
      WAIT FOR period;
    END;

  BEGIN

    -- external_trigger(3);
    KEY2 <= '1';                        -- external trigger
    SW0  <= '1';                        -- switch LEDR to prbs

    WAIT UNTIL rst_ni = '1';            -- wait until asynchronous reset ...
    -- ... is deactivated

    WAIT UNTIL falling_edge(UART_CLK_EN);
    WAIT FOR period;


    ---------------------------------------------------------------------------
    -- system enable
    ---------------------------------------------------------------------------
    DIN     <= X"01";                   -- control register at address x01
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT FOR period;
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    DIN     <= X"01";                   -- enable system: bit 0
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- pwm
    ---------------------------------------------------------------------------
    DIN     <= X"04";                   -- pwm width register at address x04
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT FOR period;
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------
    DIN     <= X"7f";                   -- value of pwm width
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------
    DIN     <= X"05";                   -- pwm period register at address x05
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT FOR period;
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------
    DIN     <= X"0f";                   -- value of pwm period
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------
    DIN     <= X"06";                   -- pwm control register at address x06
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT FOR period;
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------
    DIN     <= X"01";                   -- switch ON internal pwm generator
    WAIT FOR period;
    DIN_VLD <= '1';
    WAIT FOR period;
    DIN_VLD <= '0';
    WAIT UNTIL rising_edge(DIN_RDY);
    WAIT UNTIL falling_edge(GPO_1(3));  -- rxd_rdy
    WAIT FOR 2*period;
    ---------------------------------------------------------------------------


    -- wait for a pwm period
    ---------------------------------------------------------------------------
    WAIT UNTIL falling_edge(GPO_1(6));  -- pwm output
    WAIT UNTIL falling_edge(GPO_1(6));  -- pwm output
    WAIT UNTIL falling_edge(GPO_1(6));  -- pwm output
    WAIT UNTIL falling_edge(GPO_1(6));  -- pwm output
    ---------------------------------------------------------------------------





    clken_p <= false;                   -- switch clock generator off

    WAIT;
  END PROCESS;



END ARCHITECTURE tbench;

-------------------------------------------------------------------------------
