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
print('Serial Port initialised with the following paramters:')
print('-----------------------------------------------------')
print(ser)
print('\r')

# define time between serial transfer in seconds
wait_between_transfer = 1

# write single byte
print('Writing commands:')
print('--------------------')
print('\r')

#commands = ["system_control_enable"]
#commands = ["pwm_pulse_width", "pwm_period", "pwm_control_on_intern_trig"]
commands = ["noise_period","noise_prbsg_length_15bit", "noise_control_on_intern_trig"]

for command in commands:
    print(command)    
    ser.write(tvars.serial_vars[command])
    time.sleep(wait_between_transfer)

# send all 256 bytes in a loop
"""
print('Writing 256 single characters...')
print('--------------------------------')
for i in range(256):
    print('Sending byte: ' + hex(i) + ' '*50, end='')
    ser.write([i])
    time.sleep(wait_between_transfer)
    print('\r', end='')
print('')
"""


# end with exit code
sys.exit(0)

