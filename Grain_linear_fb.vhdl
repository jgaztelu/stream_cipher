library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain_linear_fb is
  port (
  taps_in      : in std_logic_vector  (5 downto 0);
  pre_out_in   : in std_logic;
  initialising : in std_logic;
  fb_out       : out std_logic
  );
end entity;

architecture linear_fb of grain_linear_fb is
begin
process(taps_in,pre_out_in,initialising)
begin
  if initialising = '1' then
    fb_out <= pre_out_in xor taps_in(5) xor taps_in(4) xor taps_in(3) xor taps_in(2) xor taps_in(1) xor taps_in(0);
  else
  fb_out <= taps_in(5) xor taps_in(4) xor taps_in(3) xor taps_in(2) xor taps_in(1) xor taps_in(0);
  end if;
end process;
end architecture;
