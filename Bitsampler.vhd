----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2023 13:46:45
-- Design Name: 
-- Module Name: shiftreg - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bitsampler is
generic  ( bitstream_length     : integer:= 10); -- bitstream_length should be actual bidsteam_length -1
    Port ( bitstream_in         : in STD_LOGIC_VECTOR((bitstream_length-1) downto 0);
           clk                  : in STD_LOGIC; -- 125 Mhz from ethernet prob or 60 Mhz, actually f**** this, just gonna use the clock wizard
           nrst                 : in STD_LOGIC;
           Bitstream_out        : out STD_LOGIC);
end Bitsampler;

architecture Behavioral of Bitsampler is
    signal index : integer :=(bitstream_length-1);
begin
process(clk, nrst)
    variable clk_divider    : integer  := 0;
begin
if nrst = '1' then index <= (bitstream_length-1); clk_divider := 0;
elsif rising_edge(clk) then
    if clk_divider = 9999 then -- 10Mhz/10Kbt= 1Khz (999 to compensate for 1 extra clock cycle(resetting clk_div to zero))
        if index = 0 then index <= (bitstream_length-1); -- reset index when the MSB of the bistream is reached
        else
            index <= index -1; -- increment index at 1/100Khz= 10us
            clk_divider := 0; -- counter goes back to 0
        end if;
    else
        clk_divider := clk_divider +1;  -- count amount of clock cylcles till division is made
    end if;
end if;

Bitstream_out <= bitstream_in(index);

end process;
end Behavioral;