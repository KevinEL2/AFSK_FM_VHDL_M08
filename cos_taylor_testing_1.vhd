----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.01.2024 17:16:44
-- Design Name: 
-- Module Name: cos_taylor_testing_1 - Behavioral
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

entity cos_taylor_testing_1 is
    Port ( sin : in STD_LOGIC_VECTOR (12 downto 0);
           clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           sin_out : in STD_LOGIC_VECTOR (12 downto 0));
end cos_taylor_testing_1;

architecture Behavioral of cos_taylor_testing_1 is
begin
-- get sin_input
-- scale sin_input

end Behavioral;
