library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_controller is
  port (
  clk : in std_logic;
  rst : in std_logic;
  new_key : in std_logic
  init_FSR : out std_logic;
  init    : out std_logic
  );
end entity;

architecture arch of espresso_controller is
type state_type is (new_key,initialisation,keystream)
signal  current_state,next_state  : state_type;
signal init_counter, init_counter_next : unsigned (8 downto 0);
begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    current_state <= new_key;
    init_counter <= (others => '0');
  elsif clk'event and clk='1' then
    current_state <= next_state;
    init_counter <= init_counter_next:
  end if;
end process;

combinational : process(current_state,init_counter,new_key)
begin
init <= '0';
init_FSR <= '0';

case (current_state) is
  when new_key  =>
    init_FSR <= '1';
    if new_key = '1' then
      next_state <= new_key;
    else
      next_state <= initialisation;
    end if;

    when initialisation =>
      init <= '1';
      init_counter_next <= init_counter + 1;
      if new_key = '1' then
        next_state <= new_key;
      elsif init_counter < 258 then
        next_state <= initialisation;
      else
        next_state <= keystream;
      end if;

    when keystream =>
      if new_key = '1' then
        next_state <= new_key;
      else
        next_state <= keystream;
      end if;
  end case;
end process;
end architecture;
