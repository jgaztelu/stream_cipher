library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_tb is
end entity;

architecture testbench of stream_cipher_tb is

component stream_cipher_top_p is
  port (
  clk : in std_logic;
  rst : in std_logic;
  new_key : in std_logic;
  data_in : in std_logic;
  WEB	  : in std_logic;
  reg_full : out std_logic;
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  espresso_out : out std_logic
   );
end component;

signal clk,rst,new_key,data_in,WEB,reg_full : std_logic;
signal grain128a_out : std_logic_vector (GRAIN_STEP-1 downto 0);
signal espresso_out : std_logic;

signal key	:	std_logic_vector (127 downto 0) := (others => '0');
signal IV	:	std_logic_vector (95 downto 0) := x"800000000000000000000000";

constant clk_period : time := 5 ns;

begin

clkproc: process
begin
	clk <= '1';
	wait for clk_period/2;
	clk <= '0';
	wait for clk_period/2;
end process;

stimproc: process
begin
	rst <= '1';
	wait for clk_period;
	rst <= '0';
	wait;
end process;

datainproc: process
begin
	WEB <= '0';
	new_key <= '0';
	data_in <= '0';
	wait until rst = '0';
	for I in 0 to 127 loop
		WEB <= '1';
		data_in <= key(I);
		wait for clk_period;
	end loop;
	for I in 0 to 95 loop
		WEB <= '1';
		data_in <= IV(I);
		wait for clk_period;
	end loop;
	WEB <='0';
	new_key <= '1';
	wait for clk_period;
	new_key <= '0';
	wait;
end process;

uut: stream_cipher_top_p
	port map (
		clk => clk,
		rst => rst,
		new_key => new_key,
		data_in => data_in,
		WEB => WEB,
		reg_full => reg_full,
		grain128a_out => grain128a_out,
		espresso_out => espresso_out
		);

end architecture;
	
	
