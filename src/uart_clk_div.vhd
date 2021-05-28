-------------------------------------------------------------------------------
-- Module     : serial_rx
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
USE IEEE.MATH_REAL.ALL;

ENTITY UART_CLK_DIV IS
  GENERIC (
    DIV_MAX_VAL  : integer := 16;
    DIV_MARK_POS : integer := 1
    );
  PORT (
    CLK      : IN  std_ulogic;          -- system clock
    RST      : IN  std_ulogic;          -- high active synchronous reset
    -- USER INTERFACE
    CLEAR    : IN  std_ulogic;          -- clock divider counter clear
    ENABLE   : IN  std_ulogic;          -- clock divider counter enable
    DIV_MARK : OUT std_ulogic   -- output divider mark (divided clock enable)
    );
END ENTITY;

ARCHITECTURE RTL OF UART_CLK_DIV IS

  CONSTANT CLK_DIV_WIDTH : integer := integer(ceil(log2(real(DIV_MAX_VAL))));

  SIGNAL clk_div_cnt      : unsigned(CLK_DIV_WIDTH-1 DOWNTO 0);
  SIGNAL clk_div_cnt_mark : std_ulogic;

BEGIN

  clk_div_cnt_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      IF (CLEAR = '1') THEN
        clk_div_cnt <= (OTHERS => '0');
      ELSIF (ENABLE = '1') THEN
        IF (clk_div_cnt = DIV_MAX_VAL-1) THEN
          clk_div_cnt <= (OTHERS => '0');
        ELSE
          clk_div_cnt <= clk_div_cnt + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS;

  clk_div_cnt_mark <= '1' WHEN (clk_div_cnt = DIV_MARK_POS) ELSE '0';

  div_mark_p : PROCESS (CLK)
  BEGIN
    IF (rising_edge(CLK)) THEN
      DIV_MARK <= ENABLE AND clk_div_cnt_mark;
    END IF;
  END PROCESS;

END ARCHITECTURE;
