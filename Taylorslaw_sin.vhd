----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 14:59:56
-- Design Name: 
-- Module Name: Taylorslaw_sin - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Taylorslaw_sin is
Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           Sin_in : in STD_LOGIC_Vector(8 downto 0);
           sin_out : out STD_LOGIC);
end Taylorslaw_sin;

architecture Behavioral of Taylorslaw_sin is

begin


end Behavioral;
