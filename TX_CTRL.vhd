library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TX_CTRL is
generic (
	TX_DATA_NUM 	: INTEGER := 8;
	TX_DATA_DELAY 	: INTEGER := 1250000
);
port (	
	CLK         : IN  STD_LOGIC;
	TX_READY    : IN  STD_LOGIC;
	
	TX_DATA_A   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_B   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_C   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_D   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_E   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_F   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_G   : IN  INTEGER RANGE 0 TO 4095;
	TX_DATA_H   : IN  INTEGER RANGE 0 TO 4095;
	
	TX_START    : OUT STD_LOGIC;
	TX_DATA     : OUT STD_LOGIC_VECTOR(7 downto 0)
);
end entity TX_CTRL;


architecture TX_CTRL_ARC of TX_CTRL is


type TX_STATES is (SELECT_DATA, TRANSMIT_DATA, TX_DELAY);

signal NEXT_STATE    :  TX_STATES;
signal DATA_END	     :  STD_LOGIC_VECTOR(7 DOWNTO 0);
signal TX_DATA_BUF   :  INTEGER RANGE 0 TO 4095;
signal oCLK          :  STD_LOGIC := '0';

begin


---------------------------------------------------------
--- 	        Slowing Clock for SYNC 		      ---
---------------------------------------------------------

CLK_PROCESS  : process(CLK) 
	variable CLK_COUNT : INTEGER RANGE 0 TO 5;
begin
	
	if(rising_edge(CLK)) then
		
		if(CLK_COUNT = 4) 
		then
			CLK_COUNT :=  0;
			oCLK      <= not oCLK;
		else
			CLK_COUNT := CLK_COUNT + 1;
		end if;	
			
	end if;
		
end process CLK_PROCESS;


---------------------------------------------------------
--- 		   TX Process : FSM 		      ---
---------------------------------------------------------

COMB_PROCESS : process(oCLK, NEXT_STATE, TX_DATA_A, TX_DATA_B, TX_DATA_C, TX_DATA_D)
	
	TYPE dataArray  IS ARRAY (0 to 5) of STD_LOGIC_VECTOR(7 DOWNTO 0);
	variable TX_PACKET  	 : dataArray := ( X"30", X"30", X"30", X"30", X"41", X"0a" );
	variable DATA_NUM	 : INTEGER  RANGE  0  TO  TX_DATA_NUM-1;
	variable DATA_PACK_NUM   : INTEGER  RANGE  0  TO  6;
	variable TX_DELAY_COUNT  : INTEGER  RANGE  0  TO  TX_DATA_DELAY;

begin
	
	if(rising_edge(oCLK))
	then
	
		case (NEXT_STATE) is
			
			--- Select which data to send & format packets ---
			
			when SELECT_DATA    =>
			
				case (DATA_NUM) is

					when 0  =>  TX_DATA_BUF <= TX_DATA_A; 	DATA_END <= X"41";
					when 1  =>  TX_DATA_BUF <= TX_DATA_B; 	DATA_END <= X"42";
					when 2  =>  TX_DATA_BUF <= TX_DATA_C; 	DATA_END <= X"43";
					when 3 	=>  TX_DATA_BUF <= TX_DATA_D; 	DATA_END <= X"44";
					when 4 	=>  TX_DATA_BUF <= TX_DATA_E; 	DATA_END <= X"45";
					when 5 	=>  TX_DATA_BUF <= TX_DATA_F; 	DATA_END <= X"46";
					when 6 	=>  TX_DATA_BUF <= TX_DATA_G; 	DATA_END <= X"47";
					when 7 	=>  TX_DATA_BUF <= TX_DATA_H; 	DATA_END <= X"48";
					when others =>  DATA_END <= X"45";

				 end case;

				 TX_PACKET(5)  :=  X"0a";
				 TX_PACKET(4)  :=  DATA_END;
				 TX_PACKET(3)  :=  STD_LOGIC_VECTOR(TO_UNSIGNED(( TX_DATA_BUF	   ) mod 10, 8) + X"30");
				 TX_PACKET(2)  :=  STD_LOGIC_VECTOR(TO_UNSIGNED(( TX_DATA_BUF/10   ) mod 10, 8) + X"30");
				 TX_PACKET(1)  :=  STD_LOGIC_VECTOR(TO_UNSIGNED(( TX_DATA_BUF/100  ) mod 10, 8) + X"30");
				 TX_PACKET(0)  :=  STD_LOGIC_VECTOR(TO_UNSIGNED(( TX_DATA_BUF/1000 ) mod 10, 8) + X"30"); 

				 DATA_NUM      :=  DATA_NUM + 1;
				 NEXT_STATE    <=  TRANSMIT_DATA;

			
			--- Transmit TX Array data ---
			
			when TRANSMIT_DATA  =>   
			
				 if(TX_READY = '1') then

					if(DATA_PACK_NUM = 6) then
						NEXT_STATE 	   <=  TX_DELAY;
						DATA_PACK_NUM  := 0;

					else 
						TX_DATA  <=  TX_PACKET(DATA_PACK_NUM);
						TX_START <= '1';

						DATA_PACK_NUM  :=  DATA_PACK_NUM + 1;
						NEXT_STATE 	   <=  TRANSMIT_DATA;
					end if;

				 else
					TX_START <= '0';
				 end if;
			
			
			--- Delay before transimitting next set of packets ---		
		
			when TX_DELAY      =>
			
				 if(TX_DELAY_COUNT = TX_DATA_DELAY) 
				 then
					TX_DELAY_COUNT  :=  0;
					NEXT_STATE 	    <=  SELECT_DATA;
				 else
					TX_DELAY_COUNT  :=  TX_DELAY_COUNT + 1;
					NEXT_STATE      <=  TX_DELAY;
				 end if;

				
			--- Other Invalid States ---
				
			when others	  =>
		
				 NEXT_STATE <= SELECT_DATA;
			
		end case;
		
	end if;
	
end process COMB_PROCESS;


end architecture TX_CTRL_ARC;
