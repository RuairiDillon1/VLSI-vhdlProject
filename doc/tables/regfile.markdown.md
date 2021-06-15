| **Name**            | **Type**                      | **Direction** | **Polarity** | **Description** |
|---------------------|-------------------------------|:-------------:|:------------:|-----------------|
| clk_i               | std_ulogic                    | IN            | HIGH         |                 |
| wr_en_i             | std_ulogic                    | IN            | HIGH         |                 |
| w_addr_i            | std_ulogic_vector[ADDR_WIDTH] | IN            | HIGH         |                 |
| r_addr_i            | std_ulogic_vector[ADDR_WIDTH] | IN            | HIGH         |                 |
| w_data_i            | std_ulogic_vector[DATA_WIDTH] | IN            | HIGH         |                 |
| system_control_o    | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| pwm_pulse_width_o   | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pwm_period_o        | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pwm_control_o       | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| noise_length_o      | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| noise_period_o      | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| noise_control_o     | std_ulogic_vector[2]          | OUT           | HIGH         |                 |
| pattern_mem_depth_o | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pattern_period_o    | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |
| pattern_control_o   | std_ulogic_vector[3]          | OUT           | HIGH         |                 |
| r_data_o            | std_ulogic_vector[DATA_WIDTH] | OUT           | HIGH         |                 |


| **Name**   | **Type** | **Default value** |
|------------|----------|-------------------|
| ADDR_WIDTH | integer  | 4                 |
| DATA_WIDTH | integer  | 8                 |
