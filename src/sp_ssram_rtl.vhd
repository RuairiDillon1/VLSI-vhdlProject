-------------------------------------------------------------------------------
-- Module     : sp_ssram
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: Synchronous Single-Port SRAM
--              
--
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY sp_ssram IS
  GENERIC (
    addr_width : positive := 8;
    data_width : positive := 8);
  PORT (
    clk_i  : IN  std_ulogic;
    we_i   : IN  std_ulogic;
    addr_i : IN  std_ulogic_vector;
    d_i    : IN  std_ulogic_vector;
    q_o    : OUT std_ulogic_vector
    );
END;

ARCHITECTURE rtl OF sp_ssram IS
  TYPE ram_t IS ARRAY(0 TO 2 ** addr_width - 1) OF std_ulogic_vector(data_width-1 DOWNTO 0);
  SIGNAL ram : ram_t;
BEGIN

  mem_p : PROCESS(clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      IF we_i = '1' THEN
        ram(to_integer(unsigned(addr_i))) <= d_i;
      END IF;
      q_o <= ram(to_integer(unsigned(addr_i)));
    END IF;
  END PROCESS mem_p;

END;


