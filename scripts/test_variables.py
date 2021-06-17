# name of function | address byte | data byte
serial_vars = {
    "system_control_disable" : bytearray.fromhex("01 00"),
    "system_control_enable" : bytearray.fromhex("01 01"),
    "system_control_sys_clear1" : bytearray.fromhex("01 02"), # note: system clear not implemented at the moment
    "system_control_sys_clear2" : bytearray.fromhex("01 03"),
    
    
    "pwm_pulse_width_1" : bytearray.fromhex("04 01"),
    
    "pwm_period_max" : bytearray.fromhex("05 ff"),
    "pwm_period_min" : bytearray.fromhex("05 00"),
    
    "pwm_control_off" : bytearray.fromhex("06 00"),
    "pwm_control_on_intern_trig" : bytearray.fromhex("06 01"),
    "pwm_control_on_extern_trig" : bytearray.fromhex("06 03"),


    "noise_prbsg_length_4bit" : bytearray.fromhex("08 00"),
    "noise_prbsg_length_7bit" : bytearray.fromhex("08 01"),
    "noise_prbsg_length_15bit" : bytearray.fromhex("08 02"),
    "noise_prbsg_length_17bit" : bytearray.fromhex("08 03"),
    "noise_prbsg_length_20bit" : bytearray.fromhex("08 04"),
    "noise_prbsg_length_23bit" : bytearray.fromhex("08 05"),
    
    "noise_period_max" : bytearray.fromhex("09 ff"),
    
    "noise_control_off" : bytearray.fromhex("0b 00"),
    "noise_control_on_intern_trig" : bytearray.fromhex("0b 01"),
    "noise_control_on_extern_trig" : bytearray.fromhex("0b 03"),

    
    "pattern_length_4" : bytearray.fromhex("0c 04"),
    
    "pattern_period_max" : bytearray.fromhex("0e ff"),
    "pattern_period_20" : bytearray.fromhex("0e 14"),
    "pattern_period_50" : bytearray.fromhex("0e 32"),
    "pattern_example_sequence_4" : bytearray.fromhex("08 04 02 01"), # sequence only

    "pattern_control_stop" : bytearray.fromhex("0f 00"),
    "pattern_control_load" : bytearray.fromhex("0f 03"),
    "pattern_intern_control_single_burst" : bytearray.fromhex("0f 01"),
    "pattern_intern_control_continous_run" : bytearray.fromhex("0f 02"),
    "pattern_extern_control_single_burst" : bytearray.fromhex("0f 05"),
    "pattern_extern_control_continous_run" : bytearray.fromhex("0f 06")
}
