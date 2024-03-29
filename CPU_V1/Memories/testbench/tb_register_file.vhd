library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_file is
end;

architecture bench of tb_register_file is

    -- declaration of register_file interface
    -- INSERT COMPONENT DECLARATION HERE

    signal aa, ab, aw   : std_logic_vector(4 downto 0);
    signal a, b, wrdata : std_logic_vector(31 downto 0);
    signal wren         : std_logic := '0';
    -- clk initialization
    signal clk, stop    : std_logic := '0';
    -- clk period definition
    constant CLK_PERIOD : time      := 40 ns;

begin

    -- register_file instance
    -- INSERT REGISTER FILE INSTANCE HERE
	
	register_file : entity work.register_file
	port map(clk => clk,
			 aa => aa,
			 ab => ab,
			 aw => aw,
			 wren => wren,
			 wrdata => wrdata,
			 a => a,
			 b => b);
	
    clock_gen : process
    begin
        -- it only works if clk has been initialized
        if stop = '0' then
            clk <= not clk;
            wait for (CLK_PERIOD / 2);
        else
            wait;
        end if;
    end process;

    process
    begin
        -- init
        wren   <= '0';
        aa     <= "00000";
        ab     <= "00001";
        aw     <= "00000";
        wrdata <= (others => '0');
        wait for 5 ns;

        -- write in the register file
        wren <= '1';
        for i in 0 to 31 loop
            -- std_logic_vector(to_unsigned(number, bitwidth))
            aw     <= std_logic_vector(to_unsigned(i, 5));
            wrdata <= std_logic_vector(to_unsigned(i + 1, 32));
            wait for CLK_PERIOD;
        end loop;

        -- read in the register file
        -- INSERT CODE THAT READS THE REGISTER FILE HERE
		for i in 1 to 31 loop
            -- std_logic_vector(to_unsigned(number, bitwidth))
            aa     <= std_logic_vector(to_unsigned(i, 5));
            wait for CLK_PERIOD;
			assert a = std_logic_vector(to_unsigned(i + 1, 32))
			report "Unexpected result: " &
				   "a expected = " & integer'image(i + 1) &
				   "a actual = " & integer'image(to_integer(unsigned(a)))
			severity error;
        end loop;
		
		for i in 1 to 31 loop
            -- std_logic_vector(to_unsigned(number, bitwidth))
			ab 	   <= std_logic_vector(to_unsigned(i, 5));
            wait for CLK_PERIOD;
			assert b = std_logic_vector(to_unsigned(i + 1, 32))
			report "Unexpected result: " &
					"b expected = " & integer'image(i + 1) &
					"b actual = " & integer'image(to_integer(unsigned(b)))
			severity error;
        end loop;

        stop <= '1';
        wait;
    end process;
end bench;
