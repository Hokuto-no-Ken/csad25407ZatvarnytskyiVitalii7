library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  generic (
    g_CLKS_PER_BIT : integer := 870  -- (Frequency / BaudRate) already calculated by the user
  );
  port (
    i_clk       : in  std_logic;
    i_tx_dv     : in  std_logic; -- Data Valid pulse
    i_tx_byte   : in  std_logic_vector(7 downto 0);
    o_tx_active : out std_logic;
    o_tx_serial : out std_logic;
    o_tx_done   : out std_logic
  );
end uart_tx;

architecture rtl of uart_tx is
  type t_SM_Main is (IDLE, TX_START_BIT, TX_DATA_BITS, TX_STOP_BIT, CLEANUP);
  signal r_SM_Main : t_SM_Main := IDLE;

  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;
  signal r_Tx_Data   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_Tx_Done   : std_logic := '0';

begin
  p_UART_TX : process (i_clk)
  begin
    if rising_edge(i_clk) then
      case r_SM_Main is

        when IDLE =>
          o_tx_active <= '0';
          o_tx_serial <= '1'; -- Idle high
          r_Tx_Done   <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;

          if i_tx_dv = '1' then
            r_Tx_Data <= i_tx_byte;
            r_SM_Main <= TX_START_BIT;
          else
            r_SM_Main <= IDLE;
          end if;

        -- Send Start Bit (Low)
        when TX_START_BIT =>
          o_tx_active <= '1';
          o_tx_serial <= '0';

          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= TX_START_BIT;
          else
            r_Clk_Count <= 0;
            r_SM_Main   <= TX_DATA_BITS;
          end if;

        -- Send Data Bits
        when TX_DATA_BITS =>
          o_tx_serial <= r_Tx_Data(r_Bit_Index);

          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= TX_DATA_BITS;
          else
            r_Clk_Count <= 0;
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= TX_DATA_BITS;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= TX_STOP_BIT;
            end if;
          end if;

        -- Send Stop Bit (High)
        when TX_STOP_BIT =>
          o_tx_serial <= '1';

          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= TX_STOP_BIT;
          else
            r_Tx_Done   <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= CLEANUP;
          end if;

        when CLEANUP =>
          o_tx_active <= '0';
          r_Tx_Done   <= '1';
          r_SM_Main   <= IDLE;

        when others =>
          r_SM_Main <= IDLE;
      end case;
    end if;
  end process p_UART_TX;

  o_tx_done <= r_Tx_Done;
end rtl;