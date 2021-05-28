-------------------------------------------------------------------------------
-- Module     : UART_PARITY
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

ENTITY UART_PARITY IS
  GENERIC (
    DATA_WIDTH  : integer := 8;
    PARITY_TYPE : string  := "none"  -- legal values: "none", "even", "odd", "mark", "space"
    );
  PORT (
    DATA_IN    : IN  std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    PARITY_OUT : OUT std_ulogic
    );
END ENTITY;

ARCHITECTURE RTL OF UART_PARITY IS

BEGIN

  -- -------------------------------------------------------------------------
  -- PARITY BIT GENERATOR
  -- -------------------------------------------------------------------------

  even_parity_g : IF (PARITY_TYPE = "even") GENERATE
    PROCESS (DATA_IN)
      VARIABLE parity_temp : std_ulogic;
    BEGIN
      parity_temp := '0';
      FOR i IN DATA_IN'range LOOP
        parity_temp := parity_temp XOR DATA_IN(i);
      END LOOP;
      PARITY_OUT <= parity_temp;
    END PROCESS;
  END GENERATE;

  odd_parity_g : IF (PARITY_TYPE = "odd") GENERATE
    PROCESS (DATA_IN)
      VARIABLE parity_temp : std_ulogic;
    BEGIN
      parity_temp := '1';
      FOR i IN DATA_IN'range LOOP
        parity_temp := parity_temp XOR DATA_IN(i);
      END LOOP;
      PARITY_OUT <= parity_temp;
    END PROCESS;
  END GENERATE;

  mark_parity_g : IF (PARITY_TYPE = "mark") GENERATE
    PARITY_OUT <= '1';
  END GENERATE;

  space_parity_g : IF (PARITY_TYPE = "space") GENERATE
    PARITY_OUT <= '0';
  END GENERATE;

END ARCHITECTURE;
