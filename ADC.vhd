library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC is
port (	
	
	--- ADC Pins ---
	Clk      :  IN  STD_LOGIC;
	oDIN     :  OUT STD_LOGIC;
	oCS_n    :  OUT STD_LOGIC;
	oSCLK    :  OUT STD_LOGIC;
	iDOUT    :  IN  STD_LOGIC;
	
	--- ADC Datas ---
	ADC_CH0  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH1  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH2  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH3  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH4  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH5  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH6  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH7  :  OUT INTEGER RANGE 0 TO 4095;
	
	--- Test Output ---
	TEST_OUT :  OUT STD_LOGIC  	
	
);
end entity ADC;


architecture ADC_ARC of ADC is

type   ADC_STATE is ( ADC_SEL, TRIGGER, ACQUIRE, STORE );
signal NEXT_STATE	  : ADC_STATE;
signal oCLK	   	  : STD_LOGIC := '0';
signal CS_BUF       : STD_LOGIC := '0';
signal TEST_OUT_BUF : STD_LOGIC := '0';

begin


oCS_n 	 <=  CS_BUF;
TEST_OUT  <=  TEST_OUT_BUF;


--- SCLK Selection ---

with NEXT_STATE select
   oSCLK 	<=  not oCLK  when ACQUIRE,
			    '1'       	  when others;	


---------------------------------------------------------
--- 			 2.5MHz Clock for ADC 				  ---
---------------------------------------------------------
				 
CLK_DELAY : process(CLK)

	variable CLK_DELAY_COUNT : INTEGER range 0 to 20;
	
begin
	if(rising_edge(CLK)) then
		
		if(CLK_DELAY_COUNT  = 20)
		then
			oCLK <= not oCLK;
			CLK_DELAY_COUNT := 0;
		else
			CLK_DELAY_COUNT := CLK_DELAY_COUNT + 1;
		end if;
		
	end if;
		
end process CLK_DELAY;				 
				 

---------------------------------------------------------				 
--- 			    ADC State Machine 				  ---
---------------------------------------------------------
				 
ADC_FSM : process( oCLK )
	
	variable  DATA_COUNT   : INTEGER RANGE 0 TO 15;
	variable  ADC_CH       : INTEGER RANGE 0 TO 7;
	variable  ADC_DATA_BUF : INTEGER RANGE 0 TO 4095;
	variable  iCH 		     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	variable  ADC_DATA     : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
begin

	if(rising_edge( oCLK )) 
	then
		
		case (NEXT_STATE) is
				
			--- ADC Channel Selection ---
		
			when ADC_SEL =>  
				
					iCH := STD_LOGIC_VECTOR(TO_UNSIGNED( ADC_CH, 3 ));

					if(ADC_CH = 7) then
						ADC_CH := 0;  TEST_OUT_BUF <= not TEST_OUT_BUF;
					else 
						ADC_CH := ADC_CH + 1;
					end if;
					
					NEXT_STATE <= TRIGGER;
				
		
			--- Trigger ADC Conversion ---
		
			when TRIGGER  =>
			
				if(CS_BUF = '0') then
					CS_BUF     <= '1';
				   NEXT_STATE <= TRIGGER;
				else 
					CS_BUF     <= '0';
					NEXT_STATE <= ACQUIRE;
				end if;	
				
				
			--- Sample ADC Data ---	
		
			when ACQUIRE  =>
		
				case (DATA_COUNT) is 
					
					when 1   	=>  	oDIN		 	 <=  iCH(2);
					when 2   	=>  	oDIN  		 <=  iCH(1);
					when 3   	=>  	oDIN  		 <=  iCH(0);  
					when 4		=>		ADC_DATA(11) :=  iDOUT;
					when 5   	=>  	ADC_DATA(10) :=  iDOUT;
					when 6   	=>  	ADC_DATA(9)  :=  iDOUT;
					when 7   	=>  	ADC_DATA(8)  :=  iDOUT;
					when 8   	=>  	ADC_DATA(7)  :=  iDOUT;
					when 9   	=>  	ADC_DATA(6)  :=  iDOUT;
					when 10   	=>  	ADC_DATA(5)  :=  iDOUT;
					when 11  	=>  	ADC_DATA(4)  :=  iDOUT;
					when 12  	=>  	ADC_DATA(3)  :=  iDOUT;
					when 13  	=>  	ADC_DATA(2)  :=  iDOUT;
					when 14  	=>  	ADC_DATA(1)  :=  iDOUT;
					when 15  	=>  	ADC_DATA(0)  :=  iDOUT;
					when others =>
					
			   end case;
		
		
				if(DATA_COUNT = 15) 
				then 
					DATA_COUNT   :=  0;
					NEXT_STATE   <=  STORE;
				else 
					DATA_COUNT   :=  DATA_COUNT + 1;
					NEXT_STATE   <=  ACQUIRE;
				end if;
					
			
			--- Copy ADC Data ---
	
			when STORE   =>
			
				ADC_DATA_BUF :=  to_integer(UNSIGNED(ADC_DATA));
				
				case (ADC_CH) is
					
					when 0  		=>  	ADC_CH6 <= ADC_DATA_BUF;
					when 1  		=>  	ADC_CH7 <= ADC_DATA_BUF;
					when 2 		=>  	ADC_CH0 <= ADC_DATA_BUF;
					when 3  		=>  	ADC_CH1 <= ADC_DATA_BUF;
					when 4  		=>  	ADC_CH2 <= ADC_DATA_BUF;
					when 5  		=>  	ADC_CH3 <= ADC_DATA_BUF;
					when 6  		=>  	ADC_CH4 <= ADC_DATA_BUF;
					when 7  		=>  	ADC_CH5 <= ADC_DATA_BUF;
					when others =>
					
				end case;
	
				NEXT_STATE <= ADC_SEL;
				
	
			--- Other Invalid cases ---	
				
			when others   =>  NEXT_STATE <= ADC_SEL;
				
		end case;
	end if;
end process ADC_FSM;
		

end architecture ADC_ARC;


