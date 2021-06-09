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
      rst_ni         : in  std_ulogic;
      clk_i          : in  std_ulogic;
      en_addr_reg_i  : in  std_ulogic;
      en_data_reg_i  : in  std_ulogic;
      rxd_data_i     : in  std_ulogic_vector(7 downto 0);
      regfile_addr_o : out std_ulogic_vector(3 downto 0);
      regfile_data_o : out std_ulogic_vector(7 downto 0));
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
  
BEGIN

  -- basic signals
  SIGNAL clk_i : std_ulogic;
  SIGNAL rst_ni :std_ulogic;
  SIGNAL en_tsg_pi : std_ulogic;
  SIGNAL ext_trig_i : std_ulogic;

  -- serial signals
  SIGNAL en_serial_i : std_ulogic;
  SIGNAL serial_data_i : std_ulogic;

  -- serial components instantiation

  CONSTANT CLK_DIV_VAL : integer := 16;
  constant PARITY_BIT: string := "none";
  CONSTANT regfile_addr_width: integer := 4;
  CONSTANT regfile_data_width: integer := 8;
  
  serial_rx_uart: serial_rx
    GENERIC MAP (
      CLK_DIV_VAL => CLK_DIV_VAL,
      PARITY_BIT  => PARITY_BIT)
    PORT MAP (
      CLK          => clk_i,
      RST          => NOT rst_ni, -- workaround is an synchronous high active reset!
      UART_CLK_EN  => en_serial_i,
      UART_RXD     => serial_data_i,
      DOUT         => DOUT,
      DOUT_VLD     => DOUT_VLD,
      FRAME_ERROR  => open,
      PARITY_ERROR => open);

  serial_receiver_registers: serial_receiver_reg
    PORT MAP (
      rst_ni         => rst_ni,
      clk_i          => clk_i,
      en_addr_reg_i  => en_addr_reg_i,
      en_data_reg_i  => en_data_reg_i,
      rxd_data_i     => rxd_data_i,
      regfile_addr_o => regfile_addr_o,
      regfile_data_o => regfile_data_o);

  serial_receiver_state_machine: serial_receiver_fsm
    PORT MAP (
      clk                => clk_i,
      rst_n              => rst_ni,
      rxd_rec            => rxd_rec,
      addr               => addr,
      pm_checked         => pm_checked,
      en_addr_reg        => en_addr_reg,
      en_data_reg        => en_data_reg,
      en_regfile_wr      => en_regfile_wr,
      pm_control_changed => pm_control_changed);

  register_file: regfile
    GENERIC MAP (
      ADDR_WIDTH => regfile_addr_width,
      DATA_WIDTH => regfile_data_width)
    PORT MAP (
      clk_i               => clk_i,
      wr_en_i             => wr_en_i,
      w_addr_i            => w_addr_i,
      r_addr_i            => (OTHERS => '0'), -- not used
      w_data_i            => w_data_i,
      system_control_o    => system_control_o,
      pwm_pulse_width_o   => pwm_pulse_width_o,
      pwm_period_o        => pwm_period_o,
      pwm_control_o       => pwm_control_o,
      noise_length_o      => noise_length_o,
      noise_period_o      => noise_period_o,
      noise_control_o     => noise_control_o,
      pattern_mem_depth_o => pattern_mem_depth_o,
      pattern_period_o    => pattern_period_o,
      pattern_control_o   => pattern_control_o,
      r_data_o            => open); -- not used


  -- basic signals connections
  clk_i <= clk_i;
  rst_ni <= rst_ni;
  en_tsg_pi <= en_tsg_pi;
  ext_trig_i <= ext_trig_i;

  -- serial data connections
  en_serial_i <= en_serial_i;
  serial_data_i <= serial_data_i;
  
END structure;

-------------------------------------------------------------------------------
-- Revisions:
-- ----------
-- $Id:$
-------------------------------------------------------------------------------
