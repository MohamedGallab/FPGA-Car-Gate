library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

ENTITY BoomBarrier IS

	PORT(
		clkFPGA, enableClk, IRinput: in std_logic;
		isObstacle, direction, segEnable : buffer std_logic;
		clk : buffer std_logic;
		isCarWaiting : buffer std_logic := '0';
		stepOutput : out std_logic_vector (3 downto 0);
		letter1, letter2, letter3, letter4 : out std_logic_vector(0 to 6)
	);
	
END ENTITY;

architecture arch of BoomBarrier is

	component Motor
		PORT(
			clk, enable, direction: in std_logic;
			stepOutput : out std_logic_vector (3 downto 0)
		);
	end component;
	
	component IR_Sensor
		PORT(
			inputFromSensor : in std_logic;
			output : out std_logic
		);
	end component;
	
	component Clock_Divider
        port ( 
				clk, reset: in std_logic;
				clock_out: out std_logic
			);
    end component;
	 
	 component status7seg
		port (
			status, enable : in std_logic;
			letter1, letter2, letter3, letter4 : out std_logic_vector(0 to 6)
		);
	 end component;
	 
	 signal timer : integer := 6e2;
	 signal enableMotor : std_logic := '1';
	
begin

	clkStage : Clock_Divider port map (clkFPGA, enableClk, clk);
	MotorPort : Motor PORT MAP (clk, enableMotor, direction, stepOutput);
	SensorPort : IR_Sensor PORT MAP (IRinput, isObstacle);
	status7segPort : status7seg PORT MAP (direction, segEnable, letter1, letter2, letter3, letter4);
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			
			-- car comes
			if(isObstacle = '1' and isCarWaiting = '0' and timer > 6e2) then
				isCarWaiting <= '1';
				timer <= 1;
				enableMotor <= '1';
				segEnable <= '1';
			
			-- care left
			elsif(isObstacle = '0' and isCarWaiting = '1' and timer > 6e2) then
				isCarWaiting <= '0';
				timer <= 1;
				enableMotor <= '1';
				segEnable <= '1';
			
			-- if about to stop then switch direction
			elsif(timer = 6e2) then
				direction <= not direction;
				timer <= timer + 1;
			
			-- stop after passing timer
			elsif(timer > 6e2) then
				enableMotor <= '0';
				segEnable <= '0';
			else
				timer <= timer + 1;
			end if;
		end if;
	end process;
	
end arch;