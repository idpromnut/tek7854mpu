library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_tx is
generic( 
    baud: time := 104.167 us;   -- 9600
    width: natural := 8;        -- 8 data bits
    stop_bits: natural := 1;    -- 1 stop bit
    clk_period: time );
port(
    data_in: in std_ulogic_vector(width-1 downto 0);
    data_out: out std_ulogic;
    ready: out std_ulogic;
    wr: in std_ulogic;
    clk: in std_ulogic );
end serial_tx;


architecture behavioral of serial_tx is

    type tx_state is ( state_init, state_startbit, state_tx_data, state_stopbits );
    signal state: tx_state := state_init;

    signal bits_transmitted: natural := 0;

    signal data_shift_reg: std_ulogic_vector(width-1 downto 0);

    signal baud_divider: natural := 0;
    signal baud_clk_edge: std_ulogic := '0';

    signal tx_out: std_ulogic;

begin

-- Baud rate generator
process(clk)
    constant div_top: natural := (baud / clk_period);
begin
    if rising_edge(clk) then
        if baud_divider = div_top then
            baud_divider <= 0;
        else
            baud_divider <= baud_divider + 1;
        end if;
        if baud_divider = (div_top / 2) then
            baud_clk_edge <= '1';
        else
            baud_clk_edge <= '0';
        end if;
    end if;
end process;

data_out <= tx_out;

-- Main transmitter
process(clk, data_in, wr, state)
begin

    if rising_edge(clk) then
        case state is
            when state_init =>
                data_shift_reg <= data_in;
                bits_transmitted <= 0;
                tx_out <= '1';
                ready <= '1';
                if wr = '1' and baud_clk_edge = '1' then
                    state <= state_startbit;
                else
                    state <= state_init;
                end if;

            when state_startbit =>
                bits_transmitted <= 0;
                tx_out <= '0';
                ready <= '0';
                if baud_clk_edge = '1' then
                    state <= state_tx_data;
                else
                    state <= state_startbit;
                end if;

            when state_tx_data =>
                tx_out <= data_shift_reg(0);
                ready <= '0';
                if baud_clk_edge = '1' then
                    data_shift_reg(width-2 downto 0) <= data_shift_reg(width-1 downto 1);
                    if bits_transmitted = width - 1 then
                        state <= state_stopbits;
                        bits_transmitted <= 0;
                    elsif stop_bits > 0 then
                        state <= state_tx_data;
                        bits_transmitted <= bits_transmitted + 1;
                    else
                        state <= state_init;
                        bits_transmitted <= 0;
                    end if;

                else
                    state <= state_tx_data;
                    bits_transmitted <= bits_transmitted;
                    data_shift_reg <= data_shift_reg;
                end if;

            when state_stopbits =>
                tx_out <= '1';
                ready <= '0';
                if bits_transmitted = stop_bits - 1 and baud_clk_edge = '1' then
                    state <= state_init;
                    bits_transmitted <= 0;
                elsif baud_clk_edge = '1' then
                    state <= state_stopbits;
                    bits_transmitted <= bits_transmitted + 1;
                else
                    state <= state_stopbits;
                    bits_transmitted <= bits_transmitted;
                end if;
        end case;

    end if;
end process;

end behavioral;
