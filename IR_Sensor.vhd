library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IR_Sensor is
	port ( 
		inputFromSensor : in std_logic;
		output : out std_logic
	);
end IR_Sensor;

architecture arch of IR_Sensor is
begin
	output <= not inputFromSensor;
end arch;