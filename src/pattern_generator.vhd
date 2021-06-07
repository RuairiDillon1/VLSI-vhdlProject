LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
-- use IEEE.numeric_std.all;

ENTITY pattern_generator IS
  PORT (
    en_pi  : IN std_ulogic;
    rst_ni : IN std_ulogic;
    clk_i  : IN std_ulogic;

    tc_addr_cnt_i : IN std_ulogic;

    pattern_length_i  : IN std_ulogic_vector(7 DOWNTO 0);  -- amount of numbers in pattern memory
    pattern_control_i : IN std_ulogic_vector(1 DOWNTO 0);  -- from register
                                                           -- file; bit 2 is
                                                           -- for external
                                                           -- trigger and
                                                           -- not needed
                                                           -- inside here

    rxd_valid_i : IN std_ulogic;                     -- uart data valid
    rxd_data_i  : IN std_ulogic_vector(7 DOWNTO 0);  -- uart data

    pm_control_changed_i : IN  std_ulogic;  -- communication between state machines
    pm_checked_o         : OUT std_ulogic;  -- communication between state machines

    pattern_o : OUT std_ulogic_vector(7 DOWNTO 0);
    en_pm_count_o : OUT std_ulogic;
    clr_pm_cnt_o : OUT std_ulogic;
    );
END ENTITY pattern_generator;

ARCHITECTURE structure OF pattern_generator IS

  COMPONENT pattern_generator_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      sen_p              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      tc_pm              : IN  std_ulogic;
      pm_control_changed : IN  std_ulogic;
      pm_control         : IN  std_ulogic_vector(1 DOWNTO 0);
      en_pm              : OUT std_ulogic;
      en_pm_cnt          : OUT std_ulogic;
      clr_pm_cnt         : OUT std_ulogic;
      pm_checked         : OUT std_ulogic);
  END COMPONENT pattern_generator_fsm;

  COMPONENT sp_ssram IS
    GENERIC (
      addr_width : positive;
      data_width : positive);
    PORT (
      clk_i  : IN  std_ulogic;
      we_i   : IN  std_ulogic;
      addr_i : IN  std_ulogic_vector;
      d_i    : IN  std_ulogic_vector;
      q_o    : OUT std_ulogic_vector);
  END COMPONENT sp_ssram;

  CONSTANT addr_width : natural := 8;
  CONSTANT data_width : natural := 8;

  SIGNAL clk : std_ulogic;
  SIGNAL rst : std_ulogic;
  SIGNAL en  : std_ulogic;

  SIGNAL pm_control         : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL pm_out             : std_ulogic_vector(data_width - 1 DOWNTO 0);
  SIGNAL pm_control_changed : std_ulogic;
  SIGNAL en_pm              : std_ulogic;

  SIGNAL addr     : std_ulogic_vector(addr_width - 1 DOWNTO 0);

BEGIN

  state_machine : pattern_generator_fsm
    PORT MAP (
      clk                => clk,
      rst_n              => rst,
      sen_p              => en_pi,
      rxd_rec            => rxd_valid_i,
      tc_pm              => tc_addr_cnt_i,
      pm_control_changed => pm_control_changed_i,
      pm_control         => pm_control,
      en_pm              => en_pm,
      en_pm_cnt          => en_pm_count_o,
      clr_pm_cnt         => clr_pm_cnt_o,
      pm_checked         => pm_checked_o);

  pattern_memory : sp_ssram
    GENERIC MAP (
      addr_width => addr_width,
      data_width => data_width)
    PORT MAP (
      clk_i  => clk,
      we_i   => en_pm,   
      addr_i => addr,
      d_i    => rxd_data_i,
      q_o    => pm_out);

  rst        <= rst_ni;
  clk        <= clk_i;
  en         <= en_pi;
  pm_control <= pattern_control_i;

  WITH pm_control SELECT
    pattern_o <= (OTHERS => '0') WHEN "00",  -- stop
    pm_out                       WHEN "01",  -- single burst
    pm_out                       WHEN "10",  -- continous burst
    (OTHERS              => '0') WHEN "11",  -- load
    (OTHERS              => '0') WHEN OTHERS;
  
END ARCHITECTURE structure;
