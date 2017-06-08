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
    comb_counter_max : in unsigned (59 downto 0);
    new_comb         : in std_logic;
    clr_counter      : in std_logic;
    key_masked       : out std_logic_vector (127 downto 0);
    IV_masked        : out std_logic_vector (95 downto 0);
    mask_ready       : out std_logic;
    comb_finished    : out std_logic
  );
end entity;

architecture arch of MDM_keygen is
signal key_sig, key_sig_next                   : std_logic_vector (127 downto 0);
signal key_out, key_out_next                   : std_logic_vector (127 downto 0);
signal IV_sig, IV_sig_next                     : std_logic_vector (95 downto 0);
signal IV_out, IV_out_next                     : std_logic_vector (95 downto 0);
signal comb_counter, comb_counter_next         : unsigned (59 downto 0);
signal assigned_bits, assigned_bits_next       : integer range 0 to 59;
signal key_loop_counter, key_loop_counter_next : integer range 0 to 128;
signal IV_loop_counter, IV_loop_counter_next   : integer range 0 to 96;


begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    key_sig <= (others => '0');
    key_out <= (others => '0');
    IV_sig <= (others => '0');
    IV_out <= (others => '0');
    assigned_bits <= 0;
    key_loop_counter <= 0;
    IV_loop_counter <= 0;
    comb_counter <= (others => '0');
  elsif clk = '1' and clk'event then
    key_sig <= key_sig_next;
    key_out <= key_out_next;
    IV_sig <= IV_sig_next;
    IV_out <= IV_out_next;
    assigned_bits <= assigned_bits_next;
    key_loop_counter <= key_loop_counter_next;
    IV_loop_counter <= IV_loop_counter_next;
    comb_counter <= comb_counter_next;
  end if;
end process;

key_iv_proc: process (key_in,key_mask,IV_in,IV_mask,comb_counter,key_sig,IV_sig,assigned_bits,key_loop_counter,IV_loop_counter,new_comb,key_out,IV_out,clr_counter)

begin
key_sig_next <= key_sig;
IV_sig_next  <= IV_sig;
assigned_bits_next <= assigned_bits;
key_loop_counter_next <= key_loop_counter;
IV_loop_counter_next <= IV_loop_counter;
mask_ready <= '0';
key_out_next  <= key_out;
IV_out_next   <= IV_out;

  if (new_comb = '1' or clr_counter = '1') then
    key_loop_counter_next <= 0;
    IV_loop_counter_next  <= 0;
    assigned_bits_next <= 0;
    key_out_next <= key_sig;      -- Save generated key/IV in the output register. This allows to compute the next key/IV  while the previous is in use,
    IV_out_next <= IV_sig;

  elsif key_loop_counter <= 127 then
    if key_mask (key_loop_counter) = '1' then
      key_sig_next (key_loop_counter) <= comb_counter (assigned_bits);
      assigned_bits_next <= assigned_bits + 1;
    else
      key_sig_next (key_loop_counter) <= key_in (key_loop_counter);
    end if;
    key_loop_counter_next <= key_loop_counter + 1;
  elsif IV_loop_counter <= 95 then
    if IV_mask(IV_loop_counter) = '1' then
      IV_sig_next(IV_loop_counter) <= comb_counter (assigned_bits);
      assigned_bits_next <= assigned_bits + 1;
    else
      IV_sig_next (IV_loop_counter) <= IV_in (IV_loop_counter);
    end if;
    IV_loop_counter_next <= IV_loop_counter + 1;
  end if;
  if IV_loop_counter > 95 then
    mask_ready <= '1';
  else
    mask_ready <= '0';
  end if;
end process;

comb_counter_proc:  process (comb_counter,comb_counter_max,new_comb, clr_counter)
begin
  if new_comb = '1' then
    comb_counter_next <= comb_counter + 1;
  elsif clr_counter = '1' then
    comb_counter_next <= (others => '0');
  else
    comb_counter_next <= comb_counter;
  end if;

  if comb_counter > comb_counter_max + 1 then
    comb_finished <= '1';
  else
    comb_finished <= '0';
  end if;
end process;

key_masked <= key_out;
IV_masked <= IV_out;

end architecture;
