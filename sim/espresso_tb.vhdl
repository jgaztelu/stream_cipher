library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;
  use std.textio.all;

entity espresso_tb is
end entity;

architecture arch of espresso_tb is

  component espresso_top
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    new_key   : in  std_logic;
    key       : in  std_logic_vector (127 downto 0);
    IV        : in  std_logic_vector (95 downto 0);
    keystream : out std_logic;
    current_state : out std_logic_vector (255 downto 0)
  );
  end component espresso_top;

constant clk_period : time := 10 ns;

signal clk       : std_logic;
signal rst       : std_logic;
signal new_key   : std_logic;
signal key       : std_logic_vector (127 downto 0);
signal IV        : std_logic_vector (95 downto 0);
signal keystream : std_logic;

signal save_stream  : std_logic_vector (159 downto 0);
signal espresso_state : std_logic_vector (255 downto 0);
signal current_state  : std_logic_vector (255 downto 0);
signal espresso_error : std_logic;

shared variable i :  integer range 0 to 1024;
signal row_counter : integer:=0;
shared variable row         : line;
shared variable row_data    : std_logic_vector(255 downto 0);

file input_data : text open read_mode is "/h/d7/w/ja8602ga-s/Crypto/espresso_state.txt";
begin

  clock_gen : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  stim_process : process
  begin
    rst <= '1'; 
    new_key <= '1';
    key <= (others => '0');
    IV <= (others => '0');
    --key <= x"000102030405060708090A0B0C0D0E0F";
    --IV <= x"000102030405060708090A0B";
    wait for 2*clk_period;
    rst <= '0';
    --new_key <= '1';
    --IV (95 downto 4) <= (others => '0');
    --IV (3 downto 0) <= "0001";
    wait for clk_period;
    new_key <= '0';
    wait;
  end process;

save_stream_proc : process
  begin
    i:=0;
    save_stream <= (others => '0');
  while rst = '1' loop
  end loop;
  wait for 5*clk_period;
  while (i<255) loop
    i := i+1;
    wait for clk_period;
  end loop;
  i := 0;
  wait for clk_period;
  while (i<=255) loop
    save_stream <= save_stream (158 downto 0) & keystream;
    i := i+1;
    wait for clk_period;
  end loop;
  wait;
  end process;

file_process: process
begin
    row_counter <= 0;
    wait for 4*clk_period;
    while not endfile(input_data) and row_counter < 256 loop
        readline(input_data,row);
        read (row,row_data);
	current_state <= row_data;
	row_counter <= row_counter + 1;
	wait for clk_period;
    end loop;
    wait;
end process;

check_process: process
begin
 if current_state = espresso_state then
    espresso_error <= '0';
 else
    espresso_error <= '1';
 end if;
 wait for clk_period;
end process;

  uut : espresso_top
  port map (
    clk       => clk,
    rst       => rst,
    new_key   => new_key,
    key       => key,
    IV        => IV,
    keystream => keystream,
    current_state => current_state
  );

end architecture;
