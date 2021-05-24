## ----------------------------------------------------------------------------
## Script     : makefile
## ----------------------------------------------------------------------------
## Author     : Johann Faerber, Friedrich Beckmann
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: This makefile allows automating design flow with ModelSim,
##              it is based on a design directory structure described in 
##              ../makefile
## ----------------------------------------------------------------------------

###################################################################
# Project Configuration: 
#
# assign variable PROJECT with the top level project name
#
# Prerequisite: 
#   - mandatory design directory structure (see end of file)
#   - assumes file name of testbench t_$(PROJECT).vhd
###################################################################

PROJECT = cntdnmodm

include ./makefile.sources

# Add here the testbench file
SOURCE_FILES = $(SYN_SOURCE_FILES) \
../../src/t_$(PROJECT).vhd

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

