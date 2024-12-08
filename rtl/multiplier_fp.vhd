library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_fp is 
    generic (
        NE: natural := 8;
        NF: natural := 23
    );
    port (
        rst: in std_logic;
        clk: in std_logic;
        x:   in std_logic_vector(NF+NE downto 0);
        y:   in std_logic_vector(NF+NE downto 0);
        z:   out std_logic_vector(NF+NE downto 0)
    );
end multiplier_fp;

architecture behavioral of multiplier_fp is
    constant EXC:       unsigned(NE+1 downto 0) := to_unsigned(2**(NE-1)-1, NE+2);
    constant ZERO_E:    std_logic_vector(NE-1 downto 0) := (others => '0');
    constant ZERO_F:    std_logic_vector(NF-1 downto 0) := (others => '0');
    signal x_reg :      std_logic_vector(NF+NE downto 0);
    signal y_reg :      std_logic_vector(NF+NE downto 0);
    signal sx :         std_logic;
    signal fx :         std_logic_vector(NF-1 downto 0);
    signal ex :         std_logic_vector(NE-1 downto 0);
    signal sy :         std_logic;
    signal fy :         std_logic_vector(NF-1 downto 0);
    signal ey :         std_logic_vector(NE-1 downto 0);
    signal mx :         unsigned(NF downto 0);
    signal my :         unsigned(NF downto 0);
    signal mz_prev :    unsigned(2*NF+1 downto 0);
    signal sz :         std_logic;
    signal sx_ex:       signed(NE+1 downto 0);
    signal sx_ey:       signed(NE+1 downto 0);
    signal ez_prev :    signed(NE+1 downto 0);
    signal ez_prev_3 :  std_logic_vector(NE-1 downto 0);
    signal ez_p2 :      signed(NE+1 downto 0);
    signal fz :         std_logic_vector(NF-1 downto 0);
    signal fz_p2 :      std_logic_vector(NF-1 downto 0);
    signal fz_prev_3 :  std_logic_vector(NF-1 downto 0);
    signal ez :         std_logic_vector(NE-1 downto 0);

begin

    process(clk, rst)
    begin
        if rst = '1' then
            x_reg <= (others => '0');
            y_reg <= (others => '0');
        elsif rising_edge(clk) then
            x_reg <= x;
            y_reg <= y;
        end if;
    end process;
    
    sx <= x_reg(NF+NE);
    fx <= x_reg(NF-1 downto 0);
    ex <= x_reg(NF+NE-1 downto NF);
    
    sy <= y_reg(NF+NE);
    fy <= y_reg(NF-1 downto 0);
    ey <= y_reg(NF+NE-1 downto NF);

    mx <= unsigned('1' & fx);
    my <= unsigned('1' & fy);
    
    sz <= sx xor sy;
    
    mz_prev <= mx * my ;

    sx_ex <= signed('0' & '0' & ex);
    sx_ey <= signed('0' & '0' & ey);
    
    ez_prev <= sx_ex + sx_ey - signed(EXC);
    ez_p2 <= ez_prev + 1 when mz_prev(2*NF+1) = '1' else
                ez_prev;
    ez_prev_3 <= (others => '0') when ez_p2(NE+1) = '1' else
                (others => '1') when ez_p2(NE) = '1' else
                std_logic_vector(ez_p2(NE-1 downto 0));            
    ez <= (others => '0') when (ex = ZERO_E and fx = ZERO_F) or (ey = ZERO_E and fy = ZERO_F) else
        ez_prev_3;
        
    fz_p2 <= std_logic_vector(mz_prev(2*NF downto NF+1))when mz_prev(2*NF+1) = '1' else
                std_logic_vector(mz_prev(2*NF-1 downto NF));
    fz_prev_3 <= (others => '0') when ez_p2(NE+1) = '1' else
                (others => '1') when ez_p2(NE) = '1' else
                fz_p2(NF-1 downto 0);            
    fz <= (others => '0') when (ex = ZERO_E and fx = ZERO_F) or (ey = ZERO_E and fy = ZERO_F) else
        fz_prev_3;

    process(clk, rst)
    begin
        if rst = '1' then
            z <= (others => '0');
        elsif rising_edge(clk) then
            z <= sz & ez & fz;
        end if;
    end process;

end architecture behavioral;