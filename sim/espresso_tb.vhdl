library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

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
    keystream : out std_logic
  );
  end component espresso_top;

signal clk       : std_logic;
signal rst       : std_logic;
signal new_key   : std_logic;
signal key       : std_logic_vector (127 downto 0);
signal IV        : std_logic_vector (95 downto 0);
signal keystream : std_logic;

signal save_stream  : std_logic_vector (255 downto 0);
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
    wait for 2*clk_period;
    rst <= '0';
    new_key <= '1';
    key <= x"000102030405060708090A0B0C0D0E0F";
    IV <= x"000102030405060708090A0B";
    --IV (95 downto 4) <= (others => '0');
    --IV (3 downto 0) <= "0001";
    wait for clk_period;
    new_key <= '0';
    wait;
  end process;

  save_stream_proc : process

  begin
    keystream_OK <='0';
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
  wait for 64*clk_period;
  while (i<=255) loop
    save_stream <= save_stream (254 downto 0) & stream;
    i := i+1;
    wait for clk_period;
  end loop;
  wait;
  end process;



  uut : espresso_top
  port map (
    clk       => clk,
    rst       => rst,
    new_key   => new_key,
    key       => key,
    IV        => IV,
    keystream => keystream
  );

end architecture;
