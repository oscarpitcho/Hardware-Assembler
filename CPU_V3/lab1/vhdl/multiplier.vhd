-- =============================================================================
-- ================================= multiplier ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        A, B : in  unsigned(7 downto 0);
        P    : out unsigned(15 downto 0)
    );
end multiplier;

architecture combinatorial of multiplier is
    type lv1 is array (0 to 7) of unsigned(7 downto 0);
    type lv2 is array (0 to 3) of unsigned(9 downto 0);
    type lv3 is array (0 to 1) of unsigned(12 downto 0);
    signal result : unsigned (17 downto 0) := X"0000" & "00";
    signal partial_product1 : lv1;
    signal partial_product2 : lv2;
    signal partial_product3 : lv3;
begin
    level1: process (A, B) 
    begin
        for i in 0 to 7 loop 
            partial_product1(i) <= ((7 downto 0 => A(i)) and B);
        end loop; 
    end process; 

    level2: process (partial_product1) 
    begin 
        for i in 0 to 3 loop 
            partial_product2(i) <= ("00" & partial_product1(2*i)) + ('0' & partial_product1(2*i+1) & '0');
        end loop; 
    end process;

    level3: process (partial_product2) 
    begin 
        for i in 0 to 1 loop 
            partial_product3(i) <= ("000" & partial_product2(2*i)) + ('0' & partial_product2(2*i+1) & "00");
        end loop; 
    end process;

    level4: process (partial_product3)
    begin 
        result <= ("00000" & partial_product3(0)) + ('0' & partial_product3(1) & "0000");
    end process;

    P <= result(15 downto 0);
end combinatorial;

-- =============================================================================
-- =============================== multiplier16 ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16 is
    port(
        A, B : in  unsigned(15 downto 0);
        P    : out unsigned(31 downto 0)
    );
end multiplier16;

architecture combinatorial of multiplier16 is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

begin
end combinatorial;

-- =============================================================================
-- =========================== multiplier16_pipeline ===========================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16_pipeline is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        A, B    : in  unsigned(15 downto 0);
        P       : out unsigned(31 downto 0)
    );
end multiplier16_pipeline;

architecture pipeline of multiplier16_pipeline is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

begin
end pipeline;
