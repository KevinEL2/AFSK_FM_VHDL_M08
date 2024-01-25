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

entity Taylorslaw_sin is
    generic(
          coef_num    : integer := 3;
          coeff_resol : integer := 18;
          input_resol : integer := 10
          );
    Port ( clk      : in  STD_LOGIC;
           nrst     : in  STD_LOGIC;
           Sin_modulation_in   : in  STD_LOGIC_Vector(input_resol-2 downto 0);
           Taylors_approc_cos_out  : out STD_LOGIC_Vector(input_resol-2 downto 0));
end Taylorslaw_sin;

architecture Behavioral of Taylorslaw_sin is

type coefficients is array (0 to coef_num) of signed( 17 downto 0);
signal coeff: coefficients :=( 
"011111111111111111", 
"000101010101010101", 
"000000010001000100", 
"000000000000011010");

Signal x            : signed(input_resol-2 downto 0) :=(others => '0');

Signal temp_x_1     : signed(19+input_resol-2 downto 0); -- index width + input with of x -1
Signal temp_x_2     : signed(input_resol-1 downto 0) :=(others => '0'); -- temp_x_1 / 2^17

Signal x_squared    : signed((input_resol*2)-1 downto 0); -- iz 1

Signal index : signed (18 downto 0) := "0101011101000101110";

Signal accumulator  : signed((input_resol*2)-1 downto 0) := (others=>'0'); --iz 1
Signal output       : signed((input_resol*2)-1 downto 0) := (others=> '0'); -- another one
Signal temp         : signed((input_resol*2)+(input_resol*2)-1 downto 0) := (others=>'0'); -- iz 1 + coeff 
Signal temp2        : signed(input_resol+(input_resol*2)-1 downto 0) := (others =>'0');
Signal counter      : integer;

type state_machine is (idle_st, active_st);
signal state : state_machine := idle_st;

type state_machine2 is (multiply,substract,scale,calc_z,Index_1,Index_2);
signal choice: state_machine2 := Index_1;

begin
Taylors_approc_cos_out<= std_logic_vector(output(17 downto 9));
--Taylors_approc_cos_out <= std_logic_vector(output((input_resol*2)-1 downto input_resol+1)); -- output signal to output port, not accu cuz constantly changing in active_st
process(clk, nrst)
begin

if nrst = '1' then
    x_squared <= (others=>'0');
    accumulator <= (others=> '0');
    counter <= coef_num;
    temp <= (others=> '0');
    temp2 <= (others=> '0');
    output <= (others => '0');
    x <= (others => '0');
    temp_x_1 <=(others => '0');
    temp_x_2 <=(others => '0');
    index <= "0101011101000101110";
    state <= idle_st;
    choice <=Index_1;
elsif rising_edge(clk) then 

case state is
    when idle_st => if x /= signed(Sin_modulation_in) then -- maby putting into a different process changes stuff (doesnt wait until clk cycle, which it does for some reason. (prob cuz process sensitivity list i guess
                        x <= signed(Sin_modulation_in);
                        accumulator <= (others=> '0');  -- put all values back to 0
                        temp <= (others=> '0');
                        state <= active_st;
                    end if;         
    when active_st =>
                        case choice is
                            WHEN multiply => if counter < 0 then
                                                temp2 <= temp_x_2 * accumulator; -- i think gotta use the updated x instead of old one
                                             else  
                                                temp <= x_squared * accumulator; -- when multiply
                                             end if;
                                            choice <= scale;
                            WHEN scale=> if counter < 0 then 
                                            output <= temp2((input_resol-1)+(input_resol-1)*2 downto (input_resol-1)*2-input_resol); -- might not always works but whatever ill see later (that was a big lie, just changed it to 2 and still dont care
                                            counter <= coef_num;     
                                            choice <= Index_1;
                                            state <= idle_st;
                                         else
                                            accumulator <= temp(coeff_resol+(input_resol-1)*2-1 downto (coeff_resol+(input_resol-1)*2)-input_resol*2);-- when scaling -- completly f*cks up everything, rip or does it? <vsauce intro starts playing>
                                            choice <= substract;
                                         end if;
                            WHEN substract => accumulator <= coeff(counter) -accumulator;-- when minus
                                            counter <= counter -1;                                      
                                            choice <= multiply;
                            WHEN calc_z => x_squared <= (temp_x_2 * temp_x_2); -- make x->x^2/ z value
                                         choice <= substract;
                            WHEN Index_1 => temp_x_1 <= x * index;
                                            choice <= Index_2;
                            WHEN Index_2 => temp_x_2 <= temp_x_1(18+input_resol-2 downto (18+input_resol-1)-input_resol);
                                            choice <= calc_z;
                            When others => choice <= Index_1;
                         end case;               
    end case;
end if;
end process;
end Behavioral;
