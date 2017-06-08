library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity input_register is
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  WEB      : in std_logic; -- Write enable
  key_in   : in std_logic_vector (3 downto 0);
  mask_in  : in std_logic_vector (3 downto 0);
  new_key  : in std_logic;
  reg_full : out std_logic;
  key      : out std_logic_vector (127 downto 0);
  key_mask : out std_logic_vector (127 downto 0);
  IV       : out std_logic_vector (95 downto 0);
  IV_mask  : out std_logic_vector (95 downto 0);
  mask_ones : out unsigned (59 downto 0)
  );
end entity;

architecture behavioural of input_register is
signal shifted_in_key,shifted_in_key_next : std_logic_vector (223 downto 0);
signal shifted_in_mask, shifted_in_mask_next : std_logic_vector (223 downto 0);
signal ones_count, ones_count_next :  unsigned (59 downto 0);
signal in_counter,in_counter_next : unsigned (7 downto 0);

begin

process (clk,rst)
begin
  if rst = '1' then
	shifted_in_key <= (others => '0');
  	shifted_in_mask <= (others => '0');
	in_counter <= (others => '0');
  	ones_count <= (others => '0');
  elsif clk'event and clk='1' then
	shifted_in_key <= shifted_in_key_next;
  	shifted_in_mask <= shifted_in_mask_next;
	in_counter <= in_counter_next;
  ones_count <= ones_count_next;
  end if;
end process;

store_data: process (WEB,key_in,mask_in,shifted_in_key,shifted_in_mask,in_counter,new_key)
begin
  shifted_in_key_next <= shifted_in_key;
  shifted_in_mask_next <= shifted_in_mask;
  in_counter_next <= in_counter;
  if WEB = '1' then
	in_counter_next <= in_counter + 1;
	shifted_in_key_next <= shifted_in_key (219 downto 0) & key_in;
  	shifted_in_mask_next <= shifted_in_mask (219 downto 0) & mask_in;
  elsif new_key = '1' then
	in_counter_next <= (others => '0');
  else
	in_counter_next <= in_counter;
  end if;

  if in_counter >= 56 then
	reg_full <= '1';
  else
	reg_full <= '0';
  end if;
end process;

count_ones : process(WEB,mask_in,new_key,ones_count)
begin
  if new_key = '1' then
    ones_count_next <= (others => '0');
  elsif (WEB = '1' and mask_in = '1') then
      ones_count_next <= ones_count (58 downto 0) & mask_in;
  else
    ones_count_next <= ones_count;
  end if;
end process;

key <= shifted_in_key (127 downto 0);
IV <= shifted_in_key (223 downto 128);
key_mask <= shifted_in_mask (127 downto 0);
IV_mask <= shifted_in_mask (223 downto 128);
mask_ones <= ones_count;

end architecture;
