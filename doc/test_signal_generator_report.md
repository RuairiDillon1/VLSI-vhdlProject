[comment] : <> (this is a direct adoptation from lab 7 vlsi heartbeat gen) RD

Introduction
============

Digital test signal generators (TSG) are a type of external measurement equipment that are available from several different vendors. These pieces of equipment produce a range of electrical stimuli signals that can be used to check the operation of other electrical devices. The goal of this module is to produce an on-chip version of this system with the following essential features included in the architecture and design:
• Single pulse with variable duty cycle and frequency.
• Digital noise based on pseudo random binary sequences of different length.
• Arbitrary data bus sequences at selectable speed.
• Internal/External Trigger.
• External Time Base.
Each of these features are necessary for the TSG to produce a dataset that can be used to give an engineer an informative viewpoint on their design so that they can modify it so that it lands within specification.


Features
========
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam mollis condimentum sem consectetur ultrices. Cras malesuada porttitor nisl euismod imperdiet. Pellentesque risus sem, iaculis eu aliquet sit amet, porta ut augue. Etiam libero tortor, suscipit vel suscipit ut, accumsan id lorem. Proin vel leo a dolor facilisis viverra vitae vel tellus. Pellentesque vestibulum, nunc vel gravida condimentum, erat quam eleifend quam, quis volutpat ex erat sit amet ante. Nulla porta ligula at tortor varius fringilla. Mauris sed sceler
General Description
===================

- description of tsg and split up view of tsg, register file configuration


![Heartbeat Generator - Schematic Symbol](images/heartbeat_gen_symbol.pdf){width=40%}

| **Name**       | **Type**          | **Direction** | **Polarity** | **Description**     |
|----------------|-------------------|:-------------:|:------------:|---------------------|
| clk_i          | std_ulogic        | IN            | HIGH         | clock               |
| rx_i           | std_ulogic        | IN            | HIGH         | serial data recieve |
| en_tsg_pi      | std_ulogic        | IN            | HIGH         | enable              |
| test_signals_o | std_ulogic_vector | OUT           | HIGH         | test signal output  |
|                |                   |               |              |                     |


: Test Signal Generator - Description of I/O Signals


Functional Description
======================

- describe what pwm, lfsr and uart is

## UART serial communication
A universal asynchronous receiver/transmitter (UART) is a block of circuitry responsible for implementing 
serial communication. Essentially, the UART acts as an intermediary between parallel and 
serial interfaces. Communication between devices in this project is executed using UART.



## Pattern generator

## Pulse-width modulation
Pulse width modulators are a vital and commonly found tool found in industry for control. 
It is significant due to the fact it allows a digital signal to control analog devices.

## Pseudo-random number generator (LFSR)

The shape of an [electrogardiogramm](https://en.wikipedia.org/wiki/Electrocardiography) as a voltage graph over time



![Electrocardiogram](images/ECG-SinusRhythmLabel.png){width=20%}

The important QRS complex and T wave are modelled as digital pulses.

![QRS Complex and T Wave Pulses](images/qrs-complex-t-wave-pulses.pdf){width=80%}


Design Description
==================

- component implementations

## Register file

$ x = y $

![Implemented Register File - Schematic](images/regfile.png){width=80%}

| **Name**            | **Type**                      | **Direction** | **Polarity** | **Description** |
|---------------------|-------------------------------|:-------------:|:------------:|-----------------|
| clk_i               | std_ulogic                    | IN            | HIGH         |                 |
| wr_en_i             | std_ulogic                    | IN            | HIGH         |                 |
| w_addr_i            | std_ulogic_vector[ADDR_WIDTH] | IN            | HIGH         |                 |
| r_addr_i            | std_ulogic_vector[ADDR_WIDTH] | IN            | HIGH         |                 |
| w_data_i            | std_ulogic_vector[DATA_WIDTH] | IN            | HIGH         |                 |
| system_control_o    | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| pwm_pulse_width_o   | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pwm_period_o        | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pwm_control_o       | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| noise_length_o      | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| noise_period_o      | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| noise_control_o     | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| pattern_mem_depth_o | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pattern_period_o    | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pattern_control_o   | std_ulogic_vector[3]          | OUT           | HIGH         |                 |
| r_data_o            | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |


| **Name**   | **Type** | **Default value** |
|------------|----------|-------------------|
| ADDR_WIDTH | integer  | 4                 |
| DATA_WIDTH | integer  | 8                 |

```vhdl
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY regfile IS
  GENERIC(
    ADDR_WIDTH : integer := 4;
    DATA_WIDTH : integer := 8
    );
  PORT(
    clk_i               : IN  std_ulogic; -- system clock in
    wr_en_i             : IN  std_ulogic; -- write enable in
    w_addr_i            : IN  std_ulogic_vector (ADDR_WIDTH-1 DOWNTO 0);
    r_addr_i            : IN  std_ulogic_vector (ADDR_WIDTH-1 DOWNTO 0);
    w_data_i            : IN  std_ulogic_vector (DATA_WIDTH-1 DOWNTO 0);
    -- system_status_reg_i  : IN  std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    system_control_o    : OUT std_ulogic_vector(1 DOWNTO 0);
    pwm_pulse_width_o   : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0); 
    pwm_period_o        : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    pwm_control_o       : OUT std_ulogic_vector(1 DOWNTO 0);
    noise_length_o      : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    noise_period_o      : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    noise_control_o     : OUT std_ulogic_vector(1 DOWNTO 0);
    pattern_mem_depth_o : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0); -- pattern_length
    -- pattern_data_o      : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    pattern_period_o    : OUT std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
    pattern_control_o   : OUT std_ulogic_vector(2 DOWNTO 0);
    r_data_o            : OUT std_ulogic_vector (DATA_WIDTH-1 DOWNTO 0)
    );
END regfile;

ARCHITECTURE rtl OF regfile IS
  TYPE array_2d_t IS ARRAY (0 TO 2**ADDR_WIDTH-1) OF
    std_ulogic_vector(DATA_WIDTH-1 DOWNTO 0);
  SIGNAL array_reg : array_2d_t;
BEGIN
  PROCESS(clk_i)
  BEGIN
    IF rising_edge(clk_i) THEN
      IF wr_en_i = '1' THEN
        array_reg(to_integer(unsigned(w_addr_i))) <= w_data_i;
      END IF;
    END IF;
  END PROCESS;

  system_control_o    <= array_reg(1)(1 DOWNTO 0);
  pwm_pulse_width_o   <= array_reg(4);
  pwm_period_o        <= array_reg(5);
  pwm_control_o       <= array_reg(6)(1 DOWNTO 0);
  noise_length_o      <= array_reg(8);
  noise_period_o      <= array_reg(9);
  noise_control_o     <= array_reg(11)(1 DOWNTO 0);
  pattern_mem_depth_o <= array_reg(12);
  -- pattern_data_o      <= array_reg(13);
  pattern_period_o    <= array_reg(14);
  pattern_control_o   <= array_reg(15)(2 DOWNTO 0);

-- read port
  r_data_o <= array_reg(to_integer(unsigned(r_addr_i)));
END rtl;vhdl
```

## UART serial receiver

![Implemented Serial Reciever File - Schematic](images/serial_rx.png){width=80%}

| **Name**     | **Type**             | **Direction** | **Polarity** | **Description** |
|--------------|----------------------|:-------------:|:------------:|-----------------|
| CLK          | std_ulogic           | IN            | HIGH         |                 |
| RST          | std_ulogic           | IN            | HIGH         |                 |
| UART_CLK_EN  | std_ulogic           | IN            | HIGH         |                 |
| UART_RXD     | std_ulogic           | IN            | HIGH         |                 |
| DOUT         | std_ulogic_vector[8] | OUT           | HIGH         |                 |
| DOUT_VLD     | std_ulogic           | OUT           | HIGH         |                 |
| FRAME_ERROR  | std_ulogic           | OUT           | HIGH         |                 |
| PARITY_ERROR |                      | OUT           | HIGH         |                 |


| **Name**    | **Type** | **Default value** |
|-------------|----------|-------------------|
| CLK_DIV_VAL | integer  | 16                |
| PARITY_BIT  | string   | "none"            |


## Pattern generator

![Implemented Pattern Generator File - Schematic](images/pattern_generator.png){width=80%}

| **Name**     | **Type**             | **Direction** | **Polarity** | **Description** |
|--------------|----------------------|:-------------:|:------------:|-----------------|
| en_write_pm  | std_ulogic           | IN            | HIGH         |                 |
| clk_i        | std_ulogic           | IN            | HIGH         |                 |
| pm_control_i | std_ulogic_vector[2] | IN            | HIGH         |                 |
| addr_cnt_i   | std_ulogic_vector[8] | IN            | HIGH         |                 |
| rxd_data_i   | std_ulogic_vector[8] | IN            | HIGH         |                 |
| pattern_o    | std_ulogic_vector[8] | OUT           | HIGH         |                 |


## Pulse-width modulation

![Implemented PWM File - Schematic](images/pwm_generator.png){width=80%}

| **Name**    | **Type**             | **Direction** | **Polarity** | **Description** |
|-------------|----------------------|:-------------:|:------------:|-----------------|
| en_pi       | std_ulogic           | IN            | HIGH         |                 |
| rst_ni      | std_ulogic           | IN            | LOW          |                 |
| pwm_width_i | std_ulogic_vector[8] | IN            | HIGH         |                 |
| clk_i       | std_ulogic           | IN            | HIGH         |                 |
| pwm_o       | std_ulogic           | OUT           | HIGH         |                 |


## Pseudo-random number generator (LFSR)

## Enable and external triggering

A conceptional RTL diagram is shown below.

![Heartbeat Generator - Conceptional RTL](images/heartbeat_gen_conceptional_rtl.pdf){width=60%}

The simulation result shows two full periods based on a clock period of 1 ms

![Two Periods - Simulation Result](images/heartbeat_gen_two_periods_simwave.png){width=80%}

In more detail using cursors to display correct parameters of the QRS complex and T wave.

![QRS-Complex and T-Wave - Simulation Result](images/qrs-complex-t-wave_simwave.png){width=80%}



Device Utilization and Performance
==================================

The following table shows the utilisation of both modules heartbeat_gen and cntdnmodm.

```pure
+--------------------------------------------------------------------------------------+
; Fitter Summary                                                                       ;
+------------------------------------+-------------------------------------------------+
; Fitter Status                      ; Successful - Wed Mar 31 11:50:15 2021           ;
; Quartus II 32-bit Version          ; 13.0.1 Build 232 06/12/2013 SP 1 SJ Web Edition ;
; Revision Name                      ; de1_heartbeat_gen                               ;
; Top-level Entity Name              ; de1_heartbeat_gen                               ;
; Family                             ; Cyclone II                                      ;
; Device                             ; EP2C20F484C7                                    ;
; Timing Models                      ; Final                                           ;
; Total logic elements               ; 50 / 18,752 ( < 1 % )                           ;
;     Total combinational functions  ; 50 / 18,752 ( < 1 % )                           ;
;     Dedicated logic registers      ; 26 / 18,752 ( < 1 % )                           ;
; Total registers                    ; 26                                              ;
; Total pins                         ; 15 / 315 ( 5 % )                                ;
; Total virtual pins                 ; 0                                               ;
; Total memory bits                  ; 0 / 239,616 ( 0 % )                             ;
; Embedded Multiplier 9-bit elements ; 0 / 52 ( 0 % )                                  ;
; Total PLLs                         ; 0 / 4 ( 0 % )                                   ;
+------------------------------------+-------------------------------------------------+
```

```pure

+----------------------------------------------------------------------------------------+
; TimeQuest Timing Analyzer Summary                                                      ;
+--------------------+-------------------------------------------------------------------+
; Quartus II Version ; Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition ;
; Revision Name      ; de1_heartbeat_gen                                                 ;
; Device Family      ; Cyclone II                                                        ;
; Device Name        ; EP2C20F484C7                                                      ;
; Timing Models      ; Final                                                             ;
; Delay Model        ; Combined                                                          ;
; Rise/Fall Delays   ; Unavailable                                                       ;
+--------------------+-------------------------------------------------------------------+

-----------------------------------------+
; Clocks                                 ; 
+------------+------+--------+-----------+
; Clock Name ; Type ; Period ; Frequency ;
+------------+------+--------+-----------+
; CLOCK_50	 ; Base ; 20.000 ; 50.0 MHz	 ;
+------------+------+--------+-----------+


+-----------------------------------------------------------------------------+
; Multicorner Timing Analysis Summary                                         ;
+------------------+-------+-------+----------+---------+---------------------+
; Clock            ; Setup ; Hold  ; Recovery ; Removal ; Minimum Pulse Width ;
+------------------+-------+-------+----------+---------+---------------------+
; Worst-case Slack ; 3.390 ; 0.241 ; 13.381   ; 3.796   ; 8.889               ;
;  CLOCK_50        ; 3.390 ; 0.241 ; 13.381   ; 3.796   ; 8.889               ;
; Design-wide TNS  ; 0.0   ; 0.0   ; 0.0      ; 0.0     ; 0.0                 ;
;  CLOCK_50        ; 0.000 ; 0.000 ; 0.000    ; 0.000   ; 0.000               ;
+------------------+-------+-------+----------+---------+---------------------+
```

Application Note
================

- de1 tsg description

The following test environment on a DE1 prototype board uses a system clock frequency of 50 MHz.
A prescaler is parameterised to generate an output signal with a period of 1 ms.

![Test Environment on DE1 Prototype Board](images/de1_heartbeat_gen_schematic.pdf){width=70%}



Appendix
========

References
----------

* [Wiki: Electrocardiography](https://en.wikipedia.org/wiki/Electrocardiography)

Project Hierarchy
-----------------

### Module Hierarchy for Verification

```pure
t_heartbeat_gen(tbench)
  heartbeat_gen(rtl)
```

### Prototype Environment

```pure
de1_heartbeat_gen(structure)
  heartbeat_gen(rtl)
  cntdnmodm(rtl)
```

VHDL Sources
------------

```vhdl
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY heartbeat_gen IS
  PORT (clk_i   : IN  std_ulogic;
        rst_ni  : IN  std_ulogic;
        en_pi   : IN  std_ulogic;
        count_o : OUT std_ulogic_vector;
        heartbeat_o : OUT std_ulogic
        );
END heartbeat_gen;
```

```vhdl
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ARCHITECTURE rtl OF heartbeat_gen IS

  CONSTANT n    : natural                := 10;
  CONSTANT zero : unsigned(n-1 DOWNTO 0) := (OTHERS => '0');

  CONSTANT heartbeat_period : unsigned(n-1 DOWNTO 0) := to_unsigned(833, n);
  CONSTANT qrs_width        : unsigned(n-1 DOWNTO 0) := to_unsigned(100, n);
  CONSTANT st_width
  CONSTANT t_width
  CONSTANT qt_width

  SIGNAL next_state, current_state : unsigned(n-1 DOWNTO 0);

  SIGNAL tc_qrs                    : std_ulogic;  -- qrs interval
  SIGNAL tc_t                      : std_ulogic;  -- T wave

BEGIN

  next_state_logic : 
                     


  state_register : 
                   

  -- output_logic
  t_wave : tc_t <= 
                   
                   
                   
  qrs_complex : tc_qrs <= 
                          

  output_value : heartbeat_o <= 


END rtl;
```

Revision History
----------------

| **Date**  | **Version**  | **Change Summary**  |
|:----------|:-------------|:--------------------|
| May 2020  | 0.1  | Initial Release  |
| April 2021  | 0.2  | Added parameterisation  |

