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

entity Soms_he_dan_denk_ik is
    generic(
          coef_num : integer := 3
          );
    Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           Sin_in : in STD_LOGIC_Vector(8 downto 0);
           cos_out : out STD_LOGIC_Vector(8 downto 0));
end Soms_he_dan_denk_ik;

architecture Behavioral of Soms_he_dan_denk_ik is

type coefficients is array (0 to coef_num) of signed( 17 downto 0);
signal coeff: coefficients :=( 
"011111111111111111", 
"010000000000000000", 
"000001010101010101", 
"000000000010110110");  -- right up to 3 decimals

Signal x            : signed(8 downto 0) := "000000000";
Signal x_squared    : signed(17 downto 0);

Signal accumulator  : signed(17 downto 0) := (others=>'0');
Signal output       : signed (17 downto 0) := (others=> '0');
Signal temp         : signed(35 downto 0) := (others=>'0');
Signal counter      : integer;

type state_machine is (idle_st, active_st);
signal state : state_machine := idle_st;

signal mult_min_scale : std_logic_vector (1 downto 0) := "00";

begin

cos_out <= std_logic_vector(output(17 downto 9)); -- output signal to output port, not accu cuz constantly changing in active_st

process(clk, nrst)
variable condition : STD_LOGIC := '0'; -- might not work cuz variable, we"ll see i guess
begin

if nrst = '1' then
    cos_out <= "000000000";
    x_squared <= (others=>'0');
    accumulator <= (others=> '0');
    counter <= coef_num;
    temp <= (others=> '0');
    output <= (others => '0');
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
                        case mult_min_scale is
                            WHEN "00" => temp <= x_squared * accumulator; -- when multiply
                                         --counter <= counter -1;
                                         mult_min_scale <= "01";
                            WHEN "01" => accumulator <= temp (35 downto 18);-- when scaling
                                         mult_min_scale <= "10";
                            WHEN "10" => if counter > 0 then   
                                            accumulator <= coeff(counter) -accumulator;-- when minus
                                            counter <= counter -1;                                      
                                            mult_min_scale <= "00";
                                         else 
                                            output <= coeff(counter) -accumulator;-- when minus     
                                            counter <= coef_num;        
                                            mult_min_scale <= "10";
                                            state <= idle_st;
                                         end if;
                            When others => mult_min_scale <= "10";
                         end case;               
    end case;
end if;
end process;
end Behavioral;
