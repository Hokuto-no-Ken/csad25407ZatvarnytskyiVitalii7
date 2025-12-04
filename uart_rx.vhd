library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
  generic (
    g_CLKS_PER_BIT : integer := 870
  );
  port (
    i_clk       : in  std_logic;
    i_rx_serial : in  std_logic;
    o_rx_dv     : out std_logic;
    o_rx_byte   : out std_logic_vector(7 downto 0)
  );
end uart_rx;

architecture rtl of uart_rx is
  type t_SM_Main is (IDLE, RX_START_BIT, RX_DATA_BITS, RX_STOP_BIT, CLEANUP);
  signal r_SM_Main : t_SM_Main := IDLE;

  signal r_Rx_Data_R : std_logic := '0';
  signal r_Rx_Data   : std_logic := '0';

  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;
  signal r_Rx_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_Rx_DV     : std_logic := '0';

begin
  -- Purpose: Double-register the incoming data for metastability issues
  p_SAMPLE : process (i_clk)
  begin
    if rising_edge(i_clk) then
      r_Rx_Data_R <= i_rx_serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end if;
  end process p_SAMPLE;

  p_UART_RX : process (i_clk)
  begin
    if rising_edge(i_clk) then
      case r_SM_Main is

        when IDLE =>
          r_Rx_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;

          if r_Rx_Data = '0' then -- Start bit detected
            r_SM_Main <= RX_START_BIT;
          else
            r_SM_Main <= IDLE;
          end if;

        -- Check middle of start bit to confirm it's still low
        when RX_START_BIT =>
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if r_Rx_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter, found the middle
              r_SM_Main   <= RX_DATA_BITS;
            else
              r_SM_Main <= IDLE;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= RX_START_BIT;
          end if;

        when RX_DATA_BITS =>
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= RX_DATA_BITS;
          else
            r_Clk_Count            <= 0;
            r_Rx_Byte(r_Bit_Index) <= r_Rx_Data;

            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= RX_DATA_BITS;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= RX_STOP_BIT;
            end if;
          end if;

        when RX_STOP_BIT =>
          -- Wait g_CLKS_PER_BIT-1 (Stop Bit Duration)
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= RX_STOP_BIT;
          else
            r_Rx_DV     <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= CLEANUP;
          end if;

        when CLEANUP =>
          r_SM_Main <= IDLE;
          r_Rx_DV   <= '0';

        when others =>
          r_SM_Main <= IDLE;
      end case;
    end if;
  end process p_UART_RX;

  o_rx_dv   <= r_Rx_DV;
  o_rx_byte <= r_Rx_Byte;
end rtl;