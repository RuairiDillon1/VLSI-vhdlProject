-- This file was generated by				
-- Qfsm Version 0.55					
-- (C) Stefan Duffner, Rainer Strobel, Aaron Erhardt			


-- Inputs:   rxd_rec   addr[3]   addr[2]   addr[1]   addr[0]   pm_checked
-- State/Output              en_addr_reg en_data_reg en_regfile_wr pm_control_changed
-- wait_for_addr_s           0           0           0             0                  
-- fetch_addr_s              1           0           0             0                  
-- wait_for_data_s           0           0           0             0                  
-- fetch_data_s              0           1           0             0                  
-- write_regfile_s           0           0           1             0                  
-- check_written_addr_s      0           0           0             0                  
-- pattern_control_changed_s 0           0           0             1                  
-- wait_cycle_s              0           0           0             0                  

LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY serial_receiver_fsm IS
  PORT (clk: IN std_ulogic;
        rst_n: IN std_ulogic;
        rxd_rec: IN std_ulogic;
        addr: IN std_ulogic_vector(3 DOWNTO 0);
        pm_checked: IN std_ulogic;
        en_addr_reg: OUT std_ulogic;
        en_data_reg: OUT std_ulogic;
        en_regfile_wr: OUT std_ulogic;
        pm_control_changed: OUT std_ulogic);
END serial_receiver_fsm;

ARCHITECTURE behave OF serial_receiver_fsm IS

TYPE state_type IS (wait_for_addr_s, fetch_addr_s, wait_for_data_s, fetch_data_s, write_regfile_s, check_written_addr_s, pattern_control_changed_s, wait_cycle_s);
SIGNAL next_state, current_state : state_type;

BEGIN
  state_register: PROCESS (rst_n, clk)
  BEGIN
    IF rst_n='0' THEN
      current_state <= wait_for_addr_s;
    ELSIF rising_edge(clk) THEN
      current_state <= next_state;
    END IF;
  END PROCESS;

  next_state_and_output_logic: PROCESS (current_state, rxd_rec, addr(3 DOWNTO 0), pm_checked)
    VARIABLE temp_input : std_ulogic_vector(5 DOWNTO 0);
    VARIABLE temp_output : std_ulogic_vector(3 DOWNTO 0);
  BEGIN
    temp_input := rxd_rec & addr(3) & addr(2) & addr(1) & addr(0) & pm_checked;
    CASE current_state IS
      WHEN wait_for_addr_s => temp_output := "0000";
        IF temp_input="000000" or temp_input="010000" or temp_input="001000" or temp_input="000100" or temp_input="000010" or temp_input="000001" or temp_input="011000" or temp_input="010100" or temp_input="010010" or temp_input="010001" or temp_input="001100" or temp_input="001010" or temp_input="001001" or temp_input="000110" or temp_input="000101" or temp_input="000011" or temp_input="011100" or temp_input="011010" or temp_input="011001" or temp_input="010110" or temp_input="010101" or temp_input="010011" or temp_input="001110" or temp_input="001101" or temp_input="001011" or temp_input="000111" or temp_input="011110" or temp_input="011101" or temp_input="011011" or temp_input="010111" or temp_input="001111" or temp_input="011111" THEN
          next_state <= wait_for_addr_s;
        ELSIF temp_input="100000" or temp_input="110000" or temp_input="101000" or temp_input="100100" or temp_input="100010" or temp_input="100001" or temp_input="111000" or temp_input="110100" or temp_input="110010" or temp_input="110001" or temp_input="101100" or temp_input="101010" or temp_input="101001" or temp_input="100110" or temp_input="100101" or temp_input="100011" or temp_input="111100" or temp_input="111010" or temp_input="111001" or temp_input="110110" or temp_input="110101" or temp_input="110011" or temp_input="101110" or temp_input="101101" or temp_input="101011" or temp_input="100111" or temp_input="111110" or temp_input="111101" or temp_input="111011" or temp_input="110111" or temp_input="101111" or temp_input="111111" THEN
          next_state <= fetch_addr_s;
        ELSE
          next_state <= current_state;
        END IF;
      WHEN fetch_addr_s => temp_output := "1000";
        IF temp_input="100000" or temp_input="110000" or temp_input="101000" or temp_input="100100" or temp_input="100010" or temp_input="100001" or temp_input="111000" or temp_input="110100" or temp_input="110010" or temp_input="110001" or temp_input="101100" or temp_input="101010" or temp_input="101001" or temp_input="100110" or temp_input="100101" or temp_input="100011" or temp_input="111100" or temp_input="111010" or temp_input="111001" or temp_input="110110" or temp_input="110101" or temp_input="110011" or temp_input="101110" or temp_input="101101" or temp_input="101011" or temp_input="100111" or temp_input="111110" or temp_input="111101" or temp_input="111011" or temp_input="110111" or temp_input="101111" or temp_input="111111" THEN
          next_state <= fetch_addr_s;
        ELSIF temp_input="000000" or temp_input="010000" or temp_input="001000" or temp_input="000100" or temp_input="000010" or temp_input="000001" or temp_input="011000" or temp_input="010100" or temp_input="010010" or temp_input="010001" or temp_input="001100" or temp_input="001010" or temp_input="001001" or temp_input="000110" or temp_input="000101" or temp_input="000011" or temp_input="011100" or temp_input="011010" or temp_input="011001" or temp_input="010110" or temp_input="010101" or temp_input="010011" or temp_input="001110" or temp_input="001101" or temp_input="001011" or temp_input="000111" or temp_input="011110" or temp_input="011101" or temp_input="011011" or temp_input="010111" or temp_input="001111" or temp_input="011111" THEN
          next_state <= wait_for_data_s;
        ELSE
          next_state <= current_state;
        END IF;
      WHEN wait_for_data_s => temp_output := "0000";
        IF temp_input="000000" or temp_input="010000" or temp_input="001000" or temp_input="000100" or temp_input="000010" or temp_input="000001" or temp_input="011000" or temp_input="010100" or temp_input="010010" or temp_input="010001" or temp_input="001100" or temp_input="001010" or temp_input="001001" or temp_input="000110" or temp_input="000101" or temp_input="000011" or temp_input="011100" or temp_input="011010" or temp_input="011001" or temp_input="010110" or temp_input="010101" or temp_input="010011" or temp_input="001110" or temp_input="001101" or temp_input="001011" or temp_input="000111" or temp_input="011110" or temp_input="011101" or temp_input="011011" or temp_input="010111" or temp_input="001111" or temp_input="011111" THEN
          next_state <= wait_for_data_s;
        ELSIF temp_input="100000" or temp_input="110000" or temp_input="101000" or temp_input="100100" or temp_input="100010" or temp_input="100001" or temp_input="111000" or temp_input="110100" or temp_input="110010" or temp_input="110001" or temp_input="101100" or temp_input="101010" or temp_input="101001" or temp_input="100110" or temp_input="100101" or temp_input="100011" or temp_input="111100" or temp_input="111010" or temp_input="111001" or temp_input="110110" or temp_input="110101" or temp_input="110011" or temp_input="101110" or temp_input="101101" or temp_input="101011" or temp_input="100111" or temp_input="111110" or temp_input="111101" or temp_input="111011" or temp_input="110111" or temp_input="101111" or temp_input="111111" THEN
          next_state <= fetch_data_s;
        ELSE
          next_state <= current_state;
        END IF;
      WHEN fetch_data_s => temp_output := "0100";
        IF temp_input="100000" or temp_input="110000" or temp_input="101000" or temp_input="100100" or temp_input="100010" or temp_input="100001" or temp_input="111000" or temp_input="110100" or temp_input="110010" or temp_input="110001" or temp_input="101100" or temp_input="101010" or temp_input="101001" or temp_input="100110" or temp_input="100101" or temp_input="100011" or temp_input="111100" or temp_input="111010" or temp_input="111001" or temp_input="110110" or temp_input="110101" or temp_input="110011" or temp_input="101110" or temp_input="101101" or temp_input="101011" or temp_input="100111" or temp_input="111110" or temp_input="111101" or temp_input="111011" or temp_input="110111" or temp_input="101111" or temp_input="111111" THEN
          next_state <= fetch_data_s;
        ELSIF temp_input="000000" or temp_input="010000" or temp_input="001000" or temp_input="000100" or temp_input="000010" or temp_input="000001" or temp_input="011000" or temp_input="010100" or temp_input="010010" or temp_input="010001" or temp_input="001100" or temp_input="001010" or temp_input="001001" or temp_input="000110" or temp_input="000101" or temp_input="000011" or temp_input="011100" or temp_input="011010" or temp_input="011001" or temp_input="010110" or temp_input="010101" or temp_input="010011" or temp_input="001110" or temp_input="001101" or temp_input="001011" or temp_input="000111" or temp_input="011110" or temp_input="011101" or temp_input="011011" or temp_input="010111" or temp_input="001111" or temp_input="011111" THEN
          next_state <= write_regfile_s;
        ELSE
          next_state <= current_state;
        END IF;
      WHEN write_regfile_s => temp_output := "0010";
          next_state <= check_written_addr_s;
      WHEN check_written_addr_s => temp_output := "0000";
        IF temp_input="011110" or temp_input="111110" or temp_input="011111" or temp_input="111111" THEN
          next_state <= pattern_control_changed_s;
        ELSE           next_state <= wait_for_addr_s;
        END IF;
      WHEN pattern_control_changed_s => temp_output := "0001";
        IF temp_input="000000" or temp_input="100000" or temp_input="010000" or temp_input="001000" or temp_input="000100" or temp_input="000010" or temp_input="110000" or temp_input="101000" or temp_input="100100" or temp_input="100010" or temp_input="011000" or temp_input="010100" or temp_input="010010" or temp_input="001100" or temp_input="001010" or temp_input="000110" or temp_input="111000" or temp_input="110100" or temp_input="110010" or temp_input="101100" or temp_input="101010" or temp_input="100110" or temp_input="011100" or temp_input="011010" or temp_input="010110" or temp_input="001110" or temp_input="111100" or temp_input="111010" or temp_input="110110" or temp_input="101110" or temp_input="011110" or temp_input="111110" THEN
          next_state <= pattern_control_changed_s;
        ELSIF temp_input="000001" or temp_input="100001" or temp_input="010001" or temp_input="001001" or temp_input="000101" or temp_input="000011" or temp_input="110001" or temp_input="101001" or temp_input="100101" or temp_input="100011" or temp_input="011001" or temp_input="010101" or temp_input="010011" or temp_input="001101" or temp_input="001011" or temp_input="000111" or temp_input="111001" or temp_input="110101" or temp_input="110011" or temp_input="101101" or temp_input="101011" or temp_input="100111" or temp_input="011101" or temp_input="011011" or temp_input="010111" or temp_input="001111" or temp_input="111101" or temp_input="111011" or temp_input="110111" or temp_input="101111" or temp_input="011111" or temp_input="111111" THEN
          next_state <= wait_cycle_s;
        ELSE
          next_state <= current_state;
        END IF;
      WHEN wait_cycle_s => temp_output := "0000";
          next_state <= wait_for_addr_s;
      WHEN OTHERS => temp_output := (OTHERS =>'X');
      next_state <= wait_for_addr_s;
    END CASE;
    en_addr_reg <= temp_output(3);
    en_data_reg <= temp_output(2);
    en_regfile_wr <= temp_output(1);
    pm_control_changed <= temp_output(0);
  END PROCESS;

END behave;
