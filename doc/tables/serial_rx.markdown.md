| **Name**     | **Type**             | **Direction** | **Polarity** | **Description** |
|--------------|----------------------|:-------------:|:------------:|-----------------|
| CLK          | std_ulogic           | IN            | HIGH         |                 |
| RST          | std_ulogic           | IN            | HIGH         |                 |
| UART_CLK_EN  | std_ulogic           | IN            | HIGH         |                 |
| UART_RXD     | std_ulogic           | IN            | HIGH         |                 |
| DOUT         | std_ulogic_vector[8] | OUT           | HIGH         |                 |
| DOUT_VLD     | std_ulogic           | OUT           | HIGH         |                 |
| FRAME_ERROR  | std_ulogic           | OUT           | HIGH         |                 |
| PARITY_ERROR |                      | OUT           | HIGH         |                 |


| **Name**    | **Type** | **Default value** |
|-------------|----------|-------------------|
| CLK_DIV_VAL | integer  | 16                |
| PARITY_BIT  | string   | "none"            |
