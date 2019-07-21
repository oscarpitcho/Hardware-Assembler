library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        imm_signed : out std_logic;
        sel_b      : out std_logic;
        op_alu     : out std_logic_vector(5 downto 0);
        read       : out std_logic;
        write      : out std_logic;
        sel_pc     : out std_logic;
        branch_op  : out std_logic;
        sel_mem    : out std_logic;
        rf_wren    : out std_logic;
        pc_sel_imm : out std_logic;
        pc_sel_a   : out std_logic;
        sel_ra     : out std_logic;
        rf_retaddr : out std_logic_vector(4 downto 0);
        sel_rC     : out std_logic
    );
end controller;

architecture synth of controller is
    type state is (fetch1, fetch2, decode, break, store, r_op, load1, i_op, load2, branch, call, jump, ui_op, ri_op);
signal s_nextState : state := fetch1;
signal s_op, s_opx : std_logic_vector(7 downto 0);
constant r_type : std_logic_vector(7 downto 0):= "00111010";
begin
	--Converting opcodes to 8 bits
	s_op <= "00" & op;
	s_opx <= "00" & opx;
	
	-- Controller logic
	rf_retaddr <= "11111";
	read <= '1' when s_op = X"17" else '0';
	rf_wren <= '1' when (s_op = r_type and (s_opx = X"12" or s_opx = X"1A" or s_opx = X"3A" or s_opx = X"02")) or (s_op = X"04" or s_op = X"08" or s_op = X"10" or s_op = X"18" or s_op = X"20")or (s_op = r_type or s_op = X"17") or (s_op = X"00" or (s_op = r_type and s_opx = X"1D")) or (s_op = X"0C" or s_op = X"14" or s_op = X"1C" or s_op = X"28" or s_op = X"30") else '0';
	imm_signed <= '1' when (s_op = X"04" or s_op = X"08" or s_op = X"10" or s_op = X"18" or s_op = X"20")or s_op = X"15" or s_op = X"17"  else '0'; --op(2)
	sel_b <= '1' when s_op = r_type or s_op = X"06" or s_op = X"0E" or s_op = X"16" or s_op = X"16" or s_op = X"1E" or s_op = X"26" or s_op = X"2E" or s_op = X"36" else '0';
	sel_rC <= '1' when (s_op = r_type) or (s_op = r_type and (s_opx = X"12" or s_opx = X"1A" or s_opx = X"3A" or s_opx = X"02")) or ((s_op = X"00" or (s_op = r_type and s_opx = X"1D")) and s_op = r_type) else '0';
	sel_mem <= '1' when s_op = X"17"  else '0';
	write <= '1' when s_op = X"15" else '0';
	branch_op <= '1' when s_op = X"06" or s_op = X"0E" or s_op = X"16" or s_op = X"16" or s_op = X"1E" or s_op = X"26" or s_op = X"2E" or s_op = X"36" else '0';
	pc_sel_imm <= '1' when ((s_op = X"00" or (s_op = r_type and s_opx = X"1D")) and s_op = X"00") or ((s_op = X"01" or (s_op = r_type and (s_opx = X"05" or s_opx = X"0D"))) and s_op = X"01")  else '0';
	sel_pc <= '1' when (s_op = X"00" or (s_op = r_type and s_opx = X"1D")) else '0';
	sel_ra <= '1' when (s_op = X"00" or (s_op = r_type and s_opx = X"1D")) else '0';
	pc_sel_a <= '1' when ((s_op = X"00" or (s_op = r_type and s_opx = X"1D")) and s_op = X"3A") or ((s_op = X"01" or (s_op = r_type and (s_opx = X"05" or s_opx = X"0D"))) and s_op = r_type) else '0';
	
	-- op to op_alu

    op_alu(2 downto 0) <= s_opx(5 downto 3) when s_op = r_type else "100" when s_op =X"06" else s_op(5 downto 3);
	op_alu(5 downto 3) <=  "100" when (s_op = r_type and (s_opx = X"0E" or s_opx =  X"06" or s_opx =  X"16" or s_opx =  X"1E")) or (s_op = X"0C" or s_op =  X"14" or s_op =  X"1C")  else 
						   "110" when s_op = r_type and (s_opx = X"1B" or s_opx =  X"13" or s_opx =  X"3B" or s_opx = X"03" or s_opx =  X"0B"or s_opx = X"12"or s_opx =  X"1A" or s_opx = X"3A" or s_opx =  X"02") else
						   "000" when s_op = r_type and s_opx = X"31" else 
						   "001" when s_op = r_type and s_opx = X"39" else 
						   "011" when (s_op = r_type and (s_opx = X"08" or s_opx =  X"10" or s_opx =  X"18" or s_opx =  X"20" or s_opx =  X"28" or s_opx =  X"30" )) or (s_op = X"0E" or s_op =  X"16" or s_op =  X"1E" or s_op =  X"26"or s_op =  X"2E" or s_op =  X"36" or s_op =  X"10" or s_op =  X"08" or s_op =  X"18" or s_op =  X"20"or s_op = X"28"or s_op = X"30" or s_op =  X"06")  else 
						   "000";	

end synth;
