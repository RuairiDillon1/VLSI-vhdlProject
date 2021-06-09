-------------------------------------------------------------------------------
-- Module     : serial_rx
-------------------------------------------------------------------------------
-- modified by: Johann Faerber
--------------------------------------------------------------------------------
--              modified according to our design rules:
--              using std_ulogic instead of std_logic
--------------------------------------------------------------------------------
-- Original PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart-for-fpga
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY serial_rx IS
  GENERIC (
    CLK_DIV_VAL : integer := 16;
    PARITY_BIT  : string  := "none"  -- type of parity: "none", "even", "odd", "mark", "space"
    ); 
  PORT (
    CLK          : IN  std_ulogic;      -- system clock
    RST          : IN  std_ulogic;      -- high active synchronous reset
    -- UART INTERFACE
    UART_CLK_EN  : IN  std_ulogic;      -- oversampling (16x) UART clock enable
    UART_RXD     : IN  std_ulogic;      -- serial receive data
    -- USER DATA OUTPUT INTERFACE
    DOUT         : OUT std_ulogic_vector(7 DOWNTO 0);  -- output data received via UART
    DOUT_VLD     : OUT std_ulogic;  -- when DOUT_VLD = 1, output data (DOUT) are valid without errors (is assert only for one clock cycle)
    FRAME_ERROR  : OUT std_ulogic;  -- when FRAME_ERROR = 1, stop bit was invalid (is assert only for one clock cycle)
    PARITY_ERROR : OUT std_ulogic  -- when PARITY_ERROR = 1, parity bit was invalid (is assert only for one clock cycle)
    );
END ENTITY;

ARCHITECTURE rtl OF serial_rx IS

  SIGNAL rx_clk_en          : std_ulogic;
  SIGNAL rx_data            : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL rx_bit_count       : unsigned(2 DOWNTO 0);
  SIGNAL rx_parity_bit      : std_ulogic;
  SIGNAL rx_parity_error    : std_ulogic;
  SIGNAL rx_parity_check_en : std_ulogic;
  SIGNAL rx_done            : std_ulogic;
  SIGNAL fsm_idle           : std_ulogic;
  SIGNAL fsm_databits       : std_ulogic;
  SIGNAL fsm_stopbit        : std_ulogic;

  TYPE state IS (idle, startbit, databits, paritybit, stopbit);
  SIGNAL fsm_pstate : state;
  SIGNAL fsm_nstate : state;

BEGIN

  -- -------------------------------------------------------------------------
  -- UART RECEIVER CLOCK DIVIDER AND CLOCK ENABLE FLAG
  -- -------------------------------------------------------------------------

  rx_clk_divider_i : ENTITY work.UART_CLK_DIV
    GENERIC MAP(
      DIV_MAX_VAL  => CLK_DIV_VAL,
      DIV_MARK_POS => 3
      )
    PORT MAP (
      CLK      => CLK,
      RST      => RST,
      CLEAR    => fsm_idle,
      ENABLE   => UART_CLK_EN,
      DIV_MARK => rx_clk_en
      );

  -- -------------------------------------------------------------------------
  -- UART RECEIVER BIT COUNTER
  -- -------------------------------------------------------------------------

  uart_rx_bit_counter_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        rx_bit_count <= (OTHERS => '0');
      ELSIF (rx_clk_en = '1' AND fsm_databits = '1') THEN
        IF (rx_bit_count = "111") THEN
          rx_bit_count <= (OTHERS => '0');
        ELSE
          rx_bit_count <= rx_bit_count + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- -------------------------------------------------------------------------
  -- UART RECEIVER DATA SHIFT REGISTER
  -- -------------------------------------------------------------------------

  uart_rx_data_shift_reg_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (rx_clk_en = '1' AND fsm_databits = '1') THEN
        rx_data <= UART_RXD & rx_data(7 DOWNTO 1);
      END IF;
    END IF;
  END PROCESS;

  DOUT <= rx_data;

  -- -------------------------------------------------------------------------
  -- UART RECEIVER PARITY GENERATOR AND CHECK
  -- -------------------------------------------------------------------------

  uart_rx_parity_g : IF (PARITY_BIT /= "none") GENERATE
    uart_rx_parity_gen_i : ENTITY work.UART_PARITY
      GENERIC MAP (
        DATA_WIDTH  => 8,
        PARITY_TYPE => PARITY_BIT
        )
      PORT MAP (
        DATA_IN    => rx_data,
        PARITY_OUT => rx_parity_bit
        );

    uart_rx_parity_check_reg_p : PROCESS (CLK)
    BEGIN
      IF (rising_edge(CLK)) THEN
        IF (rx_clk_en = '1') THEN
          rx_parity_error <= rx_parity_bit XOR UART_RXD;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;

  uart_rx_noparity_g : IF (PARITY_BIT = "none") GENERATE
    rx_parity_error <= '0';
  END GENERATE;

  -- -------------------------------------------------------------------------
  -- UART RECEIVER OUTPUT REGISTER
  -- -------------------------------------------------------------------------

  rx_done <= rx_clk_en AND fsm_stopbit;

  uart_rx_output_reg_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        DOUT_VLD     <= '0';
        FRAME_ERROR  <= '0';
        PARITY_ERROR <= '0';
      ELSE
        DOUT_VLD     <= rx_done AND NOT rx_parity_error AND UART_RXD;
        FRAME_ERROR  <= rx_done AND NOT UART_RXD;
        PARITY_ERROR <= rx_done AND rx_parity_error;
      END IF;
    END IF;
  END PROCESS;

  -- -------------------------------------------------------------------------
  -- UART RECEIVER FSM
  -- -------------------------------------------------------------------------

  -- PRESENT STATE REGISTER
  PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        fsm_pstate <= idle;
      ELSE
        fsm_pstate <= fsm_nstate;
      END IF;
    END IF;
  END PROCESS;

  -- NEXT STATE AND OUTPUTS LOGIC
  PROCESS (fsm_pstate, UART_RXD, rx_clk_en, rx_bit_count)
  BEGIN
    CASE fsm_pstate IS

      WHEN idle =>
        fsm_stopbit  <= '0';
        fsm_databits <= '0';
        fsm_idle     <= '1';

        IF (UART_RXD = '0') THEN
          fsm_nstate <= startbit;
        ELSE
          fsm_nstate <= idle;
        END IF;

      WHEN startbit =>
        fsm_stopbit  <= '0';
        fsm_databits <= '0';
        fsm_idle     <= '0';

        IF (rx_clk_en = '1') THEN
          fsm_nstate <= databits;
        ELSE
          fsm_nstate <= startbit;
        END IF;

      WHEN databits =>
        fsm_stopbit  <= '0';
        fsm_databits <= '1';
        fsm_idle     <= '0';

        IF ((rx_clk_en = '1') AND (rx_bit_count = "111")) THEN
          IF (PARITY_BIT = "none") THEN
            fsm_nstate <= stopbit;
          ELSE
            fsm_nstate <= paritybit;
          END IF;
        ELSE
          fsm_nstate <= databits;
        END IF;

      WHEN paritybit =>
        fsm_stopbit  <= '0';
        fsm_databits <= '0';
        fsm_idle     <= '0';

        IF (rx_clk_en = '1') THEN
          fsm_nstate <= stopbit;
        ELSE
          fsm_nstate <= paritybit;
        END IF;

      WHEN stopbit =>
        fsm_stopbit  <= '1';
        fsm_databits <= '0';
        fsm_idle     <= '0';

        IF (rx_clk_en = '1') THEN
          fsm_nstate <= idle;
        ELSE
          fsm_nstate <= stopbit;
        END IF;

      WHEN OTHERS =>
        fsm_stopbit  <= '0';
        fsm_databits <= '0';
        fsm_idle     <= '0';
        fsm_nstate   <= idle;

    END CASE;
  END PROCESS;

END ARCHITECTURE;
