| **Name**        | **Type**              | **Direction** | **Polarity** | **Description** |
|-----------------|-----------------------|:-------------:|:------------:|-----------------|
| clk_i           | std_ulogic            | IN            | HIGH         |                 |
| rst_ni          | std_ulogic            | IN            | LOW          | asynchronous reset                |
| en_tsg_pi       | std_ulogic            | IN            | HIGH         | tsg enable, used with external time base                |
| en_serial_i     | std_ulogic            | IN            | HIGH         | enable for serial data: oversample of 16 with expected baudrate 9600                |
| serial_data_i   | std_ulogic            | IN            | HIGH         | serial data with baudrate 9600                |
| rxd_rdy_o       | std_ulogic            | OUT           | HIGH         | debugging signal, output of serial_rx if serial data is ready to be read                |
| ext_trig_i      | std_ulogic            | IN            | HIGH         | external trigger for triggering test equipment                |
| pwm_o           | std_ulogic            | OUT           | HIGH         | pulse width modulated signal                |
| noise_o         | std_ulogic            | OUT           | HIGH         | 1 bit pseudo random noise                |
| prbs_o          | std_ulogic_vector[23] | OUT           | HIGH         | pseudo random noise up to 23 bit                |
| eoc_o           | std_ulogic            | OUT           | HIGH         | end of cycle when pseudo random noise repeats                |
| pattern_o       | std_ulogic_vector[8]  | OUT           | HIGH         | configurable changing pattern output                |
| pattern_valid_o | std_ulogic            | OUT           | HIGH         | pattern valid, not currently implemented! (see improvements)                |
| tc_pm_count_o   | std_ulogic            | OUT           | HIGH         | debugging signal, end of cycle for pattern memory upcounter                |
| regfile_o       | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, data input of register file                |
| addr_reg_o      | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, address output of serial_receiver registers                |
| data_reg_o      | std_ulogic_vector[8]  | OUT           | HIGH         | debugging signal, data output of serial_receiver registers                |
