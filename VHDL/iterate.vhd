library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity iterate is
	port 
	(
		reset               : in  std_logic;
		clk                 : in  std_logic;  -- 48Mhz
		num                 : in  std_logic_vector (31 downto 0);
		ans					: out std_logic_vector (31 downto 0)
	);
end iterate;

architecture iterate_arch of iterate is
------------------------------------------------------------------------------------
--Component Declaration
component guess is
	port 
	(
		reset               : in std_logic;
		clk                 : in std_logic;  -- 48Mhz
		num                 : in  std_logic_vector (31 downto 0);
		y0                  : out std_logic_vector (31 downto 0)
	);
end component;

------------------------------------------------------------------------------------
--Signal Declaration

	signal y0      : std_logic_vector (31 downto 0);
	signal y0_calc : unsigned(31 downto 0);
	
	signal yn1     : unsigned(31 downto 0);--std_logic_vector (31 downto 0);
	signal yn2     : unsigned(31 downto 0);--std_logic_vector (31 downto 0);
	signal x       : unsigned(31 downto 0);

	signal ysqr    : unsigned(63 downto 0);
	signal xysqr   : unsigned(127 downto 0);
	signal xy      : unsigned(31 downto 0);
	signal dif     : unsigned(31 downto 0);
	
	signal count   : integer := 0;
	signal ins_count : integer := -0;
	
	constant pad : unsigned := x"0000";

begin
	x <= unsigned(num);
	
------------------------------------------------------------------------------------
--Component Instantiation

    initial_guess : guess --Gets y0
	 PORT MAP
	 (
		reset => reset,
		clk   => clk,
		num   => num,
		y0    => y0
	 );

------------------------------------------------------------------------------------
--Processes

	y0_calc <= unsigned(y0); --Convert to integer for easy math.

  	iterate_proc : process(clk, reset) --does one iteration per clk
	begin
		if reset = '1' then
			count <= 0;
		elsif clk'event and clk = '1' then
			if count < 7 then
				count <= count +1; 
			elsif count = 7 then --use y0 
--				--yn1 <= (y0_calc*(3-(x*(y0_calc*y0_calc))))/2; --Newtons method math
				if ins_count = 0 then
					ysqr <= y0_calc * y0_calc;
					ins_count <= ins_count+1;
				elsif ins_count = 1 then
					xysqr <= ysqr * (pad & x & pad);
					ins_count <= ins_count+1;
				elsif ins_count = 2 then
					xy <= xysqr(79 downto 48);
					ins_count <= ins_count+1;
				elsif ins_count = 3 then
					dif <= x"00030000" - xy;
					ins_count <= ins_count+1;
				elsif ins_count = 4 then
					ysqr <= dif * y0_calc;
					ins_count <= ins_count+1;
				elsif ins_count = 5 then
					yn1 <= ysqr(48 downto 17); --resize and right shift once.
					ins_count <= 0;
					count <= count +1;                            --icrement count
				end if;
			elsif count = 8 then --use yn                    
				--yn2 <= (yn1*(3-(x*(yn1*yn1))))/2;             --2nd iteration maps directly
				if ins_count = 0 then
					ysqr <= yn1 * yn1;
					ins_count <= ins_count+1;
				elsif ins_count = 1 then
					xysqr <= ysqr * (pad & x & pad);
					ins_count <= ins_count+1;
				elsif ins_count = 2 then
					xy <= xysqr(79 downto 48);
					ins_count <= ins_count+1;
				elsif ins_count = 3 then
					dif <= x"00030000" - xy;
					ins_count <= ins_count+1;
				elsif ins_count = 4 then
					ysqr <= dif * yn1;
					ins_count <= ins_count+1;
				elsif ins_count = 5 then
					yn2 <= ysqr(48 downto 17); --resize and right shift once.
					ins_count <= 0;
					count <= count +1;                            --icrement count
				end if;
			elsif ((count >= 9) and (count <= 10)) then       --3rd+ iteration(s) uses same signals and needs to move around values
				if ins_count = 0 then
					yn1 <= yn2;
					ysqr <= yn1 * yn1;
					ins_count <= ins_count+1;
				elsif ins_count = 1 then
					xysqr <= ysqr * (pad & x & pad);
					ins_count <= ins_count+1;
				elsif ins_count = 2 then
					xy <= xysqr(79 downto 48);
					ins_count <= ins_count+1;
				elsif ins_count = 3 then
					dif <= x"00030000" - xy;
					ins_count <= ins_count+1;
				elsif ins_count = 4 then
					ysqr <= dif * yn1;
					ins_count <= ins_count+1;
				elsif ins_count = 5 then
					yn2 <= ysqr(48 downto 17); --resize and right shift once.
					ins_count <= 0;
					count <= count +1;                            --icrement count
				end if;
			end if;
		end if;
	end process;

	ans <= std_logic_vector(yn2); --Convert back to std_logic_vector for output
end iterate_arch;