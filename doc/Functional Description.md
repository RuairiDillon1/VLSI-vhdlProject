Functional Description
======================

## UART serial communication
UART(Universal asynchronous receiver/transmitter) communication is a common form of data communication between electronic devices. It communicated the data serially in the form of digital signals.

![UART Example- Schematic](images/uart_sample.png){width=80%}

UART communication has some characteristics that need to be considered for implementation.
The signal begins with the start bit (in the form of a high signal), the next in the sequence comes the data bits, the number of data bits is configurable and is dependent on the parameterisation(,namely if you send a parity bit) of the serial modules. After the data sequence is complete, UART protocol then instructs you to send a stop bit, which is again a high signal.
Due to the asynchronous nature of this communication method it requires a baud rate for the transfer to be configured. 
The baud rate is described as the rate of information transfer in a given communication channel. This is the main parameter regarding UART that will need to be considered during implementation as the transmitter will be generating a bitstream that is based on the sending device's clock signal whereas the receiver will be using its internal clock signal to sample the incoming data. The point of synchronization is managed by having the same baud rate on both devices. Failure to do so may affect the timing of sending and receiving data that can cause discrepancies during data handling. The common allowable difference of baud rate is up to 10% before the timing of bits gets too far off to be considered usable.



## Digital pattern generator

![Expected output of the pattern generator](images/pattern_output_wavedrom.png){width=100%}

Digital Pattern Generators are a common way of creating signals for testing.
Theoretically the Pattern Generator should allow the user to output a configurable pattern with either internal triggering rules or the use of an external trigger.
The pattern can take various shapes, including standard pulses or outputting larger bit patterns depending on the system configuration.
As a point of safety these digital pattern generators, due to them modifying the voltage level that is being input to an I/O pin, are often designed to be compatible with the wide range of digital electronics standards. These being TTL, LVTTL, LVCMOS and LVDS,these standards are important as they will overall limit what the digital pattern generators output. As the output signal will be limited in both the voltages it can use and the transition characteristics of the signal.

## Pulse-width modulation
Pulse Width Modulation (PWM) is a type of digital signal that has many uses for real world applications. It is a way in which you can digitally control some analog devices.

![PWM Example - Schematic](images/PWM_Explained.png){width=80%}

PWM functions by switching between low and high signals to the requested amounts by the user. For each cycle, the signal will be high for the requested percentage. This is known as the Duty Cycle.

$Period=\frac{1}{f}$

$Period=T_{on}+T_{off}$

$DutyCycle=\frac{T_{on}}{T_{on}+T_{off}}\times100$
PWMs as part of their operation reduce the average voltage and current feed to the test system. This is another peraminter concern for the TSG. This is as some components may have a minimum voltage needed for activation as part of the test system. This may cause false negatives depending on how the test system has been configured or constructed. It is also considered to be a good method of testing in industry as it has very low power dissipation.

## Pseudo-random number generator (LFSR)
Linear Feedback Shift Registers is a configuration of registers used in conjunction with an XOR gate to create a function dependent on it's previous state.

![LFSR Exampled - Schematic](images/4bit_lfsr_xor.png){width=80%}

By continually shifting to the right and going through the XOR gate, it generates a series of random numbers. However, because the register has a finite number of possible states, it must eventually enter a repeating cycle. 

The number of cycles until the pseudo random number generator repeats himself is:
  $number~of~cycles = 2^{n} -1$

With $n$ as number of bits.
However, because the register has a finite number of possible states, it must eventually enter a repeating cycle. However, if the LFSR has a well-chosen feedback function it can produce an output sequence of bits that appears to be random and has a very long cycle time.
