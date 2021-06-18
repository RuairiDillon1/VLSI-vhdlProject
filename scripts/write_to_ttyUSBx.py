#!/usr/bin/python3

# Prerequsites:
# -------------

# Installation of operating system tools
# --------------------------------------
# check available tty ports
# sudo apt install usbutils
# lsusb

# Installation of python packages:
# --------------------------------
# sudo apt install python3-pip
# pip3 install serial
# pip3 install pyserial

import sys
import time
import serial

import test_variables as tvars


# check which ttyUSBx port is available
# tbd ...


# configure port parameters
# if an error occurs, check try /dev/ttyUSB1
ser = serial.Serial(
    port='/dev/ttyUSB0',\
    baudrate=9600,\
    parity='N',\
    stopbits=1,\
    bytesize=8,\
    timeout=None)

# print serial port configuration
print('Serial Port initialised with the following parameters:')
print('-----------------------------------------------------')
print(ser)
print('\r')

# define time between serial transfer in seconds
wait_between_transfer = 0.5

print('Writing commands:')
print()
print("{:50s} | {}".format("command", "(address | data) or pattern sequence hex"))
print(100*"-")

commands = ["system_control_enable"]
#commands = ["system_control_disable", "noise_control_off", "pwm_control_off", "pattern_control_stop"]
#commands = ["pwm_pulse_width_1", "pwm_period_max","pwm_control_on_intern_trig"]
#commands = ["pwm_pulse_width_1", "pwm_period_min","pwm_control_on_intern_trig"]
#commands = ["noise_period_max","noise_prbsg_length_7bit", "noise_control_on_extern_trig"]
#commands = ["pattern_length_4", "pattern_period_max", "pattern_control_load", "pattern_example_sequence_4", "pattern_extern_control_continous_run"]

for command in commands:
    print("{:50s} | {}".format(command, tvars.serial_vars[command].hex()))    
    ser.write(tvars.serial_vars[command])
    time.sleep(wait_between_transfer)

# end with exit code
sys.exit(0)

