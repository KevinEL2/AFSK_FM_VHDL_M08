----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 14:49:22
-- Design Name: 
-- Module Name: cos_sin_carrier - Behavioral
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

entity cos_sin_carrier is
generic (NUM_POINTS: integer:=32;
         MAX_AMPLITUDE: integer :=255
         );
  Port (clk : in STD_LOGIC;
        nrst: in STD_LOGIC;
        Cos_out : out STD_LOGIC_VECTOR(8 downto 0);
        Sin_out : out STD_LOGIC_VECTOR (8 downto 0));
end cos_sin_carrier;

architecture Behavioral of cos_sin_carrier is

type memory_type is array (0 to NUM_POINTS-1) of integer range 0 to MAX_AMPLITUDE;
signal sine : memory_type :=(128,152,176,198,218,234,245,253,
                             255,253,245,234,218,198,176,152,
                             128,103,79,57,37,21,10,2,
                             0,2,10,21,37,57,79,103);                          
signal accu: std_logic_vector(20 downto 0);
signal lut_index, lut_index2: std_logic_vector(4 downto 0); -- is based on integer range, in my case 0 to NUM_POINTS (2^5 =32)
signal fcw : std_logic_vector(15 downto 0):="0000010001000011"; -- fcw increased to get a more accurate output frequency -- freq_out is 10Mhz/(2^16/1091)/32 = 5202.29 Hz (but over 5200 but iz ok still)
                                            
signal sin_out_bus : std_logic_vector(7 downto 0);
signal cos_out_bus : std_logic_vector(7 downto 0);

begin
process (clk,nrst)
begin

if nrst = '1' then         
            accu <= (others =>'0');         --synchronous reset
            fcw <= "0000010001000011";
elsif rising_edge(clk) then
    accu <= accu + fcw;
end if;                                
end process;
lut_index <= accu(20 downto 16);
lut_index2 <= accu(20 downto 16)+(NUM_POINTS/4);

sin_out_bus<= conv_std_logic_vector(sine(conv_integer(lut_index)),8);

Sin_out(8) <= '0';
Sin_out(7 downto 0) <= sin_out_bus;

cos_out_bus<= conv_std_logic_vector(sine(conv_integer(lut_index2)),8); -- add 90 degrees fase shift

Cos_out(8) <= '0';
Cos_out(7 downto 0) <= cos_out_bus;

end Behavioral;
