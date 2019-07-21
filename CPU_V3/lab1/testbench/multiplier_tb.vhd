library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity multiplier_tb is
end;

architecture bench of multiplier_tb is
    signal A, B : unsigned(7 downto 0);
    signal P    : unsigned(15 downto 0);

    component multiplier is
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

begin
    multiplier_0 : multiplier port map(
            A => A,
            B => B,
            P => P
        );

    process
        variable err         : boolean := false;
        variable line_output : line;
    begin
        for i in 0 to 255 loop
            for j in 0 to 255 loop
                A <= to_unsigned(i, 8);
                B <= to_unsigned(j, 8);
                wait for 5 ns;
                if (P /= (i * j) and not err) then
                    err := true;
                    report "not matching!" severity ERROR;
                end if;
            end loop;
        end loop;

        line_output := new string'("===================================================================");
        writeline(output, line_output);
        if (err) then
            line_output := new string'("Errors encountered during simulation.");
        else
            line_output := new string'("Simulation is successful");
        end if;
        writeline(output, line_output);
        line_output := new string'("===================================================================");
        writeline(output, line_output);

        wait;
    end process;

end bench;
