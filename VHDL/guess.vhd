library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity guess is
	port 
	(
		reset       : in std_logic;
		clk         : in std_logic;  -- 48Mhz
		num         : in  std_logic_vector (31 downto 0);
		y0          : out std_logic_vector (31 downto 0)
	);
end guess;

architecture guess_arch of guess is
------------------------------------------------------------------------------------
--Component Declaration

--Counts the leading zeros on an incoming number
component lzc is
    port (
        clk         : in  std_logic;
        lzc_vector  : in  std_logic_vector (31 downto 0);
        lzc_count   : out std_logic_vector ( 4 downto 0)
    );
end component;

-- Lookup table for xB^(-3/2)
component xB_LUT IS
	port
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		wraddress	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

------------------------------------------------------------------------------------
--Signal Declaration
    signal z     : std_logic_vector (4 downto 0);  --Number of leading zeros in x
	signal w     : Integer;  --bit width
	signal f     : Integer;  --decimal point
	signal x     : unsigned(31 downto 0); --Number that is being operated on
	
	signal beta  : Integer;
	signal alpha : Integer;
	
	signal xalpha: unsigned(31 downto 0);
	signal xbeta : unsigned(31 downto 0);
	
	signal xalpha_calc: unsigned (31 downto 0);   -- Variable used for the bit shift
	signal xbeta_calc : unsigned (31 downto 0);	-- Variable used for the bit shift
	
	signal xB_LUT_addr : STD_LOGIC_VECTOR (13 DOWNTO 0);  -- Address for for xB^(-3/2)
	signal xB_LUT_ans  : STD_LOGIC_VECTOR (15 DOWNTO 0);  -- Answer for xB^(-3/2)
	signal ynot_even	 : unsigned(63 downto 0);
	signal ynot_odd	 : unsigned(127 downto 0);
	signal ynot			 : unsigned(31 downto 0);
	
	constant invrt2	: unsigned := x"00000000B5040000";
	

begin
	w <= 32; --32
	f <= 16; --16
	x <= unsigned(num);
------------------------------------------------------------------------------------
--Component Instantiation

    
    lzc_comp : lzc 
	 PORT MAP
	 (
		clk => clk,
		lzc_vector => num,
		lzc_count => z
	 );
	 
	
    xB_LUT_comp : xB_LUT 
	port map
	(
		clock		=> clk,
		data		=> x"1111",
		rdaddress	=> xB_LUT_addr,
		wraddress	=> "00000000000000",
		wren		=> '0',
		q	 =>	xB_LUT_ans
	);

------------------------------------------------------------------------------------
--Processes
    beta <= w - f - TO_INTEGER(unsigned(z)) - 1;
    xB_LUT_addr <= STD_LOGIC_VECTOR(xBeta_calc(15 downto 2));
	xBeta <= x"0000"&unsigned(xB_LUT_ans);
	xAlpha <= xAlpha_calc;
	
  	alpha_proc : process(clk, reset) --Computes Alpha
	begin
		if reset = '1' then
			
		elsif clk'event and clk = '1' then
			if (beta mod 2) = 0 then --If beta even
				alpha <= -2*beta + (beta/2);
			elsif (beta mod 2) = 1 then --If beta odd
				alpha <= -2*beta + (beta/2) + 1;
			end if;
		end if;
	end process;
	
	xalpha_proc : process(clk, reset) --Computes Xalpha by shifting the bits left or right
	begin
	   if reset = '1' then
			
		elsif clk'event and clk = '1' then 
			
			if alpha < 0 then				-- If negative shift right by alpha
					xalpha_calc <= shift_right(x, abs(alpha));
			elsif alpha > 0 then			-- If positive, shift left by alpha
					xalpha_calc <=shift_left(x, abs(alpha));
			elsif alpha = 0 then
					xalpha_calc <= x;
			end if;
		end if;
	end process;
	
	xbeta_proc : process(clk, reset) --Computes Xbeta by shifting the bits left or right
	begin
	   if reset = '1' then
			
		elsif clk'event and clk = '1' then 
			if beta < 0 then			-- If negative shift left by beta				
					xbeta_calc <= shift_left(x, abs(beta));
			elsif beta > 0 then		-- If positive, shift right by beta
					xbeta_calc <= shift_right(x, abs(beta));
			elsif beta = 0 then
					xbeta_calc <= x;
			end if;
		end if;
	end process;
	
	ynot_proc : process(clk, reset)
	begin
		if reset = '1' then
			
		elsif clk'event and clk = '1' then 	--If beta even
			if (beta mod 2) = 0 then 
				ynot_even <= xalpha*xbeta;
				ynot <= ynot_even(47 downto 16);
			elsif (beta mod 2) = 1 then --If beta odd
				ynot_odd <= xalpha*xbeta*invrt2;
				ynot <= ynot_odd(79 downto 48);
			end if;
		end if;
	end process;
	
	y0 <= std_logic_vector(ynot);
  
end guess_arch;