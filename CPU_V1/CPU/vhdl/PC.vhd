library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
signal current_addr : std_logic_vector(15 downto 0);
signal next_addr    : std_logic_vector(15 downto 0);
begin
	--transition logic 
	next_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(current_addr)) + to_integer(unsigned(imm)), 16)) when add_imm = '1' else
			  imm (13 downto 0) & "00"                                                                                 when sel_imm = '1' else 
              a (15 downto 2) & "00"                                                                                   when sel_a = '1' else 
			  std_logic_vector(to_unsigned(to_integer(unsigned(current_addr)) + 4, 16));
			  
	--flipflop		  
	next_address : process (clk, reset_n) is 
	begin 
		if (reset_n = '0') then 
			current_addr <= (others => '0');
		elsif (rising_edge(clk) and en = '1') then 
			current_addr <= next_addr;
		end if;
	end process next_address;
	
	--output logic
	addr (31 downto 16) <= (others => '0');
	addr (15 downto 0) <= current_addr;
end synth;
