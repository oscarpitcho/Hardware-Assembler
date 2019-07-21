-- Authors  :   Panagiotis Athanasopoulos
--              Xavier Jimenez
-- Email    :   panagiotis.athanasopoulos@epfl.ch
--              xavier.jimenez@epfl.ch

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_lab is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        Button0 : in  std_logic;
        Button1 : in  std_logic;
        LEDS    : out std_logic_vector(95 downto 0)
    );
end pipeline_lab;

architecture synth of pipeline_lab is
    constant SIZE     : natural                                    := 128;
    constant OPERANDS : std_logic_vector((24 * SIZE) - 1 downto 0) := X"FFFFFF" & X"FFFFFF" & X"010101" & X"010101" & X"47D69A" & X"2140A4" & X"3116B2" & X"01E652" & X"B9351A" & X"AA2A64" & X"938487" & X"327D58" & X"4F3B43" & X"F45CED" & X"75BCFA" & X"C17C93" & X"C69E62" & X"B047CE" & X"8ADADC"
    & X"1FA06E" & X"E6B776" & X"873280" & X"B157E9" & X"25BE60" & X"3BFE8E" & X"A2354B" & X"F27253" & X"398057" & X"F90927" & X"0355C3" & X"EE5288" & X"7577EC" & X"996CFC" & X"263065" & X"3A5DBF" & X"6B0101" & X"9523E5" & X"75B9CA" & X"243DB8" & X"E38534" & X"D7DF1E" & X"059601" & X"6F2538" &
    X"3785B4" & X"57D89A" & X"1F857C" & X"71C1C9" & X"AC03F2" & X"6181D1" & X"1C5D22" & X"236537" & X"6DB8AB" & X"0FC685" & X"0727F8" & X"9BE240" & X"79A9D6" & X"673005" & X"90C1ED" & X"7AA50F" & X"3689E7" & X"AE8177" & X"CBA53D" & X"BE75E6" & X"FE71F8" & X"654E8F" & X"3E39F1" & X"897795" &
    X"4D7245" & X"6FFD53" & X"B33709" & X"4FDD1A" & X"E2778E" & X"EBCD4F" & X"69ADA9" & X"F1D011" & X"88FCD0" & X"3A3ECB" & X"FC1104" & X"4E0A56" & X"D720DF" & X"AA7B86" & X"AFE543" & X"B2A466" & X"92815C" & X"573A5C" & X"727D24" & X"C3A901" & X"047B81" & X"B7887A" & X"3D43A3" & X"4CC183" &
    X"F12E57" & X"4F1188" & X"3A2C50" & X"7AAF7E" & X"9CE3BF" & X"1B584F" & X"36AAAE" & X"0FEC10" & X"4747DF" & X"1B6C5B" & X"E6C748" & X"F20975" & X"CDE960" & X"968823" & X"70C1C9" & X"BD3959" & X"CEAC1A" & X"863122" & X"C9CAC9" & X"A49963" & X"D66F8D" & X"AE4072" & X"5D59A2" & X"60A980" &
    X"239DC5" & X"E16969" & X"838DF1" & X"717767" & X"6B0E10" & X"F5B6AA" & X"412732" & X"6005E3" & X"3CB713" & X"E36F3C" & X"D79CE9" & X"60624E" & X"59BAC3";
    constant OPERATIONS : std_logic_vector(SIZE - 1 downto 0)        := X"50" & X"68" & X"51" & X"03" & X"A9" & X"7D" & X"82" & X"73" & X"04" & X"02" & X"21" & X"37" & X"3F" & X"96" & X"E4" & X"15";
    constant RESULTS    : std_logic_vector((32 * SIZE) - 1 downto 0) := X"05F40600" & X"FC06FC00" & X"0000000C" & X"00000004" & X"00854154" & X"0007F3F4" & X"00051DF8" & X"00011E68" & X"0092B57E" & X"1139D278" & X"17798C4F" & X"0024442E" & X"01AB8B20" & X"01C624A0" & X"0106647E" & X"01901DCF" &
    X"0225B8A8" & X"4E59B911" & X"01A3DC80" & X"00B1D282" & X"035A8260" & X"004C16B6" & X"00E7D8C0" & X"00C1114E" & X"007EBA78" & X"00720D0B" & X"022F06F4" & X"002E86DB" & X"002BA070" & X"0000AFC8" & X"3E728D20" & X"2D71DD4B" & X"589B5DD2" & X"0006FDA6" & X"0750B961" & X"0000E220" & X"4564F4C4" &
    X"0100AFAE" & X"0008C08C" & X"084E59EF" & X"03B6303E" & X"00005807" & X"024D9A77" & X"05D7C917" & X"0AB3C3D2" & X"00E1BD67" & X"00FE923C" & X"6744BBA1" & X"187F8924" & X"000960FE" & X"000F1E78" & X"00E0FF8B" & X"000CED0F" & X"0000969A" & X"05DE58BA" & X"00F4094A" & X"002A83EF" & X"456CCBA1" &
    X"003384F1" & X"094690E1" & X"0157F863" & X"025C3030" & X"71D3C585" & X"EC82F4DD" & X"00475A93" & X"001523D1" & X"00C9D590" & X"00435CBD" & X"015B42F0" & X"0027A730" & X"00A45948" & X"0203421C" & X"03F81738" & X"00C344CC" & X"043928E5" & X"01EA58C0" & X"001467A0" & X"00538DC0" & X"02AE9B90" &
    X"0077FAED" & X"01386FA4" & X"02A43860" & X"13A65404" & X"00F8119A" & X"0026A6AA" & X"00978042" & X"023F4820" & X"00044B31" & X"019115C6" & X"00181FC8" & X"05E90D29" & X"1A340897" & X"00094C44" & X"01488C04" & X"0E161925" & X"34EB9191" & X"00085A89" & X"003ECD30" & X"0001BAAE" & X"0EF13630" &
    X"005C4B37" & X"1059157D" & X"2FC8B6D9" & X"171699AB" & X"01A4DB70" & X"00FAACA9" & X"00A6128C" & X"01B62EBC" & X"004868B8" & X"614AA597" & X"0FB6B249" & X"01AE9A5B" & X"1773E56C" & X"0D87A14F" & X"09007051" & X"001CD5D0" & X"01BD5F3C" & X"3B692B98" & X"008D6BE8" & X"000CAED2" & X"03C0F528" &
    X"000E5B8C" & X"00053B6F" & X"001457D9" & X"01E0328E" & X"9594725F" & X"0053A99C" & X"11F46ACF";

    -- state machines
    type state_type is (IDLE, COUNT, FINISHED);
    signal state_compute : state_type;
    signal state_verify  : state_type;

    -- clk for the arithmetic unit
    signal pipeline_clk : std_logic;
    signal inputs       : unsigned(23 downto 0);
    signal start        : std_logic;
    signal sel          : std_logic;
    signal done         : std_logic;

    -- buffers in and out for the inputs and outputs of the arithmetic unit
    type array_in is array (15 downto 0) of std_logic_vector(23 downto 0);
    type array_out is array (15 downto 0) of std_logic_vector(15 downto 0);

    signal start_in   : std_logic_vector(SIZE - 1 downto 0);
    signal FIFO_in    : std_logic_vector((24 * SIZE) - 1 downto 0);
    signal FIFO_in_op : std_logic_vector(SIZE - 1 downto 0);
    signal FIFO_out   : std_logic_vector((32 * SIZE) - 1 downto 0);
    signal FIFO_comp  : std_logic_vector((32 * SIZE) - 1 downto 0);

    -- accumulator for the comparison
    signal accum_comp : std_logic;

    signal arith_result : unsigned(31 downto 0);

    component PLL IS
        port(
            inclk0 : in  std_logic := '0';
            c0     : out std_logic
        );
    end component;

begin
    -------------------------
    -- The arithmetic unit --
    -------------------------
   -- ArithmeticUnit : entity work.arith_unit(combinatorial) port map(
     ArithmeticUnit : entity work.arith_unit(one_stage_pipeline) port map(
    -- ArithmeticUnit : entity work.arith_unit(two_stage_pipeline_1) port map(
    -- ArithmeticUnit : entity work.arith_unit(two_stage_pipeline_2) port map(
            clk     => pipeline_clk,
            reset_n => reset_n,
            start   => start,
            sel     => sel,
            a       => inputs(23 downto 16),
            b       => inputs(15 downto 8),
            c       => inputs(7 downto 0),
            d       => arith_result,
            done    => done
        );

    -- Extra clocks
    PLLUnit : PLL port map(
            inclk0 => clk,
            c0     => pipeline_clk
        );

    -- FSM compute
    FSM_compute : process(pipeline_clk, reset_n)
        variable sync_button0 : std_logic;
        variable sync_done    : std_logic;
        variable sync_result  : std_logic_vector(31 downto 0);
    begin
        if (reset_n = '0') then
            start         <= '0';
            sel           <= '0';
            state_compute <= IDLE;
            start_in      <= (others => '1');
            inputs        <= (others => '0');
            FIFO_out      <= (others => '0');
            sync_done     := '0';
            sync_button0  := '1';
            sync_result   := (others => '0');
            FIFO_in       <= OPERANDS;
            FIFO_in_op    <= OPERATIONS;
        elsif (rising_edge(pipeline_clk)) then
            inputs <= unsigned(FIFO_in(23 downto 0));
            sel    <= FIFO_in_op(0);
            -- FIFO_out
            if (sync_done = '1') then
                FIFO_out <= sync_result & FIFO_out(32 * SIZE - 1 downto 32);
            end if;

            -- FSM
            case state_compute is
                when IDLE =>
                    if (sync_button0 = '0') then
                        state_compute <= COUNT;
                    end if;

                when COUNT =>
                    start      <= start_in(0);
                    start_in   <= '0' & start_in(SIZE - 1 downto 1);
                    FIFO_in    <= (23 downto 0 => '0') & FIFO_in(24 * SIZE - 1 downto 24);
                    FIFO_in_op <= '0' & FIFO_in_op(SIZE - 1 downto 1);
                    if (start_in(0) = '0' and sync_done = '0') then
                        state_compute <= FINISHED;
                    end if;

                when FINISHED =>
                when others   =>
            end case;

            -- sync signals
            sync_done    := done;
            sync_button0 := Button0;
            sync_result  := std_logic_vector(arith_result);
        end if;
    end process;

    -- FSM verify
    FSM_verify : process(clk, reset_n)
        variable sync_state0, sync_state1 : state_type;
        variable sync_button1             : std_logic;
        variable done_out                 : std_logic_vector(SIZE - 1 downto 0);
    begin
        if (reset_n = '0') then
            state_verify <= IDLE;
            sync_button1 := '1';
            done_out     := (others => '1');
            FIFO_comp    <= RESULTS;
        elsif (rising_edge(clk)) then
            case state_verify is
                when IDLE =>
                    if (sync_state1 = FINISHED and sync_button1 = '0') then
                        state_verify <= COUNT;
                    end if;

                when COUNT =>
                    FIFO_comp <= (31 downto 0 => '0') & FIFO_comp(32 * SIZE - 1 downto 32);
                    done_out  := '0' & done_out(SIZE - 1 downto 1);
                    if (done_out(0) = '0') then
                        state_verify <= FINISHED;
                    end if;

                when FINISHED =>
                when others   =>
            end case;

            -- sync signals
            sync_state1  := sync_state0;
            sync_state0  := state_compute;
            sync_button1 := Button1;
        end if;
    end process;

    -- comparison
    process(clk, reset_n)
        variable sync_fifo : std_logic_vector(32 * SIZE - 1 downto 0);
    begin
        if (reset_n = '0') then
            accum_comp <= '1';
            sync_fifo  := (others => '0');
        elsif (rising_edge(clk)) then
            if (state_verify = IDLE) then
                sync_fifo := FIFO_out;
            else
                if (sync_fifo(15 downto 0) /= FIFO_comp(15 downto 0)) then
                    accum_comp <= '0';
                end if;
                sync_fifo := (31 downto 0 => '0') & sync_fifo(32 * SIZE - 1 downto 32);
            end if;
        end if;
    end process;

    process(state_verify, state_compute, accum_comp)
    begin
        if (state_verify = FINISHED) then
            if (accum_comp = '0') then
                LEDs <= X"000000422418182442000000"; -- Cross
            else
                LEDs <= X"000204081020402010000000"; -- Check
            end if;
        elsif (state_compute = FINISHED) then
            LEDs <= X"0000006C107C003844380000"; -- OK
        elsif (state_compute = IDLE) then
            LEDs <= X"0C700C0038447C0068147C00"; -- RDY
        else
            LEDs <= (others => '0');
        end if;
    end process;
end synth;
