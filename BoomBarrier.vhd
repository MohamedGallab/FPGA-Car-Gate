library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY BoomBarrier IS

	PORT(
		clkFPGA, enableClk, IRinput, ManualControl: IN STD_LOGIC;
		stepOutput : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		letter1, letter2, letter3, letter4 : OUT STD_LOGIC_VECTOR(0 to 6)
	);
	
END ENTITY;

ARCHITECTURE arch OF BoomBarrier IS

	COMPONENT Motor
		PORT(
			clk, enable, direction: IN STD_LOGIC;
			stepOutput : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT IR_Sensor
		PORT(
			inputFromSensor : IN STD_LOGIC;
			output : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT Clock_Divider
	  PORT( 
			clk, reset: IN STD_LOGIC;
			clock_out: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT status7seg
		PORT (
			status, enable : IN STD_LOGIC;
			letter1, letter2, letter3, letter4 : OUT STD_LOGIC_VECTOR(0 to 6)
		);
	END COMPONENT;

	SIGNAL clk, isObstacle, direction, segEnable : STD_LOGIC;
	SIGNAL timer : INTEGER := 6e2;
	SIGNAL WaitTimer : INTEGER := 1;
	SIGNAL enableMotor : STD_LOGIC := '1';	
	SIGNAL isCarWaiting : STD_LOGIC := '0';
	
BEGIN

	clkStage : Clock_Divider PORT MAP (clkFPGA, enableClk, clk);
	MotorPort : Motor PORT MAP (clk, enableMotor, direction, stepOutput);
	SensorPort : IR_Sensor PORT MAP (IRinput, isObstacle);
	status7segPort : status7seg PORT MAP (direction, segEnable, letter1, letter2, letter3, letter4);
	
	PROCESS(clk)
	BEGIN
		IF(rising_edge(clk)) THEN
		
			IF(ManualControl = '1') THEN
				enableMotor <= '1';
				direction <= '0';
			ELSE
				-- car comes
				IF(isObstacle = '1' and isCarWaiting = '0' and timer > 6e2) THEN
					isCarWaiting <= '1';
					timer <= 1;
					enableMotor <= '1';
					segEnable <= '1';
					waitTimer <= 1;
				
				-- wait for car to leave
				ELSIF(isObstacle = '0' and isCarWaiting = '1' and timer > 6e2 and waitTimer < 3e2) then
					waitTimer <= waitTimer + 1;
					enableMotor <= '0';
				
				-- car left
				ELSIF(isObstacle = '0' and isCarWaiting = '1' and timer > 6e2) THEN
					isCarWaiting <= '0';
					timer <= 1;
					enableMotor <= '1';
					segEnable <= '1';
				
				-- IF about to stop then switch direction
				ELSIF(timer = 6e2) THEN
					direction <= not direction;
					timer <= timer + 1;
				
				-- stop after passing timer
				ELSIF(timer > 6e2) THEN
					enableMotor <= '0';
					segEnable <= '0';
					
				-- increment timer
				ELSE
					timer <= timer + 1;
				END IF;
				
			END IF;
		END IF;
	END PROCESS;
	
END arch;