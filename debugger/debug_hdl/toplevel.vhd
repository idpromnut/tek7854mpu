library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
    port (  clk : in std_ulogic;        -- 50 MHz clock
            led : out std_ulogic );     -- Status LED
end toplevel;

architecture Behavioral of toplevel is

signal counter: unsigned(24 downto 0) := (others => '0');

begin

led <= counter(24);

process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1;
    end if;
end process;

end Behavioral;

