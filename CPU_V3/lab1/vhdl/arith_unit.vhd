library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_unit is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
    );
end arith_unit;

-- =============================================================================
-- =============================== COMBINATORIAL ===============================
-- =============================================================================

architecture combinatorial of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;
    signal s_mux1  : unsigned(7 downto 0);
    signal s_mux2  : unsigned(7 downto 0);
    signal s_mux3  : unsigned(7 downto 0);
    signal s_mux4  : unsigned(15 downto 0);
    signal s_mux5 : unsigned(15 downto 0);
    signal s_mux6 : unsigned(15 downto 0);
    signal s_mult1 : unsigned(15 downto 0);
    signal s_mult1_afterAdd : unsigned(15 downto 0);
    signal s_mult2_afterAdd : unsigned(15 downto 0);
    signal s_mult2 : unsigned(15 downto 0);
    signal s_quarterLL3 : unsigned(15 downto 0);
    signal s_quarterLH3 : unsigned(15 downto 0);
    signal s_quarterHL3 : unsigned(15 downto 0);
    signal s_quarterHH3 : unsigned(15 downto 0);
    signal s_mult3 : unsigned(31 downto 0);
    signal s_muxFinal : unsigned(31 downto 0);
begin
    done <= start;
    s_mux1 <= C when sel = '1' else B;
    mult1 : multiplier 
    port map (
        A => A, 
        B => s_mux1,
        P => s_mult1
    );
    s_mux2 <= B when sel = '1' else A;
    s_mux3 <= B when sel = '1' else X"05";
    mult2 : multiplier 
    port map (
        A => s_mux2, 
        B => s_mux3,
        P => s_mult2
    );
    s_mux6 <= "0000000" & A & '0' when sel = '1' else X"00" & B;
    s_mult2_AfterAdd <= s_mux6 + s_mult2;
    s_mux4 <= X"00" & C when sel = '0' else X"0000";
    s_mult1_afterAdd <= (s_mult1 + s_mux4);
    s_mux5 <= s_mult1 when sel = '1' else s_mult2_afterAdd;
    multLL : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(7 downto 0),
        P => s_quarterLL3
    );
    multLH : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(15 downto 8),
        P => s_quarterLH3
    );
    multHL : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(7 downto 0),
        P => s_quarterHL3
    );
    multHH : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(15 downto 8),
        P => s_quarterHH3
    );
    s_mult3 <= (X"0000"&s_quarterLL3) + (X"00" & s_quarterLH3 & X"00") + (X"00" & s_quarterHL3 & X"00") + (s_quarterHH3 & X"0000");
    s_muxFinal <= s_mult3 when sel = '0' else ((X"0000" & s_mult2_AfterAdd) + s_mult3);
    D <= s_muxFinal;
end combinatorial;

-- =============================================================================
-- ============================= 1 STAGE PIPELINE ==============================
-- =============================================================================

architecture one_stage_pipeline of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;
    signal s_sel : std_logic;
    signal s_mux1  : unsigned(7 downto 0);
    signal s_mux2  : unsigned(7 downto 0);
    signal s_mux3  : unsigned(7 downto 0);
    signal s_mux4  : unsigned(15 downto 0);
    signal s_mux5 : unsigned(15 downto 0);
    signal s_mux5pip : unsigned(15 downto 0);
    signal s_mux6 : unsigned(15 downto 0);
    signal s_mult1 : unsigned(15 downto 0);
    signal s_mult1_afterAdd : unsigned(15 downto 0);
    signal s_mult1_afterAddpip : unsigned(15 downto 0);
    signal s_mult2_afterAdd : unsigned(15 downto 0);
    signal s_mult2 : unsigned(15 downto 0);
    signal s_quarterLL3 : unsigned(15 downto 0);
    signal s_quarterLH3 : unsigned(15 downto 0);
    signal s_quarterHL3 : unsigned(15 downto 0);
    signal s_quarterHH3 : unsigned(15 downto 0);
    signal s_mult3 : unsigned(31 downto 0);
    signal s_muxFinal : unsigned(31 downto 0);
begin
    flipflop : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            done <= '0';
            s_sel <= '0';
        elsif( rising_edge(clk) ) then
            done <= start;
            s_sel <= sel;
        end if ;
    end process ; 

    s_mux1 <= C when s_sel = '1' else B;
    mult1 : multiplier 
    port map (
        A => A, 
        B => s_mux1,
        P => s_mult1
    );
    s_mux2 <= B when s_sel = '1' else A;
    s_mux3 <= B when s_sel = '1' else X"05";
    mult2 : multiplier 
    port map (
        A => s_mux2, 
        B => s_mux3,
        P => s_mult2
    );
    s_mux6 <= "0000000" & A & '0' when s_sel = '1' else X"00" & B;
    s_mult2_AfterAdd <= s_mux6 + s_mult2;
    s_mux4 <= X"00" & C when s_sel = '0' else X"0000";
    s_mult1_afterAddpip <= (s_mult1 + s_mux4);
    s_mux5pip <= s_mult1 when s_sel = '1' else s_mult2_afterAdd;
    identifier : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult1_AfterAdd <= (others => '0');
            s_mux5 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult1_AfterAdd <= s_mult1_afterAddpip;
            s_mux5 <= s_mux5pip;
        end if ;
    end process ; -- identifier
    multLL : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(7 downto 0),
        P => s_quarterLL3
    );
    multLH : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(15 downto 8),
        P => s_quarterLH3
    );
    multHL : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(7 downto 0),
        P => s_quarterHL3
    );
    multHH : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(15 downto 8),
        P => s_quarterHH3
    );
    s_mult3 <= (X"0000"&s_quarterLL3) + (X"00" & s_quarterLH3 & X"00") + (X"00" & s_quarterHL3 & X"00") + (s_quarterHH3 & X"0000");
    s_muxFinal <= s_mult3 when s_sel = '0' else (X"0000" & s_mult2_AfterAdd) + s_mult3;
    D <= s_muxFinal;
    end one_stage_pipeline;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE I =============================
-- =============================================================================
architecture two_stage_pipeline_1 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;
    signal s_sel   : std_logic;
    signal s_selpip: std_logic;
    signal s_pip1  : unsigned (15 downto 0);
    signal s_pip2  : unsigned (15 downto 0);
    signal s_pip3  : unsigned (31 downto 0);
    signal s_done  : std_logic;
    signal s_mux1  : unsigned(7 downto 0);
    signal s_mux2  : unsigned(7 downto 0);
    signal s_mux3  : unsigned(7 downto 0);
    signal s_mux4  : unsigned(15 downto 0);
    signal s_mux5 : unsigned(15 downto 0);
    signal s_mux6 : unsigned(15 downto 0);
    signal s_mult1 : unsigned(15 downto 0);
    signal s_mult1_afterAdd : unsigned(15 downto 0);
    signal s_mult2_afterAdd : unsigned(15 downto 0);
    signal s_mult2 : unsigned(15 downto 0);
    signal s_quarterLL3 : unsigned(15 downto 0);
    signal s_quarterLH3 : unsigned(15 downto 0);
    signal s_quarterHL3 : unsigned(15 downto 0);
    signal s_quarterHH3 : unsigned(15 downto 0);
    signal s_mult3 : unsigned(31 downto 0);
    signal s_muxFinal : unsigned(31 downto 0);
begin
    flipflop1 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_sel <= '0';
            s_done <= '0';
        elsif( rising_edge(clk) ) then
            s_sel <= sel;
            s_done <= start;
        end if ;
    end process ; -- flipflip
    flipflop2 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_sel <= '0';
            s_done <= '0';
        elsif( rising_edge(clk) ) then
            s_selpip <= s_sel;
            done <= s_done;
        end if ;
    end process ; -- identifier
    s_mux1 <= C when s_selpip = '1' else B;
    mult1 : multiplier 
    port map (
        A => A, 
        B => s_mux1,
        P => s_pip1
    );
    multpip1 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult1 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult1 <= s_pip1;
        end if ;
    end process ; -- multpip1
    s_mux2 <= B when s_selpip = '1' else A;
    s_mux3 <= B when s_selpip = '1' else X"05";
    mult2 : multiplier 
    port map (
        A => s_mux2, 
        B => s_mux3,
        P => s_pip2
    );
    multpip2 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult2 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult2 <= s_pip2;
        end if ;
    end process ; -- multpip2
    s_mux6 <= "0000000" & A & '0' when s_selpip = '1' else X"00" & B;
    s_mult2_AfterAdd <= s_mux6 + s_mult2;
    s_mux4 <= X"00" & C when s_selpip = '0' else X"0000";
    s_mult1_afterAdd <= (s_mult1 + s_mux4);
    s_mux5 <= s_mult1 when s_selpip = '1' else s_mult2_afterAdd;
    multLL : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(7 downto 0),
        P => s_quarterLL3
    );
    multLH : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(15 downto 8),
        P => s_quarterLH3
    );
    multHL : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(7 downto 0),
        P => s_quarterHL3
    );
    multHH : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(15 downto 8),
        P => s_quarterHH3
    );
    s_pip3 <= (X"0000"&s_quarterLL3) + (X"00" & s_quarterLH3 & X"00") + (X"00" & s_quarterHL3 & X"00") + (s_quarterHH3 & X"0000");
    multpip3 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult3 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult3 <= s_pip3;
        end if ;
    end process ; -- multpip3
    s_muxFinal <= s_mult3 when s_selpip = '0' else (X"0000" & s_mult2_AfterAdd) + s_mult3;
    D <= s_muxFinal;
end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================

architecture two_stage_pipeline_2 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16_pipeline
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            A, B    : in  unsigned(15 downto 0);
            P       : out unsigned(31 downto 0)
        );
    end component;
    signal s_sel : std_logic;
    signal s_selpip: std_logic;
    signal s_pip1  : unsigned (15 downto 0);
    signal s_pip2  : unsigned (15 downto 0);
    signal s_pip31  : unsigned (31 downto 0);
    signal s_pip32  : unsigned (31 downto 0);
    signal s_done  : std_logic;
    signal s_mux1  : unsigned(7 downto 0);
    signal s_mux2  : unsigned(7 downto 0);
    signal s_mux3  : unsigned(7 downto 0);
    signal s_mux4  : unsigned(15 downto 0);
    signal s_mux5 : unsigned(15 downto 0);
    signal s_mux6 : unsigned(15 downto 0);
    signal s_mult1 : unsigned(15 downto 0);
    signal s_mult1_afterAdd : unsigned(15 downto 0);
    signal s_mult2_afterAdd : unsigned(15 downto 0);
    signal s_mult2 : unsigned(15 downto 0);
    signal s_quarterLL3 : unsigned(15 downto 0);
    signal s_quarterLH3 : unsigned(15 downto 0);
    signal s_quarterHL3 : unsigned(15 downto 0);
    signal s_quarterHH3 : unsigned(15 downto 0);
    signal s_mult3 : unsigned(31 downto 0);
    signal s_muxFinal : unsigned(31 downto 0);
begin
    flipflop1 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_sel <= '0';
            s_done <= '0';
        elsif ( rising_edge(clk) ) then
            s_sel <= sel;
            s_done <= start;
        end if ;
    end process ; -- flipflip
    flipflop2 : process( clk )
    begin
        if (reset_n = '0') then 
            s_sel <= '0';
            done <= '0';
        elsif( rising_edge(clk) ) then
            s_selpip <= s_sel;
            done <= s_done;
        end if ;
    end process ; -- identifier
    s_mux1 <= C when s_selpip = '1' else B;
    mult1 : multiplier 
    port map (
        A => A, 
        B => s_mux1,
        P => s_pip1
    );
    multpip1 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult1 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult1 <= s_pip1;
        end if ;
    end process ; -- multpip1
    s_mux2 <= B when s_selpip = '1' else A;
    s_mux3 <= B when s_selpip = '1' else X"05";
    mult2 : multiplier 
    port map (
        A => s_mux2, 
        B => s_mux3,
        P => s_pip2
    );
    multpip2 : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_mult2 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_mult2 <= s_pip2;
        end if ;
    end process ; -- multpip2
    s_mux6 <= "0000000" & A & '0' when s_selpip = '1' else X"00" & B;
    s_mult2_AfterAdd <= s_mux6 + s_mult2;
    s_mux4 <= X"00" & C when s_selpip = '0' else X"0000";
    s_mult1_afterAdd <= (s_mult1 + s_mux4);
    s_mux5 <= s_mult1 when s_selpip = '1' else s_mult2_afterAdd;
    multLL : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(7 downto 0),
        P => s_quarterLL3
    );
    multLH : multiplier 
    port map (
        A => s_mult1_AfterAdd(7 downto 0), 
        B => s_mux5(15 downto 8),
        P => s_quarterLH3
    );
    fm : process( clk, reset_n )
    begin
        if (reset_n = '0') then 
            s_pip31 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_pip31 <= (X"0000"&s_quarterLL3) + (X"00" & s_quarterLH3 & X"00");
        end if ;
    end process ; 
    multHL : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(7 downto 0),
        P => s_quarterHL3
    );
    multHH : multiplier 
    port map (
        A => s_mult1_AfterAdd(15 downto 8), 
        B => s_mux5(15 downto 8),
        P => s_quarterHH3
    );
    sm : process( clk )
    begin
        if (reset_n = '0') then 
            s_pip32 <= (others => '0');
        elsif( rising_edge(clk) ) then
            s_pip32 <= (X"00" & s_quarterHL3 & X"00") + (s_quarterHH3 & X"0000");
        end if ;
    end process ; -- identifier
    s_mult3 <= s_pip32 + s_pip31;
    s_muxFinal <= s_mult3 when s_selpip = '0' else (X"0000" & s_mult2_AfterAdd) + s_mult3;
    D <= s_muxFinal;
end two_stage_pipeline_2;

