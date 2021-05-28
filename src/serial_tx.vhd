-------------------------------------------------------------------------------
-- Module     : serial_tx
-------------------------------------------------------------------------------
-- modified by: Johann Faerber
--------------------------------------------------------------------------------
--              modified according to our design rules:
--              using std_ulogic instead of std_logic
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart-for-fpga
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY UART_TX IS
  GENERIC (
    CLK_DIV_VAL : integer := 16;
    PARITY_BIT  : string  := "none"  -- type of parity: "none", "even", "odd", "mark", "space"
    );
  PORT (
    CLK         : IN  std_ulogic;       -- system clock
    RST         : IN  std_ulogic;       -- high active synchronous reset
    -- UART INTERFACE
    UART_CLK_EN : IN  std_ulogic;       -- oversampling (16x) UART clock enable
    UART_TXD    : OUT std_ulogic;       -- serial transmit data
    -- USER DATA INPUT INTERFACE
    DIN         : IN  std_ulogic_vector(7 DOWNTO 0);  -- input data to be transmitted over UART
    DIN_VLD     : IN  std_ulogic;  -- when DIN_VLD = 1, input data (DIN) are valid
    DIN_RDY     : OUT std_ulogic  -- when DIN_RDY = 1, transmitter is ready and valid input data will be accepted for transmiting
    );
END ENTITY;

ARCHITECTURE RTL OF UART_TX IS

  SIGNAL tx_clk_en       : std_ulogic;
  SIGNAL tx_clk_div_clr  : std_ulogic;
  SIGNAL tx_data         : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL tx_bit_count    : unsigned(2 DOWNTO 0);
  SIGNAL tx_bit_count_en : std_ulogic;
  SIGNAL tx_ready        : std_ulogic;
  SIGNAL tx_parity_bit   : std_ulogic;
  SIGNAL tx_data_out_sel : std_ulogic_vector(1 DOWNTO 0);

  TYPE state IS (idle, txsync, startbit, databits, paritybit, stopbit);
  SIGNAL tx_pstate : state;
  SIGNAL tx_nstate : state;

BEGIN

  DIN_RDY <= tx_ready;

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER CLOCK DIVIDER AND CLOCK ENABLE FLAG
  -- -------------------------------------------------------------------------

  tx_clk_divider_i : ENTITY work.UART_CLK_DIV
    GENERIC MAP(
      DIV_MAX_VAL  => CLK_DIV_VAL,
      DIV_MARK_POS => 1
      )
    PORT MAP (
      CLK      => CLK,
      RST      => RST,
      CLEAR    => tx_clk_div_clr,
      ENABLE   => UART_CLK_EN,
      DIV_MARK => tx_clk_en
      );

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER INPUT DATA REGISTER
  -- -------------------------------------------------------------------------

  uart_tx_input_data_reg_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (DIN_VLD = '1' AND tx_ready = '1') THEN
        tx_data <= DIN;
      END IF;
    END IF;
  END PROCESS;

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER BIT COUNTER
  -- -------------------------------------------------------------------------

  uart_tx_bit_counter_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        tx_bit_count <= (OTHERS => '0');
      ELSIF (tx_bit_count_en = '1' AND tx_clk_en = '1') THEN
        IF (tx_bit_count = "111") THEN
          tx_bit_count <= (OTHERS => '0');
        ELSE
          tx_bit_count <= tx_bit_count + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER PARITY GENERATOR
  -- -------------------------------------------------------------------------

  uart_tx_parity_g : IF (PARITY_BIT /= "none") GENERATE
    uart_tx_parity_gen_i : ENTITY work.UART_PARITY
      GENERIC MAP (
        DATA_WIDTH  => 8,
        PARITY_TYPE => PARITY_BIT
        )
      PORT MAP (
        DATA_IN    => tx_data,
        PARITY_OUT => tx_parity_bit
        );
  END GENERATE;

  uart_tx_noparity_g : IF (PARITY_BIT = "none") GENERATE
    tx_parity_bit <= '0';
  END GENERATE;

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER OUTPUT DATA REGISTER
  -- -------------------------------------------------------------------------

  uart_tx_output_data_reg_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        UART_TXD <= '1';
      ELSE
        CASE tx_data_out_sel IS
          WHEN "01" =>                  -- START BIT
            UART_TXD <= '0';
          WHEN "10" =>                  -- DATA BITS
            UART_TXD <= tx_data(to_integer(tx_bit_count));
          WHEN "11" =>                  -- PARITY BIT
            UART_TXD <= tx_parity_bit;
          WHEN OTHERS =>                -- STOP BIT OR IDLE
            UART_TXD <= '1';
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  -- -------------------------------------------------------------------------
  -- UART TRANSMITTER FSM
  -- -------------------------------------------------------------------------

  -- PRESENT STATE REGISTER
  PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (RST = '1') THEN
        tx_pstate <= idle;
      ELSE
        tx_pstate <= tx_nstate;
      END IF;
    END IF;
  END PROCESS;

  -- NEXT STATE AND OUTPUTS LOGIC
  PROCESS (tx_pstate, DIN_VLD, tx_clk_en, tx_bit_count)
  BEGIN

    CASE tx_pstate IS

      WHEN idle =>
        tx_ready        <= '1';
        tx_data_out_sel <= "00";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '1';

        IF (DIN_VLD = '1') THEN
          tx_nstate <= txsync;
        ELSE
          tx_nstate <= idle;
        END IF;

      WHEN txsync =>
        tx_ready        <= '0';
        tx_data_out_sel <= "00";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '0';

        IF (tx_clk_en = '1') THEN
          tx_nstate <= startbit;
        ELSE
          tx_nstate <= txsync;
        END IF;

      WHEN startbit =>
        tx_ready        <= '0';
        tx_data_out_sel <= "01";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '0';

        IF (tx_clk_en = '1') THEN
          tx_nstate <= databits;
        ELSE
          tx_nstate <= startbit;
        END IF;

      WHEN databits =>
        tx_ready        <= '0';
        tx_data_out_sel <= "10";
        tx_bit_count_en <= '1';
        tx_clk_div_clr  <= '0';

        IF ((tx_clk_en = '1') AND (tx_bit_count = "111")) THEN
          IF (PARITY_BIT = "none") THEN
            tx_nstate <= stopbit;
          ELSE
            tx_nstate <= paritybit;
          END IF;
        ELSE
          tx_nstate <= databits;
        END IF;

      WHEN paritybit =>
        tx_ready        <= '0';
        tx_data_out_sel <= "11";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '0';

        IF (tx_clk_en = '1') THEN
          tx_nstate <= stopbit;
        ELSE
          tx_nstate <= paritybit;
        END IF;

      WHEN stopbit =>
        tx_ready        <= '1';
        tx_data_out_sel <= "00";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '0';

        IF (DIN_VLD = '1') THEN
          tx_nstate <= txsync;
        ELSIF (tx_clk_en = '1') THEN
          tx_nstate <= idle;
        ELSE
          tx_nstate <= stopbit;
        END IF;

      WHEN OTHERS =>
        tx_ready        <= '0';
        tx_data_out_sel <= "00";
        tx_bit_count_en <= '0';
        tx_clk_div_clr  <= '0';
        tx_nstate       <= idle;

    END CASE;
  END PROCESS;

END ARCHITECTURE;
