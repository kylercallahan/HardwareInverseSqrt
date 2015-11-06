library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity rsqrt is
	port 
	(
		--reset               : in std_logic;
		clk                 : in std_logic;  -- 48Mhz
		rsqrt_input         : in  std_logic_vector (31 downto 0);
		rsqrt_output        : out std_logic_vector (31 downto 0)
	);
end rsqrt;

architecture rsqrt_arch of rsqrt is
------------------------------------------------------------------------------------
--Component Declaration

component iterate is
	port 
	(
		reset               : in  std_logic;
		clk                 : in  std_logic;  -- 48Mhz
		num                 : in  std_logic_vector (31 downto 0);
		ans					  : out std_logic_vector (31 downto 0)
	);
end component;

------------------------------------------------------------------------------------
--Signal Declaration

begin
------------------------------------------------------------------------------------
--Component Instantiation

    iterate_comp :   iterate
	 PORT MAP
	 (
		reset       => '0',
		clk         => clk,
		num         => rsqrt_input,
		ans			=> rsqrt_output
	 );


------------------------------------------------------------------------------------
--Processes

end rsqrt_arch;