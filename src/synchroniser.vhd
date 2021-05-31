entity synchroniser is
    port (
        clk_i : in std_ulogic;
        rst_ni : in std_ulogic;
        async_i : in std_ulogic;
        sync_o : out std_ulogic
    );
end entity synchroniser;

architecture rtl of synchroniser is
    
    signal ff1_i, ff2_i : std_ulogic;
    signal ff1_o, ff2_o : std_ulogic;

begin
    
    sync: process(clk_i, rst_ni)
    begin
        if rst_ni = '0' then
            ff1_o <= '0';
            ff2_o <= '0';
        elsif rising_edge(clk_i) then
            ff1_o <= ff1_i;
            ff2_o <= ff2_i;
        end if;
    end process sync;
    
    ff1_i <= async_i;
    ff2_i <= ff1_o;

    sync_o <= ff2_o;

end architecture rtl;