## ----------------------------------------------------------------------------
## Script     : create_quartus_project_settings.tcl
## ----------------------------------------------------------------------------
## Author     : Johann Faerber, F. Beckmann
## Company    : University of Applied Sciences Augsburg
## ----------------------------------------------------------------------------
## Description: create a quartus project with default settings for device, 
##              unused pins, ...
##              expects project name as command line parameter 
##              e.g.
##              quartus_sh -t create_quartus_project_settings.tcl -projectname de1_mux2to1
##                         -family "Cyclone II" -device EP2C20F484C7
## ----------------------------------------------------------------------------
## Revisions  : see end of file
## ----------------------------------------------------------------------------

package require cmdline
# Load Quartus II Tcl Project package
package require ::quartus::project

# ----------------------------------------------------------------------------
# Declare command line parameters
# ----------------------------------------------------------------------------
set parameters {
    {projectname.arg ""   "Project Name"}
	{family.arg ""   "FPGA Family"}
	{device.arg ""   "FPGA Device"}
}
array set arg [::cmdline::getoptions argv $parameters]

# ----------------------------------------------------------------------------
# Verify required paramters
# ----------------------------------------------------------------------------
set requiredParameters {projectname family device}
foreach parameter $requiredParameters {
    if {$arg($parameter) == ""} {
        puts stderr "Missing required parameter: -$parameter"
        exit 1
    }
}


	# ----------------------------------------------------------------------------
	# Create project
	# ----------------------------------------------------------------------------
	project_new $arg(projectname) -overwrite
	
	# ----------------------------------------------------------------------------
	# Assign family, device, and top-level file
	# ----------------------------------------------------------------------------
	set_global_assignment -name FAMILY $arg(family)
	set_global_assignment -name DEVICE $arg(device)
	
	# ----------------------------------------------------------------------------
	# Default settings
	# ----------------------------------------------------------------------------
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	
	# ----------------------------------------------------------------------------
	# Design files
	# ----------------------------------------------------------------------------
	#set_global_assignment -name VHDL_FILE ../src/e_cntdnmodm.vhd
	#set_global_assignment -name VHDL_FILE ../src/a_cntdnmodm_rtl.vhd
    source quartus_vhdl_source_files.tcl
	
	# ----------------------------------------------------------------------------
	# Pin Assignments
	# ----------------------------------------------------------------------------
	# set_location_assignment PIN_L1 -to CLOCK_50
	source $arg(projectname)_pins.tcl 

	# ----------------------------------------------------------------------------
	# Close project
	# ----------------------------------------------------------------------------
	project_close


## ----------------------------------------------------------------------------
## Revisions:
## ----------
## $Id:$
## ----------------------------------------------------------------------------
