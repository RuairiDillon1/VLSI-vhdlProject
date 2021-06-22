# General Description

![Test Signal Generator Schematic Symbol](images/tsg.png){width=40%}

| **Name**        | **Type**              | **Direction** | **Polarity** | **Description** |
|-----------------|-----------------------|:-------------:|:------------:|-----------------|
| clk_i           | std_ulogic            | IN            | HIGH         | clock                |
| rst_ni          | std_ulogic            | IN            | LOW          | asynchronous reset                |
| en_tsg_pi       | std_ulogic            | IN            | HIGH         | external time base                |
| en_serial_i     | std_ulogic            | IN            | HIGH         | oversample of 16, baudrate 9600                |
| serial_data_i   | std_ulogic            | IN            | HIGH         | serial data, baudrate 9600                |
| rxd_rdy_o       | std_ulogic            | OUT           | HIGH         | debugging signal, serial data ready to read                |
| ext_trig_i      | std_ulogic            | IN            | HIGH         | external trigger                |
| pwm_o           | std_ulogic            | OUT           | HIGH         | pwm signal                |
| noise_o         | std_ulogic            | OUT           | HIGH         | 1 bit pseudo random noise                |
| prbs_o          | std_ulogic_vector[23] | OUT           | HIGH         | pseudo random noise up to 23 bit                |
| eoc_o           | std_ulogic            | OUT           | HIGH         | end of cycle of pseudo random noise               |
| pattern_o       | std_ulogic_vector[8]  | OUT           | HIGH         | pattern output                |
| pattern_valid_o | std_ulogic            | OUT           | HIGH         | pattern valid |
| tc_pm_count_o   | std_ulogic            | OUT           | HIGH         | debugging signal, end of cycle pm upcounter                |
| regfile_o       | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, data input register file                |
| addr_reg_o      | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, address output serial register
| data_reg_o      | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, data output serial registers                |

: Test Signal Generator - Description of I/O Signals

The test signal generator with its multiple I/Os can be broken down into 4 distinctive parts:
- serial data handling
- pulse width modulation generator
- pattern generator
- random noise generator

![Test Signal Generator Breakup Drawing](images/breakup_tsg.png){width=100%}
In the picture above you can recognize that the register file is the central part of the design. 
The register file receives data from the serial communication and writes them into its memory. Depending on the values in the 
memory the output components are controlled. 

The register file has the following memory view.
```pure
		  					 Bit7  ..         0
------------------------------------------------
Address  	Name 				7 6 5 4 3 2 1 0
------------------------------------------------
0x00 
0x01  		system control 					x x
0x02
0x03
0x04     	pwm pulse width 	x x x x x x x x
0x05 		pwm period 			x x x x x x x x
0x06 		pwm control 					x x
0x07
0x08 		noise prbsg length 	x x x x x x x x
0x09 		noise period 		x x x x x x x x
0x0A
0x0B 		noise control 					x x
0x0C 		pattern length 		x x x x x x x x
0x0D 
0x0E 		pattern period 		x x x x x x x x
0x0F 		pattern control 			  x x x
```

The meaning of the control parts of the registers is explained in the following.
```pure
system control
---------------------------
Bit 0 Meaning
------------------------
	0 system disable
	1 system enable
---------------------------
Bit 1 Meaning
---------------------------
	1 system clear [synchronous clear](not currently implemented see improvements!)


pwm control
---------------------------
Bit 0 Meaning
--------------------------
	0 pwm off
	1 pwm on
---------------------------
Bit 1 Meaning
---------------------------
	0 internal trigger
	1 external trigger


noise prbsg length
-----------------------------------------
Bit 7 6 5 4 3 2 1 0 Meaning
-----------------------------------------
			  0 0 0 4-bit
			  0 0 1 7-bit 8B/10B-encoded pattern
			  0 1 0 15-bit ITU-T O.150
			  0 1 1 17-bit OIF-CEI-P-02.0
			  1 0 0 20-bit ITU-T O.150
			  1 0 1 23-bit ITU-T O.150

noise control
---------------------------
Bit 0 Meaning
---------------------------
	0 noise off
	1 noise on
---------------------------
Bit 1 Meaning
---------------------------
	0 internal trigger
	1 external trigger

pattern control
---------------------------
Bit 1 0 Meaning
---------------------------
	0 0 stop
	0 1 single burst
	1 0 continous run
	1 1 load data
---------------------------
Bit 2 Meaning
---------------------------
	0 internal trigger
	1 external trigger
```
Now the control part of the register will be explained in further detail. 
The system has an general enable "system control" which must be switched on 
to switch on all individual components (noise, pattern, pwm). All components 
allow for external triggering where you can change the state manually by pressing 
a button. When not specified the components run with the speed of the external time 
base which is further divided by the individual period settings. All three components 
have the same frequency divider component. The divided frequency can be calculated by the following formula:

$divided~frequency=\frac{frequency~of~external~time~base}{period~register~value+1}$
## Pwm component
![Pwm implementation](images/pwm_implementation.png){width=100%}
With the implemented pwm component a duty cycle of 0%-99,6% percent is possible. It
can be computed by $duty~cycle=\frac{pwm~pulse~width}{256}$. One counting cycle is performed 
with the frequency of the divided frequency. This results in a frequency of $\frac{divided~frequency}{256}$.
## Noise component
The noise component has an noise prbsg length and a period setting. The prbsg setting decides how many bits the 
lfsr has. That means it decides over the length of the pseudo random sequence until it repeats itself. They are designed 
after the given standards of pseudo random number generators and have different use cases. For more information about it 
see the standard documentations. One full cycle 
has the frequency of $\frac{divided~frequency}{2^{n}-1}$ with $n$ as the number of bits of the lfsr.
## Pattern component
The pattern generator has four possible control states:
- stop
  - the pattern generator is switched off
- load
  - the pattern generator is ready to receive the data sequence into its memory
  - before sending the number sequence the number of values must be specified in the pattern length register!
    - e.g. pattern length 4 -> pattern load -> pattern sequence 4 5 7 2 -> single burst/continous run
- single burst
  - a single burst puts out the sequence only once
- continous run
  - puts out the sequence forever
  - stops when the pattern control bits change 
One value of a sequence is available for the time of $\frac{1}{divided~frequency}$. A full cycle that includes 
all values has the frequency of $\frac{divided~frequency}{pattern~length}$.

## External time base and external triggering design
![Noise/PWM enable and external trigger design](images/noise_pwm_en.png){width=100%}
To get the external time base and external triggering to work correctly multiple AND gates and multiplexer are needed.
For the pwm and the noise generator we have the same design. If the noise generator is enabled depends on 
the following conditions:
- the whole system is enabled
- pwm/noise generator is enabled
- external time base on
- frequency divider enabled
When the external triggering of the noise/pwm generator is enabled it should only be controlled by external triggering
if the system is on and the pwm/noise generator is enabled.

![Pattern enable and external trigger design](images/pattern_en.png){width=100%}
For the pattern generator a more sophisticated system is needed. We need to differentiate between the four modes of our 
pattern generator:
- 00 stop
- 01 single burst
- 10 continous run
- 11 load

In stop and load mode we do not care about the external triggering and the external time base. When loading the pattern generator the
address upcounter only counts up when the pattern generator state machine gives an signal. Note that the address upcounter decides over the frequency of the pattern output, not the pattern generator (pattern memory) itself. The external trigger, external time base 
and frequency divider matters when we are in the two run modes. For the external triggering we need the additional signal pattern valid.
This signal is provided by the pattern generator state machine and is true when the state machine is in a counting state. This is needed 
for the single burst mode to stop counting after one counting cycle.

# Further improvements

## System control register

In the system control register is a bit included to do an synchronous clear over serial communication. It adds another possibility to 
reset the states of the synchronous components. At the moment only the asynchronous reset is available. To add this functionality 
an synchronous reset needs to be added to every component except the memory components (register file, pattern generator) and the address upcounter (has already one).

## Pwm switch off

When the pwm module is switched off either by the system control or the pwm control the counters in the frequency control and pwm 
generator are kept in their current counting state. This could result in an constant output of a one. To solve this problem it is 
recommended to put in a switch in the pwm generator that puts out zero when the system control AND pwm control is zero. This approach 
is already implemented for the noise generator and can be implemented in the same way (see input en_noise_generator_i).

## Testbench tsg and de1_tsg

With the fix in the serial receiver state machine (states at beginning) that solve the issue of data valid signal after reset a 
different problem occurred. In the real system the fix works but in the simulation this scenario does not happen. We have an 
immediate one after the reset and not a zero and then the pulse of the data like in the real system. A possible fix is to add an 
additional state to the state machine. 

![State Machine Fix](images/state_machine_fix.png){width=50%}

## More test scenarios

The pattern generator was not evaluated on the oscilloscope. It was only tested manually with the external trigger, were it worked correctly (burst mode and continous run). That means it needs to be tested if the frequency in the automatic mode is correct.

# Application Note
![Wiring on DE1 Altera Board](images/de1_tsg.png){width=100%}
The wiring of the DE1 Board can be seen in the picture above. The test signal generator runs with an 50 MHz clock and a time base of 
10 MHz on the enable. An synchroniser is added before the serial input to avoid metavalues because of asynchronous serial communication from the pc.
The outputs of the test signal generator were connected to test components ALU and a 101 sequence detector. On the HEX3 display the
number of 101 sequences detected is shown. Additionally some outputs are connected to the GPIOs
for measurements. For the connections see ```de1_tsg_structure.vhd```.
![Connected components on DE1 Altera Board](images/de1_tsg_wiring.png){width=100%}

## Data received after reset
![Data out valid after reset](images/rxd_rdy_after_reset.png){width=50%}
The two states at the beginning of the serial receiver state machine are required to work around a problem that the serial rx component 
creates. After a reset the serial rx component puts out a data valid signal for one cycle. This seems to be a design problem (see tsg testbench at the beginning: DIN_VLD). 
Without these states we have the issue that after an reset we would immediately transition to the state were we are waiting for the 
data. We are skipping the address states. For that reason the first two states are added.