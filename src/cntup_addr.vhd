LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity cntup_addr is
    port (
        clk_i : in std_ulogic;
        clr_i : in std_ulogic;
        en_pi : in std_ulogic;
        len_i : in std_ulogic_vector(7 downto 0);
        q_o : out std_ulogic_vector(7 downto 0);
        tc_o : out std_ulogic -- one at end of cycle 
    );
end entity cntup_addr;

architecture rtl of cntup_addr is
    
    signal current_state : unsigned(7 downto 0);

begin
    
    cntup: process(clk_i, clr_i)
    begin
        if clr_i = '1' then
            current_state <= (others => '0');
        elsif rising_edge(clk_i) and en_pi = '1' then
            if current_state = unsigned(len_i) - 1 then
                current_state <= (others => '0');
            else
                current_state <= current_state + 1;
            end if;
        end if;
    end process cntup;
   
    q_o <= std_ulogic_vector(current_state);
    tc_o <= '1' when current_state = 0 else '0';

end architecture rtl;
