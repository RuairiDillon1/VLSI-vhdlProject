## ----------------------------------------------------------------------------
## Script     : makefile
## ----------------------------------------------------------------------------
## Author     : Johann Faerber
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: This makefile allows automating documentation process
##              based on markdown and pandoc 
##              
## ----------------------------------------------------------------------------

###################################################################
# Definitions
#
###################################################################
PROJECT = test_signal_generator

DATASHEET_YAML = datasheet.yaml
REPORT_YAML = report.yaml
PRESENTATION_YAML = presentation.yaml

###################################################################
# Main Targets
#
###################################################################

help:
	@echo '"make" does intentionally nothing. Type:'
	@echo '  "make datasheet" to create a datasheet'
	@echo '  "make report" to create a report'
	@echo '  "make presentation" to create a presentation'
	@echo '  "make clean" to remove all generated files'


datasheet: $(PROJECT)_datasheet.md
	pandoc --template uasa_meng_vlsi_template.tex $(DATASHEET_YAML) $(PROJECT)_datasheet.md -o $(PROJECT)_datasheet.pdf   --highlight-style tango


report: $(PROJECT)_report.md
	pandoc --template uasa_meng_vlsi_template.tex $(REPORT_YAML) $(PROJECT)_report.md -o $(PROJECT)_report.pdf   --highlight-style tango --number-sections


presentation: $(PROJECT)_presentation.md
	pandoc -t beamer  --template uasa_meng_vlsi_template.tex $(PRESENTATION_YAML) $(PROJECT)_presentation.md -o $(PROJECT)_presentation.pdf



clean:
	rm -rf $(PROJECT)_datasheet.pdf $(PROJECT)_report.pdf $(PROJECT)_presentation.pdf

## ----------------------------------------------------------------------------
## Description: 
## ------------
## assumes the following design directory structure as prerequisite
## 
## project
## |
## |-- makefile
## |
## +-- doc/
## |     |-- stepper_motor_controller_datasheet.md
## |     |-- stepper_motor_controller_datasheet.pdf
## |     |-- stepper_motor_controller_report.md
## |     |-- stepper_motor_controller_report.pdf
## |     |-- stepper_motor_controller_presentation.md
## |     |-- stepper_motor_controller_presentation.pdf
## |     |-- ...
## |     |
## |     +-- images
## |           |-- smctrl_modes.fodg
## |           |-- smctrl_modes.png
## |           |-- smctrl_modes_simwave.png
## |           |-- wave_drive_timing.pdf
## |           |-- wave_drive_timing.svg
## |           |-- ...
## |
## ----------------------------------------------------------------------------

