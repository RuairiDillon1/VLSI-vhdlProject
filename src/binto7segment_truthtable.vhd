-------------------------------------------------------------------------------
-- Module     : binto7segment
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: binary-to-7-segment decoder
--              function modelled as a truth table
--              using a selected signal assignment
--              segments get illuminated by a low-active signal
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY binto7segment IS
  PORT (bin_i      : IN  std_ulogic_vector(3 DOWNTO 0);
        segments_o : OUT std_ulogic_vector(6 DOWNTO 0)
        );
END binto7segment;

ARCHITECTURE truthtable OF binto7segment IS

  -- seven-segment positions
  -- 
  -- segment positions    input vector index     segment name
  --      a                      0            =>     a
  --     ---                     1            =>     b
  --  f |   | b                  2            =>     c
  --     ---   <- g              3            =>     d 
  --  e |   | c                  4            =>     e 
  --     ---                     5            =>     f 
  --      d                      6            =>     g

BEGIN
  
  decoder : WITH bin_i SELECT 
    segments_o <=
    -- outputs:   |   inputs:
    --------------------------------------------
    -- index      |             number displayed
    -- 6543210    |
    --------------------------------------------
      "1000000" WHEN "0000",    -- 0
      "1111001" WHEN "0001",    -- 1
      "0100100" WHEN "0010",    -- 2
      "0110000" WHEN "0011",    -- 3
      "0011001" WHEN "0100",    -- 4
      "0010010" WHEN "0101",    -- 5
      "0000010" WHEN "0110",    -- 6
      "1111000" WHEN "0111",    -- 7
      "0000000" WHEN "1000",    -- 8
      "0010000" WHEN "1001",    -- 9
      "0001000" WHEN "1010",    -- A
      "0000011" WHEN "1011",    -- b
      "1000110" WHEN "1100",    -- C
      "0100001" WHEN "1101",    -- d
      "0000100" WHEN "1110",    -- e
      "0001110" WHEN "1111",    -- F
      "0000110" WHEN OTHERS;    -- displays Symbol 'E' for ERROR

END truthtable;
-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------

