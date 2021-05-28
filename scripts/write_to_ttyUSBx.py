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
wait_between_transfer = 0.1

# write single byte
print('Writing single byte:')
print('--------------------')
print('\r')
ser.write([0])
time.sleep(wait_between_transfer)
ser.write([15])


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

