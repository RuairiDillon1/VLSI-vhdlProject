LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY de1_tsg IS
  PORT (
    CLOCK_50 : IN std_ulogic;           -- 50 MHz Clock

    KEY0 : IN std_ulogic;  -- KEY[0] = rst_ni
                                             
    KEY2 : IN std_ulogic;  -- KEY[2] = ext_trig
    SW0 : IN std_ulogic;                     -- SW0=0 pattern_o LEDR[7:0]
    -- SW0=1 prbs_o LEDR[7:0]

    UART_RXD : IN std_ulogic;           -- UART_RXD = rxd_i

    LEDR : OUT std_ulogic_vector(9 DOWNTO 0);  -- LEDR[9] = pwm_o
    LEDG : OUT std_ulogic_vector(7 DOWNTO 0);  -- LEDG[7] = noise_o, [5:3]
                                               -- = ALU, [1:0] = KEY
    HEX0 : OUT std_ulogic_vector(6 DOWNTO 0);  -- register data low
    HEX1 : OUT std_ulogic_vector(6 DOWNTO 0);  -- register data high
    HEX2 : OUT std_ulogic_vector(6 DOWNTO 0);  -- register address
    HEX3 : OUT std_ulogic_vector(6 DOWNTO 0)  -- sequence count
    );
END ENTITY de1_tsg;

ARCHITECTURE structure OF de1_tsg IS

  COMPONENT tsg IS
    PORT (
      clk_i           : IN  std_ulogic;
      rst_ni          : IN  std_ulogic;
      en_tsg_pi       : IN  std_ulogic;
      en_serial_i     : IN  std_ulogic;
      serial_data_i   : IN  std_ulogic;
      rxd_rdy_o       : OUT std_ulogic;
      ext_trig_i      : IN  std_ulogic;
      pwm_o           : OUT std_ulogic;
      noise_o         : OUT std_ulogic;
      prbs_o          : OUT std_ulogic_vector(22 DOWNTO 0);
      eoc_o           : OUT std_ulogic;
      pattern_o       : OUT std_ulogic_vector(7 DOWNTO 0);
      pattern_valid_o : OUT std_ulogic;
      tc_pm_count_o   : OUT std_ulogic;
      regfile_o       : OUT std_ulogic_vector(7 DOWNTO 0);
      addr_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0);
      data_reg_o      : OUT std_ulogic_vector(7 DOWNTO 0));
  END COMPONENT tsg;

  COMPONENT cntdnmodm IS
    GENERIC (
      n : natural;
      m : natural);
    PORT (
      clk_i   : IN  std_ulogic;
      rst_ni  : IN  std_ulogic;
      en_pi   : IN  std_ulogic;
      count_o : OUT std_ulogic_vector(n-1 DOWNTO 0);
      tc_o    : OUT std_ulogic);
  END COMPONENT cntdnmodm;

  COMPONENT synchroniser IS
    PORT (
      clk_i   : IN  std_ulogic;
      rst_ni  : IN  std_ulogic;
      async_i : IN  std_ulogic;
      sync_o  : OUT std_ulogic);
  END COMPONENT synchroniser;

  COMPONENT falling_edge_detector IS
    PORT (
      clk_i  : IN  std_ulogic;
      rst_ni : IN  std_ulogic;
      x_i    : IN  std_ulogic;
      fall_o : OUT std_ulogic);
  END COMPONENT falling_edge_detector;

  COMPONENT sequence_detector IS
    PORT (
      clk    : IN  std_ulogic;
      rst_n  : IN  std_ulogic;
      ser_i  : IN  std_ulogic;
      done_o : OUT std_ulogic);
  END COMPONENT sequence_detector;

  COMPONENT alu IS
    PORT (
      a_i   : IN  std_ulogic_vector(2 DOWNTO 0);
      b_i   : IN  std_ulogic_vector(2 DOWNTO 0);
      sel_i : IN  std_ulogic_vector(1 DOWNTO 0);
      y_o   : OUT std_ulogic_vector(2 DOWNTO 0));
  END COMPONENT alu;

  COMPONENT binto7segment IS
    PORT (
      bin_i      : IN  std_ulogic_vector(3 DOWNTO 0);
      segments_o : OUT std_ulogic_vector(6 DOWNTO 0));
  END COMPONENT binto7segment;

  -- basic signals
  SIGNAL clk_i         : std_ulogic;
  SIGNAL rst_ni        : std_ulogic;
  SIGNAL en_tsg_pi     : std_ulogic;
  SIGNAL en_serial_i   : std_ulogic;
  SIGNAL serial_data_i : std_ulogic;
  SIGNAL ext_trig_i    : std_ulogic;

  SIGNAL en_seq_cnt  : std_ulogic;
  SIGNAL count_value : unsigned(3 DOWNTO 0);
  
  signal pwm : std_ulogic;
  signal noise : std_ulogic;
  signal prbs : std_ulogic_vector(22 downto 0);
  signal pattern : std_ulogic_vector(7 downto 0);
  signal addr_reg : std_ulogic_vector(7 downto 0);
  signal data_reg : std_ulogic_vector(7 downto 0);

BEGIN

  test_signal_generator : tsg
    PORT MAP (
      clk_i           => clk_i,
      rst_ni          => rst_ni,
      en_tsg_pi       => en_tsg_pi,
      en_serial_i     => en_serial_i,
      serial_data_i   => serial_data_i,
      rxd_rdy_o       => OPEN,
      ext_trig_i      => ext_trig_i,
      pwm_o           => pwm,
      noise_o         => noise,
      prbs_o          => prbs,
      eoc_o           => OPEN,
      pattern_o       => pattern,
      pattern_valid_o => OPEN,
      tc_pm_count_o   => OPEN,
      regfile_o       => OPEN,
      addr_reg_o      => addr_reg,
      data_reg_o      => data_reg);

  time_base : cntdnmodm                 -- 10 MHz
    GENERIC MAP (
      n => 4,
      m => 5)
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => '1',
      count_o => OPEN,
      tc_o    => en_tsg_pi);

  baud_oversample : cntdnmodm           -- baudrate 9600 with 50MHz clock
    GENERIC MAP (
      n => 9,
      m => 326)
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      en_pi   => '1',
      count_o => OPEN,
      tc_o    => en_serial_i);

  sync : synchroniser
    PORT MAP (
      clk_i   => clk_i,
      rst_ni  => rst_ni,
      async_i => UART_RXD,
      sync_o  => serial_data_i);

  external_trigger : falling_edge_detector
    PORT MAP (
      clk_i  => clk_i,
      rst_ni => rst_ni,
      x_i    => KEY2,
      fall_o => ext_trig_i);

  seq_detector : sequence_detector
    PORT MAP (
      clk    => clk_i,
      rst_n  => rst_ni,
      ser_i  => noise,
      done_o => en_seq_cnt);

  arithmetic : alu
    PORT MAP (
      a_i   => pattern(2 DOWNTO 0),
      b_i   => pattern(5 DOWNTO 3),
      sel_i => pattern(7 DOWNTO 6),
      y_o   => LEDG(5 DOWNTO 3));

  HEX_0 : binto7segment                 -- register data low
    PORT MAP (
      bin_i      => data_reg(3 DOWNTO 0),
      segments_o => HEX0);

  HEX_1 : binto7segment                 -- register data high
    PORT MAP (
      bin_i      => data_reg(7 DOWNTO 4),
      segments_o => HEX1);

  HEX_2 : binto7segment                 -- register address
    PORT MAP (
      bin_i      => addr_reg(3 DOWNTO 0),
      segments_o => HEX2);

  HEX_3 : binto7segment                 -- sequence count
    PORT MAP (
      bin_i      => std_ulogic_vector(count_value),
      segments_o => HEX3);

  clk_i            <= CLOCK_50;
  rst_ni           <= KEY0;
  LEDG(1 DOWNTO 0) <= KEY2 & KEY0;

  counter : count_value <= to_unsigned(0, 4) WHEN rst_ni = '0'  -- sequence counter
                           ELSE count_value + 1 WHEN rising_edge(clk_i) AND en_seq_cnt = '1';

  LEDR(9) <= pwm;
  LEDG(7) <= noise;

  LEDR(7 DOWNTO 0) <= pattern(7 DOWNTO 0) WHEN SW0 = '0'
                      ELSE prbs(7 DOWNTO 0);

  LEDR(8) <= '0';
  LEDG(6) <= '0';
  LEDG(2) <= '0';

END ARCHITECTURE structure;
