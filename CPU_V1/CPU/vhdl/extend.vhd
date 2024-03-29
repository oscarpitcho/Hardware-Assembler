library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
signal s_imm16 : std_logic_vector (15 downto 0);
begin 
	s_imm16 <= (others => imm16 (15));
	imm32 <= X"0000"& imm16 when signed = '0' else s_imm16 & imm16;
end synth;
