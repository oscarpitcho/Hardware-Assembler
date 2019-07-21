library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is

SIGNAL s_mux1, s_mux3, s_adder, s_currentstate, s_nextstate: std_logic_vector (15 downto 0);
    
begin

	--transition logic 
	
	s_nextstate <= s_mux3 when sel_a = '1' or sel_imm = '1' or sel_ihandler = '1' else s_adder; 
	s_adder <= std_logic_vector(unsigned(s_mux1) + unsigned(s_currentstate));
	s_mux1 <= imm when add_imm = '1' else X"0004";
	s_mux3 <= X"0004" when sel_ihandler = '1' else a when sel_a = '1' else (imm(13 downto 0) & "00");
	
	--flipflop 
	FP: PROCESS (clk, reset_n) 
	begin 
		IF (reset_n = '0') THEN 
			s_currentstate <= (OTHERS => '0');
		ELSIF (rising_edge(clk) and en = '1') THEN 
			s_currentstate <= s_nextstate;
		END IF;
	END PROCESS;

	-- output logic 
	
	addr <= X"0000" & s_currentstate;
	
    
end synth;
