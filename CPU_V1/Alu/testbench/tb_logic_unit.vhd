library ieee;
use ieee.std_logic_1164.all;

entity tb_logic_unit is
end tb_logic_unit;

architecture testbench of tb_logic_unit is
    signal a, b, r : std_logic_vector(31 downto 0);
    signal op      : std_logic_vector(1 downto 0);

    -- declaration of the logic_unit interface
    component logic_unit is
        port(
            a  : in  std_logic_vector(31 downto 0);
            b  : in  std_logic_vector(31 downto 0);
            op : in  std_logic_vector(1 downto 0);
            r  : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- logic unit instance
    logic_unit_0 : logic_unit port map(
            a  => a,
            b  => b,
            op => op,
            r  => r
        );

    -- process for verification of the logic unit
    check : process
    begin
        -- This is the 4 possible 2 bits combinaisons between A and B
        a <= (31 downto 4 => '0') & "1100";
        b <= (31 downto 4 => '0') & "1010";
        op <= "00";
        -- A NOR B
        -- assign the correct value to op to test A NOR B
        wait for 20 ns;                 -- wait for circuit to settle
        -- insert an ASSERT statement here
        ASSERT r = ( a nor b )
            REPORT "Incorrect_Nor_Behavior"
            SEVERITY warning;
        op <= "01";
        -- A AND B
        -- assign the correct value to op to test A AND B
        wait for 20 ns;                 -- wait for circuit to settle
        -- insert an ASSERT statement here
        ASSERT r = ( a and b )
            REPORT "Incorrect_Nor_Behavior"
            SEVERITY warning;
        op  <= "10";
        -- A OR B
        -- assign the correct value to op to test A OR B
        wait for 20 ns;                 -- wait for circuit to settle
        -- insert an ASSERT statement here
        ASSERT r = ( a or b )
            REPORT "Incorrect_Nor_Behavior"
            SEVERITY warning;
        op <= "11";
        -- A XNOR B
        -- assign the correct value to op to test A XNOR B
        wait for 20 ns;  
        -- wait for circuit to settle
        -- insert an ASSERT statement here
        ASSERT r = ( a xnor b )
            REPORT "Incorrect_Nor_Behavior"
            SEVERITY warning;
        wait;                           -- wait forever
    end process;

end testbench;
