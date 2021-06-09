# name of function | address byte | data byte
serial_vars = {
    "system_control" : bytearray.fromhex("01 03"), 
    
    "pwm_pulse_width" : bytearray.fromhex("04 ff"),
    "pwm_period" : bytearray.fromhex("05 ff"),
    "pwm_control" : bytearray.fromhex("04 03"),
    
    "noise_prbsg_length" : bytearray.fromhex("08 ff"),
    "noise_period" : bytearray.fromhex("09 ff"),
    "noise_control" : bytearray.fromhex("0b 03"),
    
    "pattern_length" : bytearray.fromhex("0c ff"),
    "pattern_data" : bytearray.fromhex("0d ff"),
    "pattern_period" : bytearray.fromhex("0e ff"),
    "pattern_control" : bytearray.fromhex("0f 07"),
}
