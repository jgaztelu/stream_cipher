library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity MDM_controller is
  port (
  clk              : in std_logic;
  rst              : in std_logic;
  start            : in std_logic;
  signature_valid  : in std_logic;
  mask_ready       : in std_logic;
  comb_finished    : in std_logic;
  clr_comb_counter : out std_logic;
  new_comb         : out std_logic;
  new_key          : out std_logic;
  load_signature   : out std_logic;
  store			   : out std_logic
  );
end entity;

architecture arch of MDM_controller is
type state_type is (idle,wait_mask,signature);
signal current_state, next_state : state_type;
begin

process (clk,rst)
begin
  if rst = '1' then
    current_state <= idle;
  elsif clk'event and clk = '1' then
    current_state <= next_state;
  end if;
end process;

process (current_state,start,signature_valid,mask_ready,comb_finished)
begin
  clr_comb_counter <= '0';
  new_comb <= '0';
  new_key <= '0';
  store <= '0';
  load_signature <= '0';
  case current_state is
    when idle =>
      if start = '1' then
        next_state <= wait_mask;
        clr_comb_counter <= '1';
      else
        next_state <= idle;
      end if;

    when wait_mask =>
      if mask_ready = '1' then
        new_key <= '1';
        new_comb <= '1';
        next_state <= signature;
      else
        next_state <= wait_mask;
      end if;


    when signature =>
	  store <= '1';
      if signature_valid = '1' then
        if comb_finished = '1' then
          next_state <= idle;
        else
          next_state <= wait_mask;
        end if;
      else
        next_state <= signature;
      end if;
  end case;

end process;
end architecture;
