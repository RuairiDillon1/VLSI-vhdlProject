## ----------------------------------------------------------------------------
## Script     : makefile
## ----------------------------------------------------------------------------
## Author(s)  : Johann Faerber, Friedrich Beckmann
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: This makefile allows automating design flow with ModelSim,
##              it is based on a design directory structure shown at 
##              the end of this file.
## ----------------------------------------------------------------------------

###################################################################
# Main Targets
#
###################################################################

help:
	@echo '"make" does intentionally nothing. Type:'
	@echo '  "make mproject" to create a new modelsim project only'
	@echo '  "make compile" to compile all VHDL sources in batch mode'
	@echo '  "make modelsim" to start modelsim with graphical user interface'
	@echo '  "make sim" to start modelsim gui with the top testbench of the project'
	@echo '  "make clean" to remove all generated files'

mproject : mproject_created

mproject_created : $(SOURCE_FILES)
	# create modelsim project
	rm -rf ./modelsim_sources.tcl
	for source_file in $(SOURCE_FILES); do \
	  echo project addfile $$source_file >> modelsim_sources.tcl; \
	done
	vsim -modelsimini ../../scripts/modelsim.ini -c -do "project new [pwd] $(PROJECT); source ./modelsim_sources.tcl; quit -f"
	touch mproject_created

compile: ./work/_vmake

./work/_vmake: mproject_created
	vsim -c -do "project open $(PROJECT); project calculateorder; quit -f"
	grep Error transcript; if [ $$? -eq 0 ] ; then rm -rf work/_vmake; exit 1; fi


modelsim: mproject_created
	vsim -i -do "project open $(PROJECT)" &

sim: ./work/_vmake
	vsim -i -do "project open $(PROJECT); vsim work.t_$(PROJECT)(tbench); add wave *; run -a;" &

clean:
	rm -rf *.mpf *.mti *.ini *.wlf wlf* transcript work modelsim_sources.tcl mproject_created

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

