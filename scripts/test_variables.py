# name of function | data byte | address byte
serial_vars = {
    "system_status_noise_eoc" : bytearray.fromhex("40  00"),
    "system_status_pattern_eop" : bytearray.fromhex("80 00"),

    "system_control_disable" : bytearray.fromhex("00 01"),
    "system_control_enable" : bytearray.fromhex("01  01"),
    "system_control_sys_clear1" : bytearray.fromhex("02  01"),
    "system_control_sys_clear2" : bytearray.fromhex("03  01"),
    
    "pwm_pulse_width" : bytearray.fromhex("ff 04"),
    "pwm_period" : bytearray.fromhex("ff 05"),
    
    "pwm_control_off" : bytearray.fromhex("00 04"),
    "pwm_control_on_intern_trig" : bytearray.fromhex("01 04"),
    "pwm_control_on_extern_trig" : bytearray.fromhex("02 04"),

    "noise_prbsg_length_4bit" : bytearray.fromhex("00 08"),
    "noise_prbsg_length_7bit" : bytearray.fromhex("01 08"),
    "noise_prbsg_length_15bit" : bytearray.fromhex("02 08"),
    "noise_prbsg_length_17bit" : bytearray.fromhex("03 08"),
    "noise_prbsg_length_20bit" : bytearray.fromhex("04 08"),
    "noise_prbsg_length_23bit" : bytearray.fromhex("05 08"),
,
    
    "noise_period" : bytearray.fromhex("ff 09"),
    
    "noise_control_off" : bytearray.fromhex("00 0b"),
    "noise_control_on_intern_trig" : bytearray.fromhex("01 0b"),
    "noise_control_on_extern_trig" : bytearray.fromhex("02 0b"),

    
    "pattern_length" : bytearray.fromhex("ff 0c"),
    "pattern_period" : bytearray.fromhex("ff 0e"),
    "pattern_period_20" : bytearray.fromhex("14 0e"),
    "pattern_period_50" : bytearray.fromhex("32 0e"),

    "pattern_intern_control_stop" : bytearray.fromhex("00 0f"),
    "pattern_intern_control_single_burst" : bytearray.fromhex("01 0f"),
    "pattern_intern_control_continous_run" : bytearray.fromhex("02 0f"),
    "pattern_intern_control_load" : bytearray.fromhex("03 0f"),
    "pattern_extern_control_stop" : bytearray.fromhex("04 0f"),
    "pattern_extern_control_single_burst" : bytearray.fromhex("05 0f"),
    "pattern_extern_control_continous_run" : bytearray.fromhex("06 0f"),
    "pattern_extern_control_load" : bytearray.fromhex("06 0f"),
}
