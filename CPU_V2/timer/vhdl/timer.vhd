library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);

        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is
	SIGNAL s_writtenToPeriod : std_logic;
	SIGNAL s_writeEn, s_readEn : std_logic; 
	SIGNAL latency_read, latency_cs: std_logic; 
	SIGNAL latency_address: std_logic_vector(1 DOWNTO 0); 
	SIGNAL r_period, r_status, r_control, r_counter: std_logic_vector (31 downto 0);
begin
	--write interface and counter / period handeling & counter finite state machine 
	s_writeEn <= cs and write;
	writing: PROCESS (clk, reset_n) IS
	BEGIN
		IF (reset_n = '0') THEN 
			r_period <= (OTHERS => '0');
			r_status <= (OTHERS => '0');
			r_control<= (OTHERS => '0'); 
			r_counter<= (OTHERS => '0');
		ELSIF(rising_edge(clk)) THEN
			IF(unsigned(r_counter) = 0 and r_status(1) = '1') THEN 
				r_status(1 DOWNTO 0)<= r_control(1) & '1';
				r_counter <= r_period;
			ELSIF(r_status(1) = '1' ) THEN
				r_counter <= std_logic_vector(unsigned(r_counter) - 1);
			END IF;
			IF(s_writeEn = '1') THEN 
				CASE address IS 
					WHEN "00" => r_status(0) <= wrdata(0) and r_status(0);
					WHEN "01" => r_control(3 downto 0) <= wrdata(3 downto 0);
								 IF (wrdata(3) = '1') THEN 
									r_status(1) <= '0'; 
								 ELSE 
									r_status(1) <= '1'; 
								 END IF; 
					WHEN "10" => r_period <= wrdata;
								 r_counter <= wrdata; 
								 r_status(1) <= '0';
					WHEN OTHERS => 
				END CASE; 
			END IF;
			
		END IF;
	END PROCESS;

	--read interface
	reading: PROCESS (clk) IS
	BEGIN 
		IF(rising_edge(clk)) THEN 
			latency_address <= address;
			latency_cs <= cs;
			latency_read <= read; 
		END IF; 
	END PROCESS;
	s_readEn <= latency_read and latency_cs;
	rddata <= (OTHERS => 'Z') when s_readEn = '0' else 
			  r_counter when latency_address = "11" else 
			  r_period  when latency_address = "10" else 
			  X"0000000" & "00" & r_status(1 DOWNTO 0) when latency_address = "00" else 
			  X"0000000" & "00" & r_control(1 DOWNTO 0);
			  

	
	
	--output logic 
	irq <= r_status(0) and r_control(0);
end synth;
