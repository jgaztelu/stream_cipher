library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a_controller is
  port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  new_key  : in  std_logic;
  IV0      : in std_logic;
  auth     : out std_logic;
  init_FSR : out std_logic;   -- Initialise FSRs with new values
  init     : out std_logic    -- Set to 1 during initialisation rounds
  );
end entity;

architecture arch of grain128a_controller is

type state_type is (new_key,initialise,auth,no_auth)

signal current_state     : state_type;
signal next_state        : state_type;
signal init_counter      : unsigned (7 downto 0);
signal init_counter_next : unsigned (7 downto 0);

begin

synchronous : process(clk,rst)
begin
if rst = '1' then
  current_state <= new_key;
  init_counter <= (others => '0');
elsif clk'event and clk= '1' then
  current_state <= next_state;
  init_counter <= init_counter_next;
end if;
end process;

combinational : process(new_key,auth,start)
begin
--Default values
init     <= '0';
init_FSR <= '0';
auth     <= '0';
init_counter_next <= init_counter;

case (current_state) is
  when new_key =>
    init_FSR <= '1';
    init_counter_next <= (others => '0');
    if new_key = '0' then
      next_state <= initialise;
    else
      next_state <= new_key;
    end if;

  when initialise =>
    init <= '1';
    init_counter_next <= init_counter + 1;
    if new_key = '1' then
      next_state <= new_key;
    elsif init_counter = 255 then
      if IV0 = 1 then
        next_state <= auth;
      else
        next_state <= no_auth;
      end if;
    else
      next_state <= initialise;
    end if;

  when auth =>
    auth <= '1'
    if new_key = '1' then
      next_state <= new_key;
    else
      next_state <= auth;
    end if;

  when no_auth =>
    auth <= '0';
    if new_key = '1' then
      next_state <= new_key;
    else
      next_state <= auth;
    end if;
end case;

end process;
end architecture;
