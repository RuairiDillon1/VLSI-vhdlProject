## ----------------------------------------------------------------------------
## Script     : makefile
## ----------------------------------------------------------------------------
## Author     : Johann Faerber, Friedrich Beckmann
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: This makefile allows automating design flow with Quartus,
##              it is based on a design directory structure described in 
##              ../makefile
## ----------------------------------------------------------------------------

###################################################################
# Project Configuration: 
#
# - assign variable SIM_PROJECT_NAME with the top level project name
# - add additional VHDL sources to SOURCE_FILES, if necessary
#
# Prerequisite: 
#   - mandatory design directory structure (see end of file)
#   - assumes file name of top level entity de1_$(PROJECT)_structure.vhd
###################################################################

SIM_PROJECT_NAME = cntdnmodm
PROJECT = de1_$(SIM_PROJECT_NAME)

# Prototype Board FPGA family and device settings
# DE1
FAMILY = "Cyclone II"
DEVICE = EP2C20F484C7
PROGFILEEXT = sof
# DEMMK
# FAMILY = "MAX II"
# DEVICE = EPM2210F324C3
# PROGFILEEXT = pof
# DE2
#FAMILY = "Cyclone II"
#DEVICE = EP2C35F484C7
#PROGFILEEXT = sof
# DE0
#FAMILY = "Cyclone IV E"
#DEVICE = EP4CE22F17C6
#PROGFILEEXT = sof

# Here the VHDL files for synthesis are defined. 
include ../../sim/$(SIM_PROJECT_NAME)/makefile.sources

# Add the toplevel fpga vhdl file
SOURCE_FILES = $(SYN_SOURCE_FILES) \
../../src/$(PROJECT)_structure.vhd

include ../makefile


