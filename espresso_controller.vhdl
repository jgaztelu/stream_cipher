library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_controller is
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  new_key  : in std_logic;
  init_FSR : out std_logic;
  init     : out std_logic
  );
end entity;

architecture arch of espresso_controller is
type state_type is (s_new_key,s_initialisation,s_keystream);
signal  current_state,next_state  : state_type;
signal init_counter, init_counter_next : unsigned (8 downto 0);
begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    current_state <= s_new_key;
    init_counter <= (others => '0');
  elsif clk'event and clk='1' then
    current_state <= next_state;
    init_counter <= init_counter_next;
  end if;
end process;

combinational : process(current_state,init_counter,new_key)
begin
init <= '0';
init_FSR <= '0';

case (current_state) is
  when s_new_key  =>
    init_FSR <= '1';
    if new_key = '1' then
      next_state <= s_new_key;
    else
      next_state <= s_initialisation;
    end if;

    when s_initialisation =>
      init <= '1';
      init_counter_next <= init_counter + 1;
      if new_key = '1' then
        next_state <= s_new_key;
      elsif init_counter < 258 then
        next_state <= s_initialisation;
      else
        next_state <= s_keystream;
      end if;

    when s_keystream =>
      if new_key = '1' then
        next_state <= s_new_key;
      else
        next_state <= s_keystream;
      end if;
  end case;
end process;
end architecture;
