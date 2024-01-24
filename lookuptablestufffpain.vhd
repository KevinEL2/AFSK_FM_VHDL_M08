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
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lookuptablestfffpain is
generic (NUM_POINTS: integer:=32;
         MAX_AMPLITUDE: integer :=255
         );
  Port (clk : in STD_LOGIC;
        nrst: in STD_LOGIC;
        fsk_out : out STD_LOGIC_VECTOR (8 downto 0));
end lookuptablestfffpain;

architecture Behavioral of lookuptablestfffpain is

type memory_type is array (0 to NUM_POINTS-1) of integer range -MAX_AMPLITUDE to MAX_AMPLITUDE;
signal sine : memory_type := (0,50,98,142,180,212,236,250,
                             255,250,236,212,180,142,98,50,
                             0,-50,-98,-142,-180,-212,-236,-250,
                             -255,-250,-236,-212,-180,-142,-98,-50);
signal accu: std_logic_vector(20 downto 0);
signal lut_index: std_logic_vector(4 downto 0); -- is based on integer range, in my case 0 to NUM_POINTS (2^5 =32)
signal fcw : std_logic_vector(15 downto 0):="0000000011111100"; -- fcw increased to get a more accurate output frequency -- freq_out is 10Mhz/(2^16/252)/32 = 1201,63Hz                                                                                                                                                                    -- divide by 260 to get ~ 1200Hz (1201,92 Hz, but iz ok)
signal fsk_out_bus : signed(8 downto 0);
begin
process (clk,nrst)
begin
 if nrst = '1' then         
            accu <= (others =>'0');         --synchronous reset
            fcw <= "0000000011111100";
elsif rising_edge(clk) then
    accu <= accu + fcw;
end if;                                
end process;
lut_index <= accu(20 downto 16);
fsk_out_bus<= conv_signed(sine(conv_integer(lut_index)),9);
fsk_out(8 downto 0) <= conv_std_logic_vector(fsk_out_bus,9);
end Behavioral;

