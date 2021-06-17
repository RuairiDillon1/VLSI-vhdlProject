-------------------------------------------------------------------------------
-- Module     : structure of tsg
-------------------------------------------------------------------------------
-- Author     : Johann Faerber
-- Company    : University of Applied Sciences Augsburg
-------------------------------------------------------------------------------
-- Description: Test Signal Generator
-------------------------------------------------------------------------------
-- Revisions  : see end of file
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ARCHITECTURE structure OF tsg IS

  -- components for serial communication
  COMPONENT serial_rx IS
    GENERIC (
      CLK_DIV_VAL : integer;
      PARITY_BIT  : string);
    PORT (
      CLK          : IN  std_ulogic;
      RST          : IN  std_ulogic;
      UART_CLK_EN  : IN  std_ulogic;
      UART_RXD     : IN  std_ulogic;
      DOUT         : OUT std_ulogic_vector(7 DOWNTO 0);
      DOUT_VLD     : OUT std_ulogic;
      FRAME_ERROR  : OUT std_ulogic;
      PARITY_ERROR : OUT std_ulogic);
  END COMPONENT serial_rx;

  COMPONENT serial_receiver_reg IS
    PORT (
      rst_ni         : IN  std_ulogic;
      clk_i          : IN  std_ulogic;
      en_addr_reg_i  : IN  std_ulogic;
      en_data_reg_i  : IN  std_ulogic;
      rxd_data_i     : IN  std_ulogic_vector(7 DOWNTO 0);
      regfile_addr_o : OUT std_ulogic_vector(3 DOWNTO 0);
      regfile_data_o : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT serial_receiver_reg;

  COMPONENT serial_receiver_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      addr               : IN  std_ulogic_vector(3 DOWNTO 0);
      pm_checked         : IN  std_ulogic;
      en_addr_reg        : OUT std_ulogic;
      en_data_reg        : OUT std_ulogic;
      en_regfile_wr      : OUT std_ulogic;
      pm_control_changed : OUT std_ulogic);
  END COMPONENT serial_receiver_fsm;

  COMPONENT regfile IS
    GENERIC (
      ADDR_WIDTH : integer;
      DATA_WIDTH : integer);
    PORT (
      clk_i               : IN  std_ulogic;
      wr_en_i             : IN  std_ulogic;
      w_addr_i            : IN  std_ulogic_vector (ADDR_WIDTH-1 DOWNTO 0);
      r_addr_i            : IN  std_ulogic_vector (ADDR_WIDTH-1 DOWNTO 0);
      w_data_i            : IN  std_ulogic_vector (DATA_WIDTH-1 DOWNTO 0);
      system_control_o    : OUT std_ulogic_vector(1 DOWNTO 0);
      pwm_pulse_width_o   : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      pwm_period_o        : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      pwm_control_o       : OUT std_ulogic_vector(1 DOWNTO 0);
      noise_length_o      : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      noise_period_o      : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      noise_control_o     : OUT std_ulogic_vector(1 DOWNTO 0);
      pattern_mem_depth_o : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      pattern_period_o    : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
      pattern_control_o   : OUT std_ulogic_vector(2 DOWNTO 0);
      r_data_o            : OUT std_ulogic_vector (DATA_WIDTH-1 DOWNTO 0));
  END COMPONENT regfile;

  -- for noise, pattern and pwm
  COMPONENT freq_control IS
    PORT (
      clk_i    : IN  std_ulogic;
      rst_ni   : IN  std_ulogic;
      en_pi    : IN  std_ulogic;
      count_o  : OUT std_ulogic_vector(7 DOWNTO 0);
      freq_o   : OUT std_ulogic;
      period_i : IN  std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT freq_control;

  -- for pwm
  COMPONENT pwm_generator IS
    PORT (
      en_pi       : IN  std_ulogic;
      rst_ni      : IN  std_ulogic;
      pwm_width_i : IN  std_ulogic_vector(7 DOWNTO 0);
      clk_i       : IN  std_ulogic;
      pwm_o       : OUT std_ulogic);
  END COMPONENT pwm_generator;

  -- for noise
  COMPONENT noise_generator IS
    PORT (
      clk_i                : IN  std_ulogic;
      rst_ni               : IN  std_ulogic;
      en_pi                : IN  std_ulogic;
      en_noise_generator_i : IN  std_ulogic;
      noise_prbsg_length_i : IN  std_ulogic_vector(7 DOWNTO 0);
      prbs_o               : OUT std_ulogic_vector(22 DOWNTO 0);
      noise_o              : OUT std_ulogic;
      eoc_o                : OUT std_ulogic);
  END COMPONENT noise_generator;

  -- for pattern
  COMPONENT pattern_generator IS
    PORT (
      en_write_pm  : IN  std_ulogic;
      clk_i        : IN  std_ulogic;
      pm_control_i : IN  std_ulogic_vector(1 DOWNTO 0);
      addr_cnt_i   : IN  std_ulogic_vector(7 DOWNTO 0);
      rxd_data_i   : IN  std_ulogic_vector(7 DOWNTO 0);
      pattern_o    : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT pattern_generator;

  COMPONENT pattern_generator_fsm IS
    PORT (
      clk                : IN  std_ulogic;
      rst_n              : IN  std_ulogic;
      rxd_rec            : IN  std_ulogic;
      tc_pm              : IN  std_ulogic;
      pm_control_changed : IN  std_ulogic;
      pm_control         : IN  std_ulogic_vector(1 DOWNTO 0);
      addr_cnt_enabled   : IN  std_ulogic;
      en_pm              : OUT std_ulogic;
      en_pm_cnt          : OUT std_ulogic;
      clr_pm_cnt         : OUT std_ulogic;
      pm_checked         : OUT std_ulogic;
      pattern_valid      : OUT std_ulogic);
  END COMPONENT pattern_generator_fsm;

  COMPONENT cntup_addr IS
    PORT (
      clk_i  : IN  std_ulogic;
      clr_i  : IN  std_ulogic;
      rst_ni : IN  std_ulogic;
      en_pi  : IN  std_ulogic;
      len_i  : IN  std_ulogic_vector(7 DOWNTO 0);
      q_o    : OUT std_ulogic_vector(7 DOWNTO 0);
      tc_o   : OUT std_ulogic);
  END COMPONENT cntup_addr;

  -- serial components instantiation
  CONSTANT CLK_DIV_VAL        : integer := 16;
  CONSTANT PARITY_BIT         : string  := "none";
  CONSTANT regfile_addr_width : integer := 4;
  CONSTANT regfile_data_width : integer := 8;

  -- basic signals
  SIGNAL clock       : std_ulogic;
  SIGNAL reset       : std_ulogic;
  SIGNAL en_main     : std_ulogic;      -- en_tsg and en_system
  SIGNAL ext_trigger : std_ulogic;

  -- serial signals
  SIGNAL en_serial           : std_ulogic;
  SIGNAL serial_data         : std_ulogic;
  SIGNAL serial_data_o       : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL serial_data_valid_o : std_ulogic;

  SIGNAL regfile_addr_o : std_ulogic_vector(regfile_addr_width - 1 DOWNTO 0);
  SIGNAL regfile_data_o : std_ulogic_vector(regfile_data_width - 1 DOWNTO 0);

  SIGNAL en_addr_reg   : std_ulogic;
  SIGNAL en_data_reg   : std_ulogic;
  SIGNAL en_regfile_wr : std_ulogic;

  -- state machine communication
  SIGNAL pm_checked         : std_ulogic;
  SIGNAL pm_control_changed : std_ulogic;

  -- regfile signals
  SIGNAL system_control_o  : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL pwm_pulse_width_o : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL pwm_period_o      : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL pwm_control_o     : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL noise_length_o    : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL noise_period_o    : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL noise_control_o   : std_ulogic_vector(1 DOWNTO 0);
  SIGNAL pattern_length_o  : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL pattern_period_o  : std_ulogic_vector(regfile_data_width-1 DOWNTO 0);
  SIGNAL pattern_control_o : std_ulogic_vector(2 DOWNTO 0);

  -- noise signals
  SIGNAL noise_freq_div : std_ulogic;
  SIGNAL en_noise_gen   : std_ulogic;

  -- pwm signals
  SIGNAL pwm_freq_div : std_ulogic;
  SIGNAL en_pwm_gen   : std_ulogic;

  -- pattern signals
  SIGNAL pattern_freq_div        : std_ulogic;
  SIGNAL en_write_pm             : std_ulogic;
  SIGNAL en_cntup_addr           : std_ulogic;
  SIGNAL en_pattern_freq_div     : std_ulogic;
  SIGNAL en_pm_cnt               : std_ulogic;
  SIGNAL en_continous_cntup_addr : std_ulogic;
  SIGNAL clr_cntup_addr          : std_ulogic;
  SIGNAL cntup_addr_o            : std_ulogic_vector(7 DOWNTO 0);
  SIGNAL cntup_addr_tc           : std_ulogic;
  SIGNAL pattern_valid           : std_ulogic;

BEGIN

  serial_rx_uart : serial_rx
    GENERIC MAP (
      CLK_DIV_VAL => CLK_DIV_VAL,
      PARITY_BIT  => PARITY_BIT)
    PORT MAP (
      CLK          => clock,
      RST          => NOT reset,  -- workaround is an synchronous high active reset!
      UART_CLK_EN  => en_serial,
      UART_RXD     => serial_data,
      DOUT         => serial_data_o,
      DOUT_VLD     => serial_data_valid_o,
      FRAME_ERROR  => OPEN,
      PARITY_ERROR => OPEN);

  serial_receiver_registers : serial_receiver_reg
    PORT MAP (
      rst_ni         => reset,
      clk_i          => clock,
      en_addr_reg_i  => en_addr_reg,
      en_data_reg_i  => en_data_reg,
      rxd_data_i     => serial_data_o,
      regfile_addr_o => regfile_addr_o,
      regfile_data_o => regfile_data_o);

  serial_receiver_state_machine : serial_receiver_fsm
    PORT MAP (
      clk                => clock,
      rst_n              => reset,
      rxd_rec            => serial_data_valid_o,
      addr               => regfile_addr_o,
      pm_checked         => pm_checked,
      en_addr_reg        => en_addr_reg,
      en_data_reg        => en_data_reg,
      en_regfile_wr      => en_regfile_wr,
      pm_control_changed => pm_control_changed);

  register_file : regfile
    GENERIC MAP (
      ADDR_WIDTH => regfile_addr_width,
      DATA_WIDTH => regfile_data_width)
    PORT MAP (
      clk_i               => clock,
      wr_en_i             => en_regfile_wr,
      w_addr_i            => regfile_addr_o,
      r_addr_i            => (OTHERS => '0'),  -- not used
      w_data_i            => regfile_data_o,
      system_control_o    => system_control_o,
      pwm_pulse_width_o   => pwm_pulse_width_o,
      pwm_period_o        => pwm_period_o,
      pwm_control_o       => pwm_control_o,
      noise_length_o      => noise_length_o,
      noise_period_o      => noise_period_o,
      noise_control_o     => noise_control_o,
      pattern_mem_depth_o => pattern_length_o,
      pattern_period_o    => pattern_period_o,
      pattern_control_o   => pattern_control_o,
      r_data_o            => OPEN);            -- not used

  -- pwm components
  pwm_freq_control : freq_control
    PORT MAP (
      clk_i    => clock,
      rst_ni   => reset,
      en_pi    => en_main AND pwm_control_o(0),
      count_o  => OPEN,
      freq_o   => pwm_freq_div,
      period_i => pwm_period_o);

  pwm_gen : pwm_generator
    PORT MAP (
      en_pi       => en_pwm_gen,
      rst_ni      => reset,
      pwm_width_i => pwm_pulse_width_o,
      clk_i       => clock,
      pwm_o       => pwm_o);

  -- noise components
  noise_freq_control : freq_control
    PORT MAP (
      clk_i    => clock,
      rst_ni   => reset,
      en_pi    => en_main AND noise_control_o(0),
      count_o  => OPEN,
      freq_o   => noise_freq_div,
      period_i => noise_period_o);

  noise_gen : noise_generator
    PORT MAP (
      clk_i                => clock,
      rst_ni               => reset,
      en_pi                => en_noise_gen,
      en_noise_generator_i => noise_control_o(0),
      noise_prbsg_length_i => noise_length_o,
      prbs_o               => prbs_o,
      noise_o              => noise_o,
      eoc_o                => eoc_o);

  -- pattern components
  pattern_freq_control : freq_control
    PORT MAP (
      clk_i    => clock,
      rst_ni   => reset,
      en_pi    => en_pattern_freq_div,
      count_o  => OPEN,
      freq_o   => pattern_freq_div,
      period_i => pattern_period_o);

  pattern_gen : pattern_generator
    PORT MAP (
      en_write_pm  => en_write_pm,
      clk_i        => clock,
      pm_control_i => pattern_control_o(1 DOWNTO 0),
      addr_cnt_i   => cntup_addr_o,
      rxd_data_i   => serial_data_o,
      pattern_o    => pattern_o);

  pattern_generator_state_machine : pattern_generator_fsm
    PORT MAP (
      clk                => clock,
      rst_n              => reset,
      rxd_rec            => serial_data_valid_o,
      tc_pm              => cntup_addr_tc,
      pm_control_changed => pm_control_changed,
      pm_control         => pattern_control_o(1 DOWNTO 0),
      addr_cnt_enabled   => en_cntup_addr,
      en_pm              => en_write_pm,
      en_pm_cnt          => en_pm_cnt,
      clr_pm_cnt         => clr_cntup_addr,
      pm_checked         => pm_checked,
      pattern_valid => pattern_valid);

  cntup_address : cntup_addr
    PORT MAP (
      clk_i  => clock,
      clr_i  => clr_cntup_addr,
      rst_ni => reset,
      en_pi  => en_cntup_addr,
      len_i  => pattern_length_o,
      q_o    => cntup_addr_o,
      tc_o   => cntup_addr_tc);

  -- basic signals connections
  clock       <= clk_i;
  reset       <= rst_ni;
  ext_trigger <= ext_trig_i;
  en_main     <= en_tsg_pi AND system_control_o(0);

  -- output signals
  rxd_rdy_o       <= serial_data_valid_o;
  tc_pm_count_o   <= cntup_addr_tc;
  pattern_valid_o <= pattern_valid;
  regfile_o       <= regfile_data_o;    -- write data
  addr_reg_o      <= std_ulogic_vector(resize(unsigned(regfile_addr_o), 8));
  data_reg_o      <= regfile_data_o;

  -- serial data connections
  en_serial   <= en_serial_i;
  serial_data <= serial_data_i;

  -- pwm connections
  en_pwm_gen <= (pwm_freq_div AND en_main AND pwm_control_o(0)) WHEN pwm_control_o(1) = '0'
                ELSE (ext_trigger AND system_control_o(0) AND pwm_control_o(0));

  -- noise connections
  en_noise_gen <= (noise_freq_div AND en_main AND noise_control_o(0)) WHEN noise_control_o(1) = '0'
                  ELSE (ext_trigger AND system_control_o(0) AND noise_control_o(0));

  -- pattern connections
  WITH pattern_control_o(1 DOWNTO 0) SELECT
    en_pattern_freq_div <= en_main WHEN "01" | "10",  -- burst or continous burst
    '0'                            WHEN "00" | "11",  -- stop or load
    '0'                            WHEN OTHERS;

  en_continous_cntup_addr <= (en_main AND en_pm_cnt AND pattern_freq_div) WHEN pattern_control_o(2) = '0'
                             ELSE (ext_trigger AND system_control_o(0) AND pattern_valid);

  WITH pattern_control_o(1 DOWNTO 0) SELECT
    en_cntup_addr <= en_pm_cnt WHEN "11",         -- load, speed of clock 
    en_continous_cntup_addr    WHEN "01" | "10",  -- burst or continous burst;
                                                  -- speed of enable
    '0'                        WHEN "00",         -- stop
    '0'                        WHEN OTHERS;

END structure;

-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------
