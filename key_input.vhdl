library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity input_register is
  port (
  clk          : in std_logic;
  rst          : in std_logic;
  WEB          : in std_logic; -- Write enable
  data_in      : in std_logic;
  new_key	: in std_logic;
  reg_full	: out std_logic;
  key     	: out std_logic_vector (127 downto 0);
  IV		: out std_logic_vector(95 downto 0)
  );
end entity;

architecture behavioural of input_register is
signal shifted_in,shifted_in_next : std_logic_vector (223 downto 0);
signal in_counter,in_counter_next : unsigned (7 downto 0);

begin

process (clk,rst)
begin
  if rst = '1' then
	shifted_in <= (others => '0');
	in_counter <= (others => '0');
  elsif clk'event and clk='1' then
	shifted_in <= shifted_in_next;
	in_counter <= in_counter_next;
  end if;
end process;

process (WEB,data_in,shifted_in,in_counter)
begin
  shifted_in_next <= shifted_in;
  in_counter_next <= in_counter;
  if WEB = '1' then
	in_counter_next <= in_counter + 1;
	shifted_in_next <= shifted_in(222 downto 0) & data_in;
  elsif new_key = '1' then
	in_counter_next <= (others => '0');
  else
	in_counter_next <= in_counter;
  end if;

  if in_counter >= 223 then
	reg_full <= '1';
  else
	reg_full <= '0';
  end if;
end process;

key <= shifted_in(127 downto 0);
IV <= shifted_in (223 downto 128);

end architecture;
 
  
	

