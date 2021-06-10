LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY noise_generator IS
  PORT (
    clk_i                : IN  std_ulogic;
    rst_ni               : IN  std_ulogic;
    en_pi                : IN  std_ulogic;
    noise_prbsg_length_i : IN  std_ulogic_vector(7 DOWNTO 0);
    prbs_o               : OUT std_ulogic_vector(22 DOWNTO 0);
    noise_o              : OUT std_ulogic;
    eoc_o                : OUT std_ulogic
    );
END ENTITY noise_generator;

ARCHITECTURE structure OF noise_generator IS

  COMPONENT config_noise_generator IS
    GENERIC (
      num_of_bits : natural;
      tap_high    : natural;
      tap_low     : natural);
    PORT (
      en_pi   : IN  std_ulogic;
      clk_i   : IN  std_ulogic;
      rst_ni  : IN  std_ulogic;
      prbs_o  : OUT std_ulogic_vector(num_of_bits - 1 DOWNTO 0);
      noise_o : OUT std_ulogic;
      eoc_o   : OUT std_ulogic);
  END COMPONENT config_noise_generator;

  CONSTANT idx_4bit  : natural := 0;
  CONSTANT idx_7bit  : natural := 1;
  CONSTANT idx_15bit : natural := 2;
  CONSTANT idx_17bit : natural := 3;
  CONSTANT idx_20bit : natural := 4;
  CONSTANT idx_23bit : natural := 5;

  SIGNAL en  : std_ulogic;
  SIGNAL ens : std_ulogic_vector(5 DOWNTO 0);
  SIGNAL clk : std_ulogic;
  SIGNAL rst : std_ulogic;

  SIGNAL prbs4_o  : std_ulogic_vector(3 DOWNTO 0);
  SIGNAL prbs7_o  : std_ulogic_vector(6 DOWNTO 0);
  SIGNAL prbs15_o : std_ulogic_vector(14 DOWNTO 0);
  SIGNAL prbs17_o : std_ulogic_vector(16 DOWNTO 0);
  SIGNAL prbs20_o : std_ulogic_vector(19 DOWNTO 0);
  SIGNAL prbs23_o : std_ulogic_vector(22 DOWNTO 0);
  SIGNAL prbs_us  : unsigned(22 DOWNTO 0);  -- for resize to work temporary signal

  SIGNAL noises : std_ulogic_vector (5 DOWNTO 0);
  SIGNAL noise  : std_ulogic;

  SIGNAL eocs : std_ulogic_vector(5 DOWNTO 0);
  SIGNAL eoc  : std_ulogic;

BEGIN

  noise_generator_4 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 4,
      tap_high    => 4,
      tap_low     => 3)
    PORT MAP (
      en_pi   => ens(idx_4bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs4_o,
      noise_o => noises(idx_4bit),
      eoc_o   => eocs(idx_4bit));

  noise_generator_7 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 7,
      tap_high    => 7,
      tap_low     => 6)
    PORT MAP (
      en_pi   => ens(idx_7bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs7_o,
      noise_o => noises(idx_7bit),
      eoc_o   => eocs(idx_7bit));

  noise_generator_15 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 15,
      tap_high    => 15,
      tap_low     => 14)
    PORT MAP (
      en_pi   => ens(idx_15bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs15_o,
      noise_o => noises(idx_15bit),
      eoc_o   => eocs(idx_15bit));

  noise_generator_17 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 17,
      tap_high    => 17,
      tap_low     => 14)
    PORT MAP (
      en_pi   => ens(idx_17bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs17_o,
      noise_o => noises(idx_17bit),
      eoc_o   => eocs(idx_17bit));

  noise_generator_20 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 20,
      tap_high    => 20,
      tap_low     => 17)                -- also available with 3
    PORT MAP (
      en_pi   => ens(idx_20bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs20_o,
      noise_o => noises(idx_20bit),
      eoc_o   => eocs(idx_20bit));

  noise_generator_23 : config_noise_generator
    GENERIC MAP (
      num_of_bits => 23,
      tap_high    => 23,
      tap_low     => 18)
    PORT MAP (
      en_pi   => ens(idx_23bit),
      clk_i   => clk,
      rst_ni  => rst,
      prbs_o  => prbs23_o,
      noise_o => noises(idx_23bit),
      eoc_o   => eocs(idx_23bit));

  -- every time there is a change in signals in the process sensitivity list, all
  -- of the sequential statements in the process are re-evaluated
  switch : PROCESS(noise_prbsg_length_i, en, eocs, noises,
                   prbs4_o, prbs7_o, prbs15_o, prbs17_o, prbs20_o, prbs23_o)
  BEGIN
    CASE noise_prbsg_length_i IS
      WHEN "00000000" =>
        prbs_us <= resize(unsigned(prbs4_o), prbs_o'length);
        noise   <= noises(idx_4bit);
        eoc     <= eocs(idx_4bit);
        ens     <= (idx_4bit => en, OTHERS => '0');
      WHEN "00000001" =>
        prbs_us <= resize(unsigned(prbs7_o), prbs_o'length);
        noise   <= noises(idx_7bit);
        eoc     <= eocs(idx_7bit);
        ens     <= (idx_7bit => en, OTHERS => '0');
      WHEN "00000010" =>
        prbs_us <= resize(unsigned(prbs15_o), prbs_o'length);
        noise   <= noises(idx_15bit);
        eoc     <= eocs(idx_15bit);
        ens     <= (idx_15bit => en, OTHERS => '0');
      WHEN "00000011" =>
        prbs_us <= resize(unsigned(prbs17_o), prbs_o'length);
        noise   <= noises(idx_17bit);
        eoc     <= eocs(idx_17bit);
        ens     <= (idx_17bit => en, OTHERS => '0');
      WHEN "00000100" =>
        prbs_us <= resize(unsigned(prbs20_o), prbs_o'length);
        noise   <= noises(idx_20bit);
        eoc     <= eocs(idx_20bit);
        ens     <= (idx_20bit => en, OTHERS => '0');
      WHEN "00000101" =>
        prbs_us <= resize(unsigned(prbs23_o), prbs_o'length);
        noise   <= noises(idx_23bit);
        eoc     <= eocs(idx_23bit);
        ens     <= (idx_23bit => en, OTHERS => '0');
      WHEN OTHERS =>
        prbs_us <= (OTHERS => '0');
        noise   <= '0';
        eoc     <= '0';
        ens     <= (OTHERS => '0');
    END CASE;
  END PROCESS switch;

  clk     <= clk_i;
  rst     <= rst_ni;
  en      <= en_pi;
  prbs_o  <= std_ulogic_vector(prbs_us);
  noise_o <= noise;
  eoc_o   <= eoc;

END ARCHITECTURE structure;
