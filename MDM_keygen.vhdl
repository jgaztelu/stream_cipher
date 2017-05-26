library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity MDM_keygen is
  port (
    clk              : in std_logic;
    rst              : in std_logic;
    key_in           : in std_logic_vector (127 downto 0);
    IV_in            : in std_logic_vector (95 downto 0);
    key_mask         : in std_logic_vector (127 downto 0);
    IV_mask          : in std_logic_vector (95 downto 0);
    comb_counter_max : in unsigned (6 downto 0);
    new_comb         : in std_logic;
    key_masked       : out std_logic_vector (127 downto 0);
    IV_masked        : out std_logic_vector (95 downto 0)
  );
end entity;

architecture arch of MDM_keygen is
signal key_sig, key_sig_next             : std_logic_vector (127 downto 0);
signal IV_sig, IV_sig_next               : std_logic_vector (95 downto 0);
signal comb_counter, comb_counter_next   : unsigned (59 downto 0);
signal assigned_bits, assigned_bits_next : integer range 0 to 59;
signal key_loop_counter, key_loop_counter_next   : integer range 0 to 128;
signal IV_loop_counter, IV_loop_counter_next     : integer range 0 to 96;


begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    key_sig <= (others => '0');
    IV_sig <= (others => '0');
    assigned_bits <= 0;
    key_loop_counter <= 0;
    IV_loop_counter <= 0;
    comb_counter <= (others => '0');
  elsif clk = '1' and clk'event then
    key_sig <= key_sig_next;
    IV_sig <= IV_sig_next;
    assigned_bits <= assigned_bits_next;
    key_loop_counter <= key_loop_counter_next;
    IV_loop_counter <= IV_loop_counter_next;
    comb_counter <= comb_counter_next;
  end if;
end process;

key_iv_proc: process (key_in,key_mask,IV_in,IV_mask,comb_counter,key_sig,IV_sig,assigned_bits,key_loop_counter,IV_loop_counter)

begin
key_sig_next <= key_sig;
IV_sig_next  <= IV_sig;
assigned_bits_next <= assigned_bits;
key_loop_counter_next <= key_loop_counter;
IV_loop_counter_next <= IV_loop_counter;

  if key_loop_counter < 128 then
    if key_mask (key_loop_counter) = '1' then
      key_sig_next (key_loop_counter) <= comb_counter (assigned_bits);
      assigned_bits_next <= assigned_bits + 1;
    else
      key_sig_next (key_loop_counter) <= key_in (key_loop_counter);
    end if;
    key_loop_counter_next <= key_loop_counter + 1;
  elsif IV_loop_counter < 96 then
    if IV_mask(IV_loop_counter) = '1' then
      IV_sig_next(IV_loop_counter) <= comb_counter (assigned_bits);
      assigned_bits_next <= assigned_bits + 1;
    else
      IV_sig_next (IV_loop_counter) <= IV_in (IV_loop_counter);
    end if;
    IV_loop_counter_next <= IV_loop_counter + 1;
  end if;
end process;

comb_counter_proc:  process (comb_counter,comb_counter_max,new_comb)
begin
  if (new_comb = '1' and comb_counter < comb_counter_max) then
    comb_counter_next <= comb_counter + 1;
  else
    comb_counter_next <= comb_counter;
  end if;
end process;

key_masked <= key_sig;
IV_masked <= IV_sig;

end architecture;
