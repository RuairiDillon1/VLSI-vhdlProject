## ----------------------------------------------------------------------------
## Script     : makefile
## ----------------------------------------------------------------------------
## Author     : Johann Faerber, Friedrich Beckmann
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: This makefile allows automating design flow with Quartus,
##              it is based on a design directory structure shown at 
##              the end of this file.
## ----------------------------------------------------------------------------

###################################################################
# Main Targets
#
###################################################################

help:
	@echo '"make" does intentionally nothing. Type:'
	@echo '  "make qproject" to create quartus project only'
	@echo '  "make compile" to synthesize the design'
	@echo '  "make prog" to configure programmable device'
	@echo '  "make quartus" to start quartus graphical user interface'
	@echo '  "make clean" to remove all generated files'

qproject: $(PROJECT).qpf

$(PROJECT).sdc:
	# create a default timing constraint file assuming CLOCK_50
	echo "create_clock -period 20.000 -name CLOCK_50 [get_ports CLOCK_50]" > $(PROJECT).sdc
	echo "set_input_delay -clock CLOCK_50 2 [all_inputs]" >> $(PROJECT).sdc
	echo "set_output_delay -clock CLOCK_50 2 [all_outputs]" >> $(PROJECT).sdc

$(PROJECT).qpf: $(SOURCE_FILES) ../../scripts/create_quartus_project_settings.tcl $(PROJECT)_pins.tcl $(PROJECT).sdc
	# assign VHDL design files
	rm -rf quartus_vhdl_source_files.tcl
	for source_file in $(SOURCE_FILES); do \
		echo set_global_assignment -name VHDL_FILE $$source_file >> quartus_vhdl_source_files.tcl; \
	done
	# just create a quartus project
	quartus_sh -t ../../scripts/create_quartus_project_settings.tcl -projectname $(PROJECT) -family $(FAMILY) -device $(DEVICE)

compile: $(PROJECT).qpf flowsummary.log

flowsummary.log: $(SOURCE_FILES)  
	quartus_sh -t ../../scripts/quartus_project_flow.tcl -projectname $(PROJECT) -process compile

prog: $(PROJECT).qpf flowsummary.log
	quartus_pgm -c USB-Blaster --mode jtag --operation="p;$(PROJECT).$(PROGFILEEXT)"

quartus: $(PROJECT).qpf
	# start	quartus gui
	quartus $(PROJECT).qpf &

clean:
	rm -rf *.rpt *.chg *.log quartus_vhdl_source_files.tcl *.htm *.eqn *.pin *.sof *.pof db incremental_db *.qpf *.qsf *.summary $(PROJECT).* *~

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

