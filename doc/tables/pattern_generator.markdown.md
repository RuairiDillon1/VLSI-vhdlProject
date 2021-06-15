| **Name**     | **Type**             | **Direction** | **Polarity** | **Description** |
|--------------|----------------------|:-------------:|:------------:|-----------------|
| en_write_pm  | std_ulogic           | IN            | HIGH         |                 |
| clk_i        | std_ulogic           | IN            | HIGH         |                 |
| pm_control_i | std_ulogic_vector[2] | IN            | HIGH         |                 |
| addr_cnt_i   | std_ulogic_vector[8] | IN            | HIGH         |                 |
| rxd_data_i   | std_ulogic_vector[8] | IN            | HIGH         |                 |
| pattern_o    | std_ulogic_vector[8] | OUT           | HIGH         |                 |
