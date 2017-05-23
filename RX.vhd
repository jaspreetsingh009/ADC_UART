library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RX is
generic(
	PRSCL	  : INTEGER := 5207  
);
port (	
	CLK       : IN  STD_LOGIC;
	RST		  : IN  STD_LOGIC;
	RX_LINE   : IN  STD_LOGIC;
	RX_STATUS : OUT STD_LOGIC;
	RX_DATA   : OUT STD_LOGIC_VECTOR(7 downto 0)
);
end entity RX;
 
 
architecture RX_ARC of RX is

signal RX_FLAG		:  STD_LOGIC := '0';
signal INDEX      	:  INTEGER RANGE 0 TO 9     := 0;
signal PRSCL_TICK	:  INTEGER RANGE 0 TO PRSCL := 0;
signal RX_DATA_BUF	:  STD_LOGIC_VECTOR(9 DOWNTO 0);

begin


RX_STATUS <= RX_FLAG;

							 
RX_PROCESS : PROCESS(CLK, RST) is
begin

	if(RST = '0') 
	then
		PRSCL_TICK 	 <=   0;
		INDEX    	 <=   0;
		RX_FLAG    	 <=  '0';
		RX_DATA_BUF  <=  (others => '0');
		
		
	elsif(rising_edge(CLK)) then

	
		-- RX STATUS : IDLE --
	
		if(RX_FLAG = '0' AND  RX_LINE = '0') 
		then 
			INDEX  		<=  0; 
			PRSCL_TICK  <=  0; 
			RX_FLAG  	<= '1';
			RX_DATA_BUF <= (others => '0');
		end if;
	 
	 
		-- RX STATUS : START --
	 
		if(RX_FLAG = '1') 
		then 
			
			RX_DATA_BUF(INDEX) <= RX_LINE;
			
			if(PRSCL_TICK < PRSCL) 
			then 
				PRSCL_TICK <= PRSCL_TICK + 1;
			else 
				PRSCL_TICK <= 0;
			end if;
		  
		  
		   if(PRSCL_TICK = PRSCL/2) 
		   then
				 if(INDEX < 9) then
						INDEX   <=  INDEX + 1;
				 else	 
						if(RX_DATA_BUF(0) = '0' and RX_DATA_BUF(9) = '1') 
						then
							RX_DATA <= RX_DATA_BUF(8 DOWNTO 1);	
						else 
							RX_DATA <= (others => '0');
						end if;
						
						RX_FLAG <= '0';
				 end if;
		   
		   end if;  
		  
		end if;
		
	end if;
	
end process RX_PROCESS;


end architecture RX_ARC;