library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Motor is

	port ( 
		clk, enable, direction: in std_logic;
		stepOutput        : out std_logic_vector (3 downto 0)
	);
	end Motor;
  
architecture arch of Motor is

    signal processLed: std_logic := '0';
	 signal step: integer := 1;
	 

begin

	 process(clk)
	 begin
		if(rising_edge(clk)) then
			if(enable = '1') then
				if(direction = '0') then
					case step is
						 when 1 =>
							  stepOutput <= "0001";
						 when 2 =>
							  stepOutput <= "0010";
						 when 3 =>
							  stepOutput <= "0100";
						 when 4 =>
							  stepOutput <= "1000";
						 when others =>
							  stepOutput <= "0000";
					end case;
				else
					case step is
						 when 1 =>
							  stepOutput <= "1000";
						 when 2 =>
							  stepOutput <= "0100";
						 when 3 =>
							  stepOutput <= "0010";
						 when 4 =>
							  stepOutput <= "0001";
						 when others =>
							  stepOutput <= "0000";
					end case;
				end if;
				if(step > 4) then
					step <= 1;
				else
					step <= step + 1;
				end if;
			end if;
		end if;
	 end process;
end arch;