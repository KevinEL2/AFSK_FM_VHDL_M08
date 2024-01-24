----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 14:54:58
-- Design Name: 
-- Module Name: multiplier_scaler - Behavioral
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
use IEEE.std_logic_arith.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier_scaler is
    Port ( SignalA : in STD_LOGIC_vector(8 downto 0);
           SignalB : in STD_LOGIC_vector (8 downto 0);
           Signal_out : out STD_LOGIC_vector(8 downto 0)
          );
end multiplier_scaler;

architecture Behavioral of multiplier_scaler is
Signal temp : signed(17 downto 0);
begin
process(signalA,SignalB,temp)
begin 
    temp <= signed(SignalA) * signed(SignalB);
    Signal_out <= std_logic_vector(temp(16 downto 8));
end process;
end Behavioral;
