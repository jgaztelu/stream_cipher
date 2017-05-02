library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a_tb is
end entity;

architecture arch of grain128a_tb is
  component grain128a_top
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    new_key : in  std_logic;
    key     : in  std_logic_vector (127 downto 0);
    IV      : in  std_logic_vector (95 downto 0);
    stream  : out std_logic
  );
  end component grain128a_top;

constant clk_period : time := 10 ns;

--DUT signals
signal clk     : std_logic;
signal rst     : std_logic;
signal new_key : std_logic;
signal key     : std_logic_vector (127 downto 0);
signal IV      : std_logic_vector (95 downto 0);
signal stream  : std_logic;
signal save_stream  : std_logic_vector (255 downto 0);

shared variable i :  integer range 0 to 256;


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
  key <= x"0123456789abcdef123456789abcdef0";
  IV <= x"0123456789abcdef12345678";
  wait for clk_period;
  new_key <= '0';
  wait;
end process;

save_stream_proc : process
begin
  i:=0;
  save_stream <= (others => '0');
wait for 4*clk_period;
while (i<=255) loop
  save_stream <= save_stream (254 downto 0) & stream;
  i := i+1;
  wait for clk_period;
end loop;
wait;
end process;

uut : grain128a_top
port map (
  clk     => clk,
  rst     => rst,
  new_key => new_key,
  key     => key,
  IV      => IV,
  stream  => stream
);

end architecture;
