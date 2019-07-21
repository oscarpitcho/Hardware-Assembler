library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
type RAM_type is array ( 0 to 1023 ) of std_logic_vector (31 downto 0);
signal RAM: RAM_type := ((others=> (others=>'0')));
signal s_enableTriStateD, s_enableTriState : std_logic;
signal s_transmit : std_logic := '0';
signal s_dataQ, s_dataD :  std_logic_vector (31 downto 0);
begin
-- tri-state buffer check 
	triStateEnable: process (clk) is 
	begin 
		if (rising_edge(clk)) then 
				s_enableTriState <= read and cs;
		end if; 
	end process triStateEnable;
	
	rddata <= s_dataQ when s_enableTriState = '1' else (others =>'Z');
-- read 
	obtainData: process (clk) is 
	begin 
		if (rising_edge(clk)) then
			s_dataQ <= s_dataD ;
		end if; 
	end process obtainData;
	s_dataD <= RAM (to_integer(unsigned(address)));
-- write 
    changeData: process (clk) is 
	begin 
		if (rising_edge(clk) and write = '1' and cs = '1') then 
				RAM(to_integer(unsigned(address))) <= wrdata;
		end if;
	end process changeData; 
end synth;
