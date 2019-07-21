library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0) := X"00000000"
    );
end control_registers;

architecture synth of control_registers is

SIGNAL r_status, r_estatus, r_bstatus, r_ienable, r_ipending, r_cpuid: std_logic_vector(31 downto 0);

begin

--output logic 
	ipending <= '1' when r_status(0) = '1' and (r_ipending /= X"00000000") else '0';
	r_ipending <= (r_ienable and irq);
	
-- read 
	rddata <= X"0000000" & "000" & r_status(0) when unsigned(address) = 0 else	
			  X"0000000" & "000" & r_estatus(0) when unsigned(address) = 1 else 
			  r_bstatus  when unsigned(address) = 2 else
			  r_ienable  when unsigned(address) = 3 else 
			  r_ipending when unsigned(address) = 4;
			  
-- write 
    writting: PROCESS (clk, reset_n, write_n) 
	BEGIN 
		IF (reset_n = '0') THEN
			r_status <= (OTHERS => '0');
			r_estatus <= (OTHERS => '0');
			r_bstatus <= (OTHERS => '0');
			r_ienable <= (OTHERS => '0');
			r_cpuid <= (OTHERS => '0');
		ELSIF (rising_edge(clk)) THEN
			IF (backup_n = '0') THEN
				r_estatus(0) <= r_status(0);
				r_status(0) <= '0';
			END IF;
			IF (restore_n = '0') THEN
				r_status(0) <= r_estatus(0);
			END IF;
			IF (write_n = '0') THEN 
				case address is
					when "000" => r_status <= wrdata;
					when "001" => r_estatus <= wrdata;
					when "010" => r_bstatus <= wrdata;
					when "011" => r_ienable <= wrdata;
					when OTHERS => 
				 end case;
			END IF;
		END IF;
	END PROCESS;
	

	
end synth;
