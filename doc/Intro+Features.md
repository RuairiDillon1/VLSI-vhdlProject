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
These features are key to the TSG as they are utilised in many commercially available TSGs as such they are included in this TSG. 

### Serial Transmission
Utilising UART serial transmission allows for a large range of data to be transferred between the TSG and the subject system. It allows for the TSG to be given Parallel inputs and then communicate using serial transmission  which can then be returned to a parallel data type for the target system to utilise.


### Single pulse with variable duty cycle and frequency.
Utilising Pulse width modulation a series of digitally controlled electrical signals can be sent allowing for a spectrum of both peak voltage and high frequency testing within a single module.

### Digital noise based on pseudo random binary sequences of different length.
Ustilsing LFSRs to generate a string of pseudo random binary that is then sent along the UART transmission lines to the subject board. It allows for the subject system's ability to handle junk data as well as other highly variable data types.   

### Arbitrary data bus sequences at selectable speed.
Utilising digital pattern generators to create arbitrary data busses that can then be sent using UART to a subject board. As the output of this system is arbitrary it allows for the clarity of transmissions that are sent to the subject board. 

### Internal/External Trigger.
Internal and external triggers allow for the TSG to be triggered by internally set rules or received data from the test subject system allowing for specific internal rules to be set up. External triggers allow for specific targeted stimulus to be produced by the TSG meaning that any of the above test types can be used with a high level of precision.  

### External Time Base
An external time base allows for the entire TSG to be configured based on the system to be tested by the TSG system. As well as allowing for the TSG to be run at a different clock rate to the tested system.
