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
          coef_num    : integer := 3;
          coeff_resol : integer := 18;
          input_resol : integer := 9
          );
    Port ( clk      : in  STD_LOGIC;
           nrst     : in  STD_LOGIC;
           Sin_in   : in  STD_LOGIC_Vector(input_resol-1 downto 0);
           cos_out  : out STD_LOGIC_Vector(input_resol-1 downto 0));
end Soms_he_dan_denk_ik;

architecture Behavioral of Soms_he_dan_denk_ik is

type coefficients is array (0 to coef_num) of signed( 17 downto 0);
signal coeff: coefficients :=( 
"011111111111111111", 
"010000000000000000", 
"000001010101010101", 
"000000000010110110");  -- right up to 3 decimals

Signal x            : signed(input_resol-1 downto 0) := "000000000";
Signal x_squared    : signed((input_resol*2)-1 downto 0); -- iz 1

Signal accumulator  : signed((input_resol*2)-1 downto 0) := (others=>'0'); --iz 1
Signal output       : signed((input_resol*2)-1 downto 0) := (others=> '0'); -- another one
Signal temp         : signed((input_resol*2)+coeff_resol-1 downto 0) := (others=>'0'); -- iz 1 + coeff 
Signal counter      : integer;

type state_machine is (idle_st, active_st);
signal state : state_machine := idle_st;

type state_machine2 is (multiply,substract,scale,calc_z);
signal choice: state_machine2 := calc_z;

begin

cos_out <= std_logic_vector(output((input_resol*2)-1 downto input_resol)); -- output signal to output port, not accu cuz constantly changing in active_st
process(clk, nrst)
begin

if nrst = '1' then
    x_squared <= (others=>'0');
    accumulator <= (others=> '0');
    counter <= coef_num;
    temp <= (others=> '0');
    output <= (others => '0');
    x <= (others => '0');
    state <= idle_st;
elsif rising_edge(clk) then 

case state is
    when idle_st => if x /= signed(Sin_in) then -- maby putting into a different process changes stuff (doesnt wait until clk cycle, which it does for some reason. (prob cuz process sensitivity list i guess
                        x <= signed(Sin_in);
                        accumulator <= (others=> '0');  -- put all values back to 0
                        temp <= (others=> '0');
                        state <= active_st;
                    end if;         
    when active_st =>
                        case choice is
                            WHEN multiply => temp <= x_squared * accumulator; -- when multiply
                                         --counter <= counter -1;
                                         choice <= scale;
                            WHEN scale=> accumulator <= temp (coeff_resol+(input_resol-1)*2-1 downto (coeff_resol+(input_resol-1)*2)-input_resol*2);-- when scaling -- completly f*cks up everything, rip or does it? <vsauce intro starts playing>
                                         choice <= substract;
                            WHEN substract => if counter > 0 then   
                                            accumulator <= coeff(counter) -accumulator;-- when minus
                                            counter <= counter -1;                                      
                                            choice <= multiply;
                                         else 
                                            output <= coeff(counter) -accumulator;-- when minus     
                                            counter <= coef_num;     
                                            choice <= calc_z;
                                            state <= idle_st;
                                         end if;
                            WHEN calc_z => x_squared <= (x * x); -- make x->x^2/ z value
                                         choice <= substract;
                            When others => choice <= calc_z;
                         end case;               
    end case;
end if;
end process;
end Behavioral;
