library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is
	COMPONENT ROM_Block
     PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
	SIGNAL s_rddata : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_enableTriStateD, s_enableTriStateQ : std_logic;
begin 
	rom0: ROM_Block
        PORT MAP (address => address,
				  clock => clk, 
				  q => s_rddata);
		
	--Fsm of tri state buffer	
	triStateEnable: process (clk) is 
	begin 
		if (rising_edge(clk)) then 
			s_enableTriStateQ <= s_enableTriStateD;
		end if; 
	end process triStateEnable;
	s_enableTriStateD <= read and cs;
	
	rddata <= s_rddata when s_enableTriStateQ = '1' else (others =>'Z');
end synth;
