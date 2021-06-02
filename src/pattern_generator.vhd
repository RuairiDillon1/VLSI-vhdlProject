library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.numeric_std.all;

entity pattern_generator is
    port (
        en_pi : in std_ulogic;
        rst_ni : in std_ulogic;
        clk_i : in std_ulogic;

        pattern_control_i : in std_ulogic_vector(2 downto 0); -- from register file

        rxd_valid_i : in std_ulogic; -- uart data valid
        rxd_data_i : in std_ulogic_vector(7 downto 0); -- uart data

        pm_control_changed_i : in std_ulogic; -- communication between state machines
        pm_checked_o : out std_ulogic; -- communication between state machines

        pattern_o : out std_ulogic_vector(7 downto 0)
    );
end entity pattern_generator;

architecture structure of pattern_generator is
    
begin
    -- instantiate cntup_addr and sp_ssram_rtl
    -- for the state machine the pattern control input 1 downto 0 is needed
    
end architecture structure;