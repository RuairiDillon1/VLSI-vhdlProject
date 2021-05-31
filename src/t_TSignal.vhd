-------------------------------------------------------------------------------
-- Module     : t_TSignal
-------------------------------------------------------------------------------
-- Author     :   David.Cunningham@HS-Augsburg.DE
-- Company    : University of Applied Sciences Augsburg
-- Copyright (c) 2011   <haf@fh-augsburg.de>
-------------------------------------------------------------------------------
-- Description: Testbench for mini porject  "Test Signal Generator"
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------------------------------------

ENTITY t_TSignal IS
END t_TSignal;

-------------------------------------------------------------------------------
ARCHITECTURE tbench OF t_TSignal IS

  COMPONENT TSignal
    PORT(
      
      )
   END COMPONENT;


BEGIN --tbench
  
