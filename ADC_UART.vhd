library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_UART is
port (	
	CLK       :  IN  STD_LOGIC;
	RST		 :  IN  STD_LOGIC;  
	RX_DATA   :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	TEST_OUT  :  OUT STD_LOGIC;
	
	--- UART TX Pin --
	TX_LINE   :  OUT STD_LOGIC;
	RX_LINE	 :  IN  STD_LOGIC;
	
	--- ADC Pins ---
	oDIN      :  OUT STD_LOGIC;
	oCS_n     :  OUT STD_LOGIC;
	oSCLK     :  OUT STD_LOGIC;
	iDOUT     :  IN  STD_LOGIC 
);	
end entity ADC_UART;


architecture ADC_UART_ARC of ADC_UART is

type BUFFER_DATAS is array (7 DOWNTO 0) of INTEGER RANGE 0 TO 4095;
signal ADC_BUF_CH : BUFFER_DATAS;

signal TX_DATA_BUF   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal RX_DATA_BUF   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal TX_READY_BUF  : STD_LOGIC;
signal TX_START_BUF  : STD_LOGIC;
signal RX_STATUS_BUF : STD_LOGIC;
signal TEST_OUT_BUF  : STD_LOGIC;

begin						  

	RX_DATA 	  <=  RX_DATA_BUF;
	TEST_OUT   <=  TEST_OUT_BUF;

	ADC_8CH : entity work.ADC
			    port map( 	
								CLK         =>  CLK,
								oDIN        =>  oDIN,
								oCS_n       =>  oCS_n,
								oSCLK       =>  oSCLK,
								iDOUT       =>  iDOUT,
		
								-- ADC Data Buffers --						  
								ADC_CH0     =>  ADC_BUF_CH(0), 
								ADC_CH1     =>  ADC_BUF_CH(1),
								ADC_CH2     =>  ADC_BUF_CH(2),
								ADC_CH3     =>  ADC_BUF_CH(3),
								ADC_CH4     =>  ADC_BUF_CH(4),
								ADC_CH5     =>  ADC_BUF_CH(5),
								ADC_CH6     =>  ADC_BUF_CH(6),
								ADC_CH7     =>  ADC_BUF_CH(7),
								
								--- Test Output ---
								TEST_OUT    =>  TEST_OUT_BUF  );
							 
							 
	TX_MOD : entity work.TX_CTRL
				generic map( 
								TX_DATA_NUM 	=>  	8,
								TX_DATA_DELAY  =>  	1250000 )
							 
				port map ( 	CLK         	=>  	CLK,	
			
								-- ADC Data Buffers --
								TX_DATA_A   	=>  	ADC_BUF_CH(0),
								TX_DATA_B   	=>  	ADC_BUF_CH(1),
								TX_DATA_C   	=>  	ADC_BUF_CH(2),
								TX_DATA_D   	=>  	ADC_BUF_CH(3),
								TX_DATA_E   	=>  	ADC_BUF_CH(4),
								TX_DATA_F   	=>  	ADC_BUF_CH(5),
								TX_DATA_G   	=>  	ADC_BUF_CH(6),
								TX_DATA_H   	=>  	ADC_BUF_CH(7),
							 
								TX_READY    	=>  	TX_READY_BUF,				 
								TX_START    	=>  	TX_START_BUF,
								TX_DATA     	=> 	TX_DATA_BUF );
							 
							 
	TX_232 : entity work.TX
				generic map( 
								PRSCL       	=>  	5207 )   -- 9600 baud rate ~ 50MHz/PRSCL---
								
				port map   ( CLK         	=>  	CLK,
								TX_LINE     	=>  	TX_LINE,
								TX_START    	=>  	TX_START_BUF,
								TX_READY    	=>  	TX_READY_BUF,
								TX_DATA     	=>  	TX_DATA_BUF );		
								
								
	RX_232 : entity work.RX
				generic map( 
								PRSCL       	=>  	5207 )   -- 9600 baud rate ~ 50MHz/PRSCL---
								
				port map   ( CLK         	=>  	CLK,
								RST         	=>  	RST,
								RX_LINE     	=>  	RX_LINE,
								RX_STATUS   	=>  	RX_STATUS_BUF,
								RX_DATA     	=>  	RX_DATA_BUF );

							 
end architecture ADC_UART_ARC;



