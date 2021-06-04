library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serial_receiver is
    port (
        en_pi : in std_ulogic;
        rst_ni : in std_ulogic;
        clk_i : in std_ulogic;

        rxd_valid_i : in std_ulogic; -- uart data valid
        rxd_data_i : in std_ulogic_vector(7 downto 0); -- uart data

        pm_checked_i : in std_ulogic; -- communication between state machines
        pm_control_changed_o : out std_ulogic; -- communication between state machines

        regfile_addr_o : out std_ulogic_vector(3 downto 0);
        regfile_data_o : out std_ulogic_vector(7 downto 0);
        en_regfile_wr_o : out std_ulogic
    );
end entity serial_receiver;

architecture structure of serial_receiver is
    
begin

  addr_register : regfile_addr_o <= zero WHEN rst_ni = '0' ELSE
    rxd_data_i WHEN rising_edge(clk_i) AND (en_pi = '1');


 data__register : regfile_data_o <= zero WHEN rst_ni = '0' ELSE
    rxd_data_i WHEN rising_edge(clk_i) AND (en_pi = '1');

    
end architecture structure;
