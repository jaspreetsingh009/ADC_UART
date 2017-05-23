library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TX is
generic(
	PRSCL	 : INTEGER := 5207  
);
port (	
	CLK      : IN  STD_LOGIC;
	TX_LINE  : OUT STD_LOGIC;
	TX_START : IN  STD_LOGIC;
	TX_READY : OUT STD_LOGIC;
	TX_DATA  : IN STD_LOGIC_VECTOR(7 downto 0)
);
end entity TX;


architecture TX_ARC of TX is

signal TX_FLAG		:  STD_LOGIC := '0';
signal INDEX      	:  INTEGER RANGE 0 TO 9     := 0;
signal PRSCL_TICK	:  INTEGER RANGE 0 TO PRSCL := 0;
signal TX_DATA_BUF	:  STD_LOGIC_VECTOR(9 DOWNTO 0);

begin

TX_READY <= not TX_FLAG;

---------------------------------------------------------
--- 	          TX Data Transmit 		      ---
---------------------------------------------------------
							 
TX_PROCESS : PROCESS(CLK) is
begin

	if(rising_edge(CLK)) then
				
		--- Wait for Transmit Trigger ---

		if(TX_FLAG = '0' and TX_START = '1') 
		then 
			TX_FLAG  		 <=  '1'; 
			INDEX    		 <=   0;
			TX_DATA_BUF(0)  <=  '0'; 
			TX_DATA_BUF(9)  <=  '1'; 
			TX_DATA_BUF(8 DOWNTO 1) <= TX_DATA;
		end if;
	 
		--- Transmit TX Data ---
	 
		if(TX_FLAG = '1') 
		then			
			if(PRSCL_TICK < PRSCL) 
			then 
				PRSCL_TICK <= PRSCL_TICK + 1;
			else 
				PRSCL_TICK <= 0;
			end if;
			
			
			if(PRSCL_TICK = PRSCL/2) 
		    	then			
				TX_LINE <= TX_DATA_BUF(INDEX);

				if(INDEX < 9) then
				      INDEX   <=  INDEX + 1;
				else
				      TX_FLAG  <= '0';
				end if;		 
		   	 end if;  	 
		end if;	
			
	end if;  -- rising_edge if end --

end process TX_PROCESS;


end architecture TX_ARC;

