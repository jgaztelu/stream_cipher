library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_tb is
end entity;

architecture testbench of stream_cipher_tb is

  component stream_cipher_top
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    start_attack  : in  std_logic;
    new_key       : in  std_logic;
    key_in        : in  std_logic;
    mask_in       : in  std_logic;
    WEB           : in  std_logic;
    reg_full      : out std_logic;
    grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
    espresso_out  : out std_logic
  );
  end component stream_cipher_top;


signal clk,rst,start_attack,new_key,key_in,mask_in,WEB,reg_full : std_logic;
signal grain128a_out : std_logic_vector (GRAIN_STEP-1 downto 0);
signal espresso_out : std_logic;

signal key	:	std_logic_vector (127 downto 0) := (others => '0');
signal IV	:	std_logic_vector (95 downto 0) := (others => '0');
signal key_mask : std_logic_vector (127 downto 0);
signal IV_mask  : std_logic_vector (95 downto 0);
signal save_grain : std_logic_vector (319 downto 0);
shared variable i :  integer range 0 to 1024;

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
	key_in <= '0';
  mask_in <= '0';
  start_attack <= '0';
  key_mask <= (23 => '1', others => '0');
  IV_mask <= (47 => '1',53 => '1', 58 => '1', 64 => '1', others => '0');
	wait until rst = '0';

	for I in 0 to 95 loop
		WEB <= '1';
		key_in <= IV(I);
    mask_in <= IV_mask (I);
		wait for clk_period;
	end loop;

	for I in 0 to 127 loop
		WEB <= '1';
		key_in <= key(I);
    mask_in <= key_mask (I);
		wait for clk_period;
	end loop;

	WEB <='0';
	start_attack <= '1';
	wait for clk_period;
	start_attack <= '0';
	wait;
end process;

savegrainproc: process
begin
	wait until new_key = '0';
	save_grain <= (others => '0');
	wait until new_key = '1';
	wait until new_key = '0';

	wait for 3*clk_period;
	while (i<(256/GRAIN_STEP)-1) loop	-- Wait initialisation rounds
	  i := i+1;
	  wait for clk_period;
	end loop;
	i:=0;
	wait for 66*clk_period;
	while (i<=(320/GRAIN_STEP)-1) loop
	  save_grain <= save_grain ((319-GRAIN_STEP) downto 0) & grain128a_out;
	  i := i+1;
	  wait for 2*clk_period;    -- Key-stream with auth
	end loop;
	wait;
end process;

uut : stream_cipher_top
port map (
  clk           => clk,
  rst           => rst,
  start_attack  => start_attack,
  new_key       => new_key,
  key_in        => key_in,
  mask_in       => mask_in,
  WEB           => WEB,
  reg_full      => reg_full,
  grain128a_out => grain128a_out,
  espresso_out  => espresso_out
);


end architecture;
