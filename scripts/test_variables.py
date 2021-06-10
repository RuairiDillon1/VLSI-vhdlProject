# name of function | address byte | data byte
serial_vars = {
    "system_status_noise_eoc" : bytearray.fromhex("00  40"),
    "system_status_pattern_eop" : bytearray.fromhex("00  80"),

    "system_control_disable" : bytearray.fromhex("01 00"),
    "system_control_enable" : bytearray.fromhex("01  01"),
    "system_control_sys_clear1" : bytearray.fromhex("01  02"),
    "system_control_sys_clear2" : bytearray.fromhex("01  03"),
    
    "pwm_pulse_width" : bytearray.fromhex("04 ff"),
    "pwm_period" : bytearray.fromhex("05 ff"),
    
    "pwm_control_off" : bytearray.fromhex("04 00"),
    "pwm_control_on_intern_trig" : bytearray.fromhex("04 01"),
    "pwm_control_on_extern_trig" : bytearray.fromhex("04 02"),

    "noise_prbsg_length_4bit" : bytearray.fromhex("08 00"),
    "noise_prbsg_length_7bit" : bytearray.fromhex("08 01"),
    "noise_prbsg_length_15bit" : bytearray.fromhex("08 02"),
    "noise_prbsg_length_17bit" : bytearray.fromhex("08 03"),
    "noise_prbsg_length_20bit" : bytearray.fromhex("08 04"),
    "noise_prbsg_length_23bit" : bytearray.fromhex("08 05"),
,
    
    "noise_period" : bytearray.fromhex("09 ff"),
    
    "noise_control_off" : bytearray.fromhex("0b 00"),
    "noise_control_on_intern_trig" : bytearray.fromhex("0b 01"),
    "noise_control_on_extern_trig" : bytearray.fromhex("0b 02"),

    
    "pattern_length" : bytearray.fromhex("0c ff"),
    "pattern_period" : bytearray.fromhex("0e ff"),
    "pattern_period_20" : bytearray.fromhex("0e 14"),
    "pattern_period_50" : bytearray.fromhex("0e 32"),

    "pattern_intern_control_stop" : bytearray.fromhex("0f 00"),
    "pattern_intern_control_single_burst" : bytearray.fromhex("0f 01"),
    "pattern_intern_control_continous_run" : bytearray.fromhex("0f 02"),
    "pattern_intern_control_load" : bytearray.fromhex("0f 03"),
    "pattern_extern_control_stop" : bytearray.fromhex("0f 04"),
    "pattern_extern_control_single_burst" : bytearray.fromhex("0f 05"),
    "pattern_extern_control_continous_run" : bytearray.fromhex("0f 06"),
    "pattern_extern_control_load" : bytearray.fromhex("0f 07"),
}
