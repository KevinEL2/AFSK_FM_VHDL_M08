----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2024 14:53:30
-- Design Name: 
-- Module Name: Taylorslaw_cos - Behavioral
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

entity Taylorslaw_cos is
    generic(
          coef_num : integer := 4
          );
    Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           Sin_in : in STD_LOGIC_Vector(8 downto 0);
           cos_out : out STD_LOGIC_Vector(8 downto 0));
end Taylorslaw_cos;

architecture Behavioral of Taylorslaw_cos is

type coefficients is array (0 to coef_num) of signed( 23 downto 0);
signal coeff: coefficients :=( 
"011111111111111111111111", "010000000000000000000000", --c1 = int of 1/n!*2^23
"000101010101010101010101", "000001010101010101010101", 
"000000010001000100010001");--, "000000000010110110000010", 
--"000000000000011010000000", "000000000000000011010000", 
--"000000000000000000010111", "000000000000000000000010");

Signal input        : signed (8 downto 0); -- is most likely not necessary since the input signal was kindof signed to begin with, but just to be sure
Signal x            : signed(8 downto 0) := "000000000";
Signal x_squared    : signed(17 downto 0);

Signal accumulator  : signed(41 downto 0) := (others=>'0');
Signal output       : signed (24 downto 0) := (others=> '0');
Signal temp         : signed(41 downto 0) := (others=>'0');
Signal counter      : integer;

type state_machine is (idle_st, active_st);
signal state : state_machine := idle_st;
begin

cos_out <= std_logic_vector(output(24 downto 16)); -- rescale the ouput to the 8 bit cosine (i hope, well at least for constants i guess)

process(clk, nrst)
variable condition : STD_LOGIC := '0';
variable mult_min_choice : std_logic := '0';
begin

if nrst = '1' then
    cos_out <= "000000000";
    x_squared <= (others=>'0');
    accumulator <= (others=> '0');
    counter <= coef_num;
    input <= (others=>'0');
    temp <= (others=> '0');
elsif rising_edge(clk) then 

case state is
    when idle_st => if x /= signed(Sin_in) then -- maby putting into a different process changes stuff (doesnt wait until clk cycle, which it does for some reason. (prob cuz process sensitivity list i guess
                        x <= signed(Sin_in);
                        condition := '1';
                    end if;
                    
                    if condition = '1' then
                        x_squared <= (x * x); -- make x->x^2/ z value -- just why does it break here? me confused
                        condition := '0';
                        state <= active_st;
                    end if;
    when active_st =>
                     accumulator <=coeff(counter)*x_squared;  
    
    
    
--                    if counter > 0 then
--                        --1- z*(const-z*(const-z*(const -z*const))) ~ basically the formula
--                        if mult_min_choice = '1' then
--                            -- multiply
--                            accumulator <= x_squared * temp; -- aint working again, dunno why though kinda sad
--                           mult_min_choice := '0';
--                           counter <= counter -1;
--                        else
--                            -- minus
--                            temp <= coeff(counter); --- accumulator;
--                            mult_min_choice := '1';
--                        end if;

--                    else
--                        output <= coeff(counter)-accumulator;
--                        counter <= coef_num;
--                        state <= idle_st;
--                    end if;                      
    end case;
end if;
end process;
end Behavioral;
