library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
end uart_tb;

architecture behave of uart_tb is
  constant c_CLK_PERIOD : time := 10 ns; -- 100 MHz
  constant c_CLKS_PER_BIT : integer := 87; -- Number of clock cycles per bit this is calculated as 10 ns / (1/115200) = 87

  signal r_Clk : std_logic := '0';
  signal w_Tx_Serial : std_logic;

  -- TX Signals
  signal r_Tx_Dv   : std_logic := '0';
  signal r_Tx_Byte : std_logic_vector(7 downto 0) := (others => '0');
  signal w_Tx_Active : std_logic;
  signal w_Tx_Done   : std_logic;

  -- RX Signals
  signal w_Rx_Dv   : std_logic;
  signal w_Rx_Byte : std_logic_vector(7 downto 0);

begin
  -- Clock Generator
  r_Clk <= not r_Clk after c_CLK_PERIOD/2;


  UART_TX_INST : entity work.uart_tx
    generic map (g_CLKS_PER_BIT => c_CLKS_PER_BIT)
    port map (
      i_clk       => r_Clk,
      i_tx_dv     => r_Tx_Dv,
      i_tx_byte   => r_Tx_Byte,
      o_tx_active => w_Tx_Active,
      o_tx_serial => w_Tx_Serial,
      o_tx_done   => w_Tx_Done
    );

  -- Instantiate UART Receiver
  UART_RX_INST : entity work.uart_rx
    generic map (g_CLKS_PER_BIT => c_CLKS_PER_BIT)
    port map (
      i_clk       => r_Clk,
      i_rx_serial => w_Tx_Serial,
      o_rx_dv     => w_Rx_Dv,
      o_rx_byte   => w_Rx_Byte
    );

    -- Main Stimulus Process
      p_TEST : process
      begin
        wait until rising_edge(r_Clk);
        wait until rising_edge(r_Clk);

        -- Send a byte: 0x37 (00110111)
        r_Tx_Dv   <= '1';
        r_Tx_Byte <= X"10";
        wait until rising_edge(r_Clk);
        r_Tx_Dv   <= '0';


        wait until w_Rx_Dv = '1';


        assert w_Rx_Byte = X"10"
          report "Test Failed: Received wrong byte" severity failure;

        report "Test Passed: Sent 0x10 and Received " & to_hstring(w_Rx_Byte);

        wait for 1 us;

        assert false report "Simulation Finished Successfully";
        wait;
      end process;

end behave;
