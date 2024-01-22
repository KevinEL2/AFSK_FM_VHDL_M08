----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.11.2023 09:52:07
-- Design Name: 
-- Module Name: Pre_emp_filterdesign - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pre_emphasis_filter is
  Generic(
        Filter_order     : integer := 61;               -- order number of particulair filter
        INPUT_WIDTH     : integer range 8 to 32 := 9; -- amount of bits of input signal
        COEFF_WIDTH     : integer range 8 to 32 := 24; -- amount of bits of the coefficient
        OUTPUT_WIDTH    : integer range 8 to 32 := 12
  );
  Port (   
        Clk             : in STD_LOGIC;   
        Sampling_Clk    : in STD_LOGIC;
        Data_in         : in STD_LOGIC_VECTOR(INPUT_WIDTH-1 downto 0);
        Data_out        : out STD_LOGIC_VECTOR(OUTPUT_WIDTH-1 downto 0)
        );
end Pre_emphasis_filter;

architecture Behavioral of Pre_emphasis_filter is

type input_registers is array(0 to Filter_order-1) of signed(INPUT_WIDTH-1 downto 0); -- makes a array of input registers of 60 with each a signed value of max 16 bits
signal delay_line_s  : input_registers := (others=>(others=>'0')); 

type coefficients is array (0 to 60) of signed( 23 downto 0);
signal coeff: coefficients :=( 
x"000000", x"00001C", x"0000E0", x"0002DF", x"000664", x"000B42", x"00109F", x"0014D5", 
x"00157A", x"000F8F", x"FFFFFF", x"FFE455", x"FFBB9F", x"FF8767", x"FF4C86", x"FF1394", 
x"FEE8D2", x"FEDB57", x"FEFB8D", x"FF5908", x"000000", x"00F6CF", x"023BDA", x"03C44D", 
x"057C0A", x"0746E4", x"09031F", x"0A8CF9", x"0BC2B7", x"0C88B3", x"0CCCCC", x"0C88B3", 
x"0BC2B7", x"0A8CF9", x"09031F", x"0746E4", x"057C0A", x"03C44D", x"023BDA", x"00F6CF", 
x"000000", x"FF5908", x"FEFB8D", x"FEDB57", x"FEE8D2", x"FF1394", x"FF4C86", x"FF8767", 
x"FFBB9F", x"FFE455", x"FFFFFF", x"000F8F", x"00157A", x"0014D5", x"00109F", x"000B42", 
x"000664", x"0002DF", x"0000E0", x"00001C", x"000000");

type state_machine is (idle_st, active_st);
signal state : state_machine := idle_st;
signal counter : integer range 0 to Filter_order-1 := Filter_order-1;  -- make a counter of max value depending on order number and set to max value

signal accumulator  : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others=>'0');
signal output       : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others=>'0');
signal debounce_clk : std_logic := '0'; -- has to be a signal cuz else it no work. most likely cuz variables do not save, me stupid
begin
    data_out <= std_logic_vector(output(INPUT_WIDTH+COEFF_WIDTH-1 downto INPUT_WIDTH+COEFF_WIDTH-OUTPUT_WIDTH));
process (clk)
variable sum : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others => '0');
begin
if rising_edge (clk) then
    debounce_clk <= Sampling_clk;
    case state is
    When idle_st    =>  if Sampling_clk = '1' and debounce_clk = '0' then -- prob doesnt work for some reason
                            state <= active_st;
                            accumulator <= (others => '0');    
                        end if;
    When active_st =>   if counter > 0 then
                            counter <= counter -1;
                        else
                            counter <= Filter_order-1;
                            state <= idle_st;
                        end if; 
                        
                        -- Delay registers
                        if counter > 0 then
                            delay_line_s(counter) <= delay_line_s(counter-1); -- shifts next input of the delay line to the left
                        else 
                            delay_line_s(counter) <= signed(data_in); -- last bit of data goes directly into register (n(0))    
                         end if;
                        
                        -- operations
                        if counter > 0 then
                            sum := delay_line_s(counter) * coeff (counter); 
                            accumulator <= accumulator + sum; 
                        else
                            sum := delay_line_s(counter)* coeff (counter);
                            output <= accumulator +sum; 
                        end if;
    end case;
end if;
end process;
end Behavioral;
