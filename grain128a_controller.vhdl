library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a_controller is
  port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  IV0      : in std_logic;
  new_key  : in std_logic;
  auth     : out std_logic;
  init_FSR : out std_logic;   -- Initialise FSRs with new values
  init     : out std_logic;   -- Set to 1 during initialisation rounds
  pre_64   : out std_logic    -- Set to 1 after 64 pre-output rounds if auth = 1
  );
end entity;

architecture arch of grain128a_controller is

type state_type is (s_new_key,s_initialise,s_auth,s_noauth);

signal current_state     : state_type;
signal next_state        : state_type;
signal init_counter      : unsigned (7 downto 0);
signal init_counter_next : unsigned (7 downto 0);
signal auth_counter      : unsigned (6 downto 0);
signal auth_counter_next : unsigned (6 downto 0);

begin

synchronous : process(clk,rst)
begin
if rst = '1' then
  current_state <= s_new_key;
  init_counter <= (others => '0');
  auth_counter <= (others => '0');
elsif clk'event and clk= '1' then
  current_state <= next_state;
  init_counter <= init_counter_next;
  auth_counter <= auth_counter_next;
end if;
end process;

combinational : process(new_key,IV0,init_counter,auth_counter,current_state)
begin
--Default values
init     <= '0';
init_FSR <= '0';
auth     <= '0';
init_counter_next <= init_counter;
auth_counter_next <= auth_counter;
pre_64  <= '0';

case (current_state) is
  when s_new_key =>
    init_FSR <= '1';
    init_counter_next <= (others => '0');
    auth_counter_next <= (others => '0');
    if new_key = '0' then
      next_state <= s_initialise;
    else
      next_state <= s_new_key;
    end if;

  when s_initialise =>
    init <= '1';
    init_counter_next <= init_counter + 1;
    if new_key = '1' then
      next_state <= s_new_key;
    elsif init_counter = 255 then
      if IV0 = '1' then
        next_state <= s_auth;
      else
        next_state <= s_noauth;
      end if;
    else
      next_state <= s_initialise;
    end if;

  when s_auth =>
    auth <= '1';

    if auth_counter < 63 then
      auth_counter_next <= auth_counter + 1;
    else
      pre_64 <= '1';
    end if;

    if new_key = '1' then
      next_state <= s_new_key;
    else
      next_state <= s_auth;
    end if;

  when s_noauth =>
    auth <= '0';
    if new_key = '1' then
      next_state <= s_new_key;
    else
      next_state <= s_noauth;
    end if;
end case;

end process;
end architecture;
