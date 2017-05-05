library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain_auth is
  port (
    clk        : in std_logic;
    rst        : in std_logic;
    auth       : in std_logic;
    pre_64     : in std_logic;
    pre_out_in : in std_logic;
    keystream  : out std_logic
  );
end entity;

architecture arch of grain_auth is
signal even_bit      : std_logic;
signal even_bit_next : std_logic;
signal z             : std_logic;
signal z_next        : std_logic;
begin

process(clk,rst)
begin
  if rst = '1' then
    even_bit <= '0';
    z <= '0';
  elsif clk'event and clk='1' then
    even_bit <= even_bit_next;
    z <= z_next;
  end if;
end process;

process(auth,pre_64,pre_out_in,z,even_bit)
begin
  even_bit_next <= not (even_bit);
  if auth = '0' then
    z_next <= pre_out_in;
  elsif pre_64 = '1' then
    if even_bit = '1' then
      z_next <= pre_out_in;
    else
      z_next <= z;
    end if;
  else
    z_next <= '0';
  end if;
keystream <= z;
end process;
end architecture;
