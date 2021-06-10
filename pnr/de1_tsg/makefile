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

SIM_PROJECT_NAME = tsg
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
../../src/binto7segment_truthtable.vhd \
../../src/cntdnmodm_rtl.vhd \
../../src/synchroniser.vhd \
../../src/a_falling_edge_detector_rtl.vhd \
../../src/e_falling_edge_detector.vhd \
../../src/sequence_detector.vhd \
../../src/alu.vhd \
../../src/$(PROJECT)_structure.vhd 

include ../makefile

## ----------------------------------------------------------------------------
## Description: 
## ------------
## assumes the following design directory structure as prerequisite
## 
## DigitaltechnikPraktikum
## |   
## +---src
## |       and2gate_equation.vhd
## |       invgate_equation.vhd
## |       mux2to1_structure.vhd
## |       or2gate_equation.vhd
## |       t_mux2to1.vhd
## |       de1_mux2to1_structure.vhd
## |
## +---sim
## |   |   makefile
## |   |
## |   \---mux2to1
## |           makefile
## |           makefile.sources
## |
## +---pnr
## |   |   makefile
## |   |
## |   \---de1_mux2to1
## |           de1_mux2to1_pins.tcl
## |           makefile
## |
## \---scripts
##         de1_pin_assignments_minimumio.csv
##         de1_pin_assignments_minimumio.tcl
##         modelsim.ini
##         quartus_project_settings.tcl
## ----------------------------------------------------------------------------
