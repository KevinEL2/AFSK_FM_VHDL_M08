----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 15:03:46
-- Design Name: 
-- Module Name: Substractor - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Substractor is
    Port ( inputA : in STD_LOGIC_vector(8 downto 0);
           inputB : in STD_LOGIC_vector(8 downto 0);
           outputC : out STD_LOGIC_vector(9 downto 0)
          );
end Substractor;

architecture Behavioral of Substractor is

signal tempA : signed(9 downto 0);
signal tempB : signed (9 downto 0);
begin
process(inputA,inputB,tempA, tempB)
begin
tempA <= conv_signed(signed(inputA),10);
tempB <= conv_signed(signed(inputB),10);
outputC <= tempA - tempB;
end process;
end Behavioral;
