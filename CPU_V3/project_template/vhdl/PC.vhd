library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is
    constant inc : unsigned(15 downto 0) := X"0004";
    signal s_eimmInc: unsigned(15 downto 0);
    signal s_nextAddr, s_currentAddr, s_mux00, s_mux01, s_mux10: std_logic_vector(15 downto 0);
begin
    s_eimmInc <= unsigned(e_imm) + inc;
    s_mux00 <= std_logic_vector(unsigned(s_currentAddr) + inc) when branch = '0' 
              else std_logic_vector(unsigned(pc_addr) + s_eimmInc);
    s_mux01 <= std_logic_vector(unsigned(a) + inc);
    s_mux10 <= d_imm(13 downto 0) & "00";

    s_nextAddr <= s_mux00 when sel_imm = '0' and sel_a = '0' else 
                  s_mux01 when sel_imm = '0' and sel_a = '1' else 
                  s_mux10 when sel_imm = '1' and sel_a = '0' else (others => 'Z'); 



    dfpfp : process(clk, reset_n) 
    begin
        if (reset_n = '0') then 
            s_currentAddr <= (others => '0');
        elsif(rising_edge(clk)) then
            s_currentAddr <= s_nextAddr;
        end if ;
    end process ; -- D-flipflop

    addr <= s_nextAddr;
    next_addr <= s_currentAddr;

end synth;
