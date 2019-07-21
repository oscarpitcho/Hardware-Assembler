library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic := '0';
        -- immediate value sign extention
        imm_signed : out std_logic := '0';
        -- instruction register enable
        ir_en      : out std_logic := '0';
        -- PC control signals
        pc_add_imm : out std_logic := '0';
        pc_en      : out std_logic := '0';
        pc_sel_a   : out std_logic := '0';
        pc_sel_imm : out std_logic := '0';
        -- register file enable
        rf_wren    : out std_logic := '0';
        -- multiplexers selections
        sel_addr   : out std_logic := '0';
        sel_b      : out std_logic := '0';
        sel_mem    : out std_logic := '0';
        sel_pc     : out std_logic := '0';
        sel_ra     : out std_logic := '0';
        sel_rC     : out std_logic := '0';
        -- write memory output
        read       : out std_logic := '0';
        write      : out std_logic := '0';
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0) := "000000"
    );
end controller;

architecture synth of controller is 
type state is (fetch1, fetch2, decode, break, store, r_op, load1, i_op, load2, branch, call, jump, ui_op, ri_op);
signal s_currentState, s_nextState : state;
signal s_op, s_opx : std_logic_vector(7 downto 0);
constant r_type : std_logic_vector(7 downto 0):= "00111010";
begin
	--Converting opcodes to 8 bits
	s_op <= "00" & op;
	s_opx <= "00" & opx;
	-- flipflop to change states 
	nextStateSwitch : process (clk, reset_n) is 
	begin 
		if (reset_n = '0') then 
			s_currentState <= fetch1;
		elsif (rising_edge(clk)) then 
			s_currentState <= s_nextState;
		end if;
	end process nextStateSwitch;
	
	-- transition logic 
	s_nextState <= fetch2 when s_currentState = fetch1 else
				   decode when s_currentState = fetch2 else 
				   load2  when s_currentState = load1 else
				   load1  when s_currentState = decode and s_op = X"17" else
				   store  when s_currentState = decode and s_op = X"15" else 
				   break  when(s_currentState = decode and s_op = r_type and s_opx = X"34") or s_currentState = break else 
				   i_op   when s_currentState = decode and(s_op = X"04" or s_op = X"08" or s_op = X"10" or s_op = X"18" or s_op = X"20") else 
				   branch when s_currentState = decode and(s_op = X"06" or s_op = X"0E" or s_op = X"16" or s_op = X"16" or s_op = X"1E" or s_op = X"26" or s_op = X"2E" or s_op = X"36") else 
				   call   when s_currentState = decode and(s_op = X"00" or (s_op = r_type and s_opx = X"1D")) else 
				   jump   when s_currentState = decode and(s_op = X"01" or (s_op = r_type and (s_opx = X"05" or s_opx = X"0D"))) else
				   ui_op  when s_currentState = decode and(s_op = X"0C" or s_op = X"14" or s_op = X"1C" or s_op = X"28" or s_op = X"30") else 
				   ri_op  when s_currentState = decode and s_op = r_type and (s_opx = X"12" or s_opx = X"1A" or s_opx = X"3A" or s_opx = X"02") else 
				   r_op   when s_currentState = decode and s_op = r_type  else
				   fetch1;
	
	-- output logic
	
	read <= '1' when s_currentState = load1 or s_currentState = fetch1 else '0';
	pc_en <= '1' when s_currentState = fetch2 or s_currentState = call or s_currentState = jump else '0';
	ir_en <= '1' when s_currentState = fetch2 else '0';
	rf_wren <= '1' when s_currentState = ri_op or s_currentState = i_op or s_currentState = r_op or s_currentState = load2 or s_currentState = call or s_currentState = ui_op else '0';
	imm_signed <= '1' when s_currentState = i_op or s_currentState = store or s_currentState = load1 else '0'; --op(2)
	sel_b <= '1' when s_currentState = r_op or s_currentState = branch else '0';
	sel_rC <= '1' when s_currentState = r_op or s_currentState = ri_op or (s_currentState = call and s_op = r_type) else '0';
	sel_addr <= '1' when s_currentState = load1 or s_currentState = store else '0';
	sel_mem <= '1' when s_currentState = load2 else '0';
	write <= '1' when s_currentState = store else '0';
	pc_add_imm <= '1' when s_currentState = branch else '0';
	branch_op <= '1' when s_currentState = branch else '0';
	pc_sel_imm <= '1' when (s_currentState = call and s_op = X"00") or (s_currentState = jump and s_op = X"01")  else '0';
	sel_pc <= '1' when s_currentState = call else '0';
	sel_ra <= '1' when s_currentState = call else '0';
	pc_sel_a <= '1' when (s_currentState = call and s_op = X"3A") or (s_currentState = jump and s_op = r_type) else '0';
	
	-- op to op_alu

    op_alu(2 downto 0) <= s_opx(5 downto 3) when s_op = r_type else "100" when s_op =X"06" else s_op(5 downto 3);
	op_alu(5 downto 3) <=  "100" when (s_op = r_type and (s_opx = X"0E" or s_opx =  X"06" or s_opx =  X"16" or s_opx =  X"1E")) or (s_op = X"0C" or s_op =  X"14" or s_op =  X"1C")  else 
						   "110" when s_op = r_type and (s_opx = X"1B" or s_opx =  X"13" or s_opx =  X"3B" or s_opx = X"03" or s_opx =  X"0B"or s_opx = X"12"or s_opx =  X"1A" or s_opx = X"3A" or s_opx =  X"02") else
						   "000" when s_op = r_type and s_opx = X"31" else 
						   "001" when s_op = r_type and s_opx = X"39" else 
						   "011" when (s_op = r_type and (s_opx = X"08" or s_opx =  X"10" or s_opx =  X"18" or s_opx =  X"20" or s_opx =  X"28" or s_opx =  X"30" )) or (s_op = X"0E" or s_op =  X"16" or s_op =  X"1E" or s_op =  X"26"or s_op =  X"2E" or s_op =  X"36" or s_op =  X"10" or s_op =  X"08" or s_op =  X"18" or s_op =  X"20"or s_op = X"28"or s_op = X"30" or s_op =  X"06")  else 
						   "000";	

	
	
end synth;
