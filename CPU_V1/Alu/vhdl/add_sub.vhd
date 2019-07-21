library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
SIGNAL s_sub: std_logic_vector (31 DOWNTO 0);
SIGNAL s_subL, s_bADD, s_r: std_logic_vector (32 DOWNTO 0);
	begin
		s_sub <= (31 DOWNTO 0 => sub_mode);
		s_subL <= (0 => sub_mode, OTHERS => '0');
		s_bADD <= '0' & (b XOR s_sub); 
		s_r <= std_logic_vector (unsigned(s_bADD) + unsigned(s_subL) + unsigned('0' & a));
		carry <= s_r (32);
		zero <= '1' WHEN s_r (31 downto 0) = std_logic_vector (to_unsigned (0, 32)) ELSE '0';
		r <= s_r (31 DOWNTO 0);

end synth;
