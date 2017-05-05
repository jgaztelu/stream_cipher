library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a_auth is
  port (
  clk : in std_logic;
  rst : in std_logic;
  pre_out_in  : in std_logic;
  auth  : in std_logic;
  init  : in std_logic;
  keystream : out std_logic
  );
end entity;

architecture behavioural of grain128a_auth is
signal pre_out_counter, pre_out_counter_next : unsigned (5 downto 0);
signal even_bit, even_bit_next  : std_logic;
signal z,z_next    : std_logic;
begin

synchronous : process(clk,rst)
begin
  if rst <= '1' then
    pre_out_counter <= (others => '0');
    even_bit <= '0';
  elsif clk'event and clk='1' then
    pre_out_counter <= pre_out_counter_next;
    even_bit <= even_bit_next;
  end if;
end process;

auth_proc : process(pre_out_counter,pre_out_in,auth)
begin
  if auth = '1' then
    if pre_out_counter < 63 then
      z_next <= '0';
    else
      even_bit_next <= even_bit xor '1';
      if even_bit = '1' then
        z_next <= pre_out_in;
      else
        z_next <= z;
      end if;
    end if;
  else
    z_next <= pre_out_in;
  end if;
end process;

counter_proc : process(pre_out_counter)
begin
  if pre_out_counter < 63 then
    pre_out_counter_next <= pre_out_counter + 1;
  else
    pre_out_counter_next <= pre_out_counter;
  end if;
end process;

output_proc : process(z,init)
begin
if init = '1' then
  keystream <= '0';
else
  keystream <= z;
end if;
end process;
end architecture;
