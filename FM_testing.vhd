----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2023 10:50:46
-- Design Name: 
-- Module Name: FM_testing - Behavioral
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
use IEEE.std_logic_arith;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FM_testing is
  Port ( Mod_signal : in STD_LOGIC_VECTOR(8 downto 0);
         clk        : in STD_LOGIC;
         nrst       : in STD_LOGIC;
         FM_out     : out STD_LOGIC_VECTOR(8 downto 0));
end FM_testing;

architecture Behavioral of FM_testing is

--type coefficients is array (0 to 9) of signed( 23 downto 0);
--signal coeff: coefficients :=( 
--"011111111111111111111111", "010000000000000000000000", --c1 = int of 1/n!*2^23
--"000101010101010101010101", "000001010101010101010101", 
--"000000010001000100010001", "000000000010110110000010", 
--"000000000000011010000000", "000000000000000011010000", 
--"000000000000000000010111", "000000000000000000000010");

--Signal input        : signed (8 downto 0); -- is most likely not necessary since the input signal was kindof signed to begin with, but just to be sure
Signal x            : signed(8 downto 0) := "000000000";
Signal x_squared    : signed(17 downto 0);
--Signal counter    : integer range 0 to 8;
--Signal sum        : signed(9 downto 0); -- does not have to be 8+24 at all cuz its just addition so only 1 bit for overflow (9 cuz 1 bit for overflow)
--Signal accu       : signed (24+8-1 downto 0);

Signal accumulator  : signed(41 downto 0) := (others=>'0');

Signal condition : STD_LOGIC := '0';
Signal condition2: STD_LOGIC:= '0';

begin

process(clk,nrst,Mod_signal)

begin
if x /= signed(Mod_signal) then -- maby putting into a different process changes stuff (doesnt wait until clk cycle, which it does for some reason. (prob cuz process sensitivity list i guess
        x <= signed(Mod_signal);                  
        condition <= '1';
end if;

if nrst = '1' then
    x <= (others=> '0');
    x_squared <= (others=> '0');
    condition  <= '0';
    condition2 <= '0';
    accumulator <= (others=> '0');
elsif rising_edge(clk) then 
     
        if condition = '1' then
            x_squared <= (x * x); -- make x->x^2/ z value -- just why does it break here? me confused
            condition <= '0';
            condition2 <= '1';
        end if;
 
 
        if condition2 = '1' then
            accumulator <= (x_squared * "000000010001000100010001");
            condition2  <= '0';
        end if;
end if;

--if nrst = '1' then
--    counter <= 5;
--    accu <= (others =>'0');
--    sum  <= (others =>'0');
--elsif rising_edge(clk) then

--FM_out <= std_logic_vector(accu(31 downto 23)); -- get only the most significant bits
---- cos(x) = c1 -z (c2-z)(c3-z(c4)....
---- FM_out = cos(2*pi*fc*t + freq_deviation/max_freq* input_signal)

--for i in 0 to counter loop
--    sum <= coeff(counter) - x_squared; -- do the addition of the coefficients (c1-z,c2-z... etc)
--    accu <= accu * sum;
--    counter <= counter-1;
-- end loop;
-- end if;
end process;
end Behavioral;
