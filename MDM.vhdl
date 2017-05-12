library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity MDM_test is
  generic (
  r_GRAIN_STEP  : integer;
  r_ESPRESSO_STEP : integer
  )
  port (
  clk   : in std_logic;
  rst   : in std_logic;
  init  : in std_logic;   -- 1 when cipher initialisation rounds are running
  input_sel : in std_logic_vector (1 downto 0);     -- "01" for grain, "10" espresso
  grain_in  : in std_logic_vector (r_GRAIN_STEP-1 downto 0);
  espresso_in : in std_logic_vector (r_ESPRESSO_STEP-1 downto 0)

  );
end entity;

architecture arch of MDM_test is
signal input_shift        : std_logic_vector (255 downto 0);
signal input_shift_next   : std_logic_vector (255 downto 0);
signal MDM_signature      : std_logic_vector (255 downto 0);
signal MDM_signature_next : std_logic_vector (255 downto 0);
begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    input_shift <= (others => '0');
    MDM_signature <= (others => '0');
  elsif clk'event and clk='1' then
    input_shift <= input_shift_next;
    MDM_signature <= MDM_signature_next;
  end if;
end process;

combinational : process(input_shift,MDM_signature,input_sel,init,grain_in,espresso_in)
begin
  input_shift_next <= input_shift;
  MDM_signature_next <= MDM_signature;
  if init = '1' then
    if input_sel = "01" then
      input_shift_next <= input_shift (255-r_GRAIN_STEP downto 0) & grain_in;
    elsif input_sel = "10" then
      input_shift_next <= input_shift (255-r_ESPRESSO_STEP downto 0) & espresso_in;
    end if;
  else
    MDM_signature_next <= MDM_signature xor input_shift;
  end if;
end process;
end architecture;
