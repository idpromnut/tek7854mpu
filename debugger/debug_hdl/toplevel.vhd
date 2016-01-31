library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
    port (  clk : in std_ulogic;        -- 50 MHz clock
            mojo_tx : out std_ulogic;       -- Debug data out to PC
            idpromnut_tx : out std_ulogic;  -- Debug data out to test header
            led : out std_ulogic );     -- Status LED
end toplevel;

architecture Behavioral of toplevel is

signal ser_wr: std_ulogic;
signal ser_ready: std_ulogic;
signal ser_ready_last: std_ulogic;
signal ser_data_in: std_ulogic_vector(7 downto 0);
signal ser_data_out: std_ulogic;

type ctrl_state is ( state_wait );
signal state: ctrl_state := state_wait;

type mem is array(0 to 26) of std_ulogic_vector(7 downto 0);
constant data_rom: mem := (
    x"4e", x"4f", x"4e", x"20",
    x"47", x"45", x"4e", x"55",
    x"49", x"4e", x"45", x"20",
    x"32", x"53", x"43", x"34",
    x"37", x"35", x"37", x"20",
    x"46", x"4f", x"55", x"4e",
    x"44", x"0d", x"0a" );

signal rom_addr: natural := 0;

begin

transmitter: entity work.serial_tx
    generic map ( clk_period => 20 ns )
    port map (
        clk => clk,
        wr => ser_wr,
        ready => ser_ready,
        data_out => ser_data_out,
        data_in => ser_data_in );

mojo_tx <= ser_data_out;
idpromnut_tx <= ser_data_out;
ser_data_in <= data_rom(rom_addr);
ser_wr <= ser_ready;
ser_ready_last <= ser_ready when rising_edge(clk);
led <= not ser_ready;

process(clk, ser_ready)
begin
    if rising_edge(clk) then
        if ser_ready = '1' and ser_ready_last = '0' then
            if rom_addr = data_rom'high then
                rom_addr <= 0;
            else
                rom_addr <= rom_addr + 1;
            end if;
        end if;
    end if;
end process;

end Behavioral;

