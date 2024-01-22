----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.11.2023 11:02:19
-- Design Name: 
-- Module Name: FSK_mod - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSK_mod is
generic (NUM_POINTS     : integer:=32;
         MAX_AMPLITUDE  : integer :=255
         );
  Port (clk             : in STD_LOGIC;
        nrst            : in STD_LOGIC;
        bitstream_in    : in STD_LOGIC;
        fsk_out         : out STD_LOGIC_VECTOR (8 downto 0));
end FSK_mod;

architecture Behavioral of FSK_mod is

--signal i : integer range 0 to NUM_POINTS := 0;
type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;
signal sine : memory_type :=(128,152,176,198,218,234,245,253,       -- lookup-table sine generated with: https://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml
                             255,253,245,234,218,198,176,152,
                             128,103,79,57,37,21,10,2,
                             0,2,10,21,37,57,79,103);
signal accu: std_logic_vector(20 downto 0);
signal lut_index: std_logic_vector(4 downto 0); -- is based on integer range, in my case 0 to NUM_POINTS (2^5 =32)
signal fcw : std_logic_vector(15 downto 0); -- fcw increased to get a more accurate output frequency
signal fsk_out_bus : std_logic_vector(7 downto 0);
begin
process (clk,nrst)
begin
 if nrst = '1' then         
            accu <= (others =>'0');         --synchronous reset
            fcw  <= (others => '0'); 
elsif rising_edge(clk) then
if bitstream_in ='1' then fcw <= "0000000011111100"; else fcw <= "0000000111001110"; end if; -- based on bitstream input, different frequency(fcw) (Freq_out =clk /((2^bitrate_fcw)/fcw_value)/Number of points)
   -- if high, then freq is 10Mhz/(2^16/252)/32 = 1201,63Hz, else freq is 10Mhz/(2^16/462)/32=2202.98Hz
    accu <= accu + fcw;
end if;
end process;
lut_index <= accu(20 downto 16);
fsk_out_bus<= conv_std_logic_vector(sine(conv_integer(lut_index)),8);
fsk_out(8) <= '0';
fsk_out(7 downto 0) <= fsk_out_bus;
end Behavioral;

