library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is 
SIGNAL s_r : std_logic_vector(31 DOWNTO 0);
begin
	shift_rotate : process(a, b)
	variable v : std_logic_vector(31 downto 0);
	begin
	v := a;
	if (op = "000" ) THEN
		for i in 0 to 4 loop
		if (b(i) = '1') then
		v := v(31 - (2 ** i) downto 0) & v(31 downto 32 -(2 ** i));
		end if;
		end loop;
	ELSIF (op = "010") THEN
		for i in 0 to 4 loop
		if (b(i) = '1') then
		v := v(31 - (2 ** i) downto 0) & ((2 ** i) - 1 downto 0 => '0');
		end if;
		end loop;
	ELSIF (op = "011") THEN 
		for i in 0 to 4 loop
		if (b(i) = '1') then
		v := ((2 ** i) - 1 downto 0 => '0') & v(31 downto 2 ** i);
		end if;
		end loop;
	ELSIF (op = "111") THEN 
		for i in 0 to 4 loop
		if (b(i) = '1') then
		v := ((2 ** i) - 1 downto 0 => a(31)) & v(31 downto 2 ** (i));
		end if;
		end loop;
	ELSE 
		for i in 0 to 4 loop
		if (b(i) = '1') then
		v := v((2 ** i) - 1 DOWNTO 0) & v(31 downto 2 **i);
		end if;
		end loop;
   	END IF;
    	r <= v;
	end process;

end synth;
