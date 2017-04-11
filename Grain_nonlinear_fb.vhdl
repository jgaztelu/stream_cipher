library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain_nonlinear_fb is
  port (
  taps_in    : in std_logic_vector(28 downto 0);   --Input bits are expected in order of appearance on equation g(x) in Grain128a specification, left to right.
  pre_out_in : in std_logic;
  init       : in std_logic;
  fb_out     : out std_logic
  );
end entity;

architecture non_linear_fb of grain_nonlinear_fb is

begin
process(taps_in,pre_out_in,init)
begin
if init = '1' then
  -- g(x) = 1^x(32)^x(37)^x(72)^x(102)^x(128)^x(44)x(60)^x(61)x(125)^x(63)x(67)^x(69)x(101)^x(80)x(88)^x(110)x(111)^x(115)x(117)^x(46)x(50)x(58)^x(103)x(104)x(106)^x(33)x(35)x(36)x(40)
  fb_out <= '1' xor pre_out_in xor taps_in(28) xor taps_in(27) xor taps_in (26) xor taps_in(25) xor taps_in(24) xor (taps_in (23) and taps_in(22)) xor (taps_in (21) and taps_in(20))
            xor (taps_in (19) and taps_in(18)) xor (taps_in (17) and taps_in(16)) xor (taps_in (15) and taps_in(14)) xor (taps_in (13) and taps_in(12)) xor (taps_in (11) and taps_in(10))
            xor (taps_in (9) and taps_in(8) and taps_in(7)) xor (taps_in (6) and taps_in(5) and taps_in(4)) xor (taps_in (3) and taps_in(2) and taps_in(1) and taps_in(0));
else
  fb_out <= '1' xor taps_in(28) xor taps_in(27) xor taps_in (26) xor taps_in(25) xor taps_in(24) xor (taps_in (23) and taps_in(22)) xor (taps_in (21) and taps_in(20))
            xor (taps_in (19) and taps_in(18)) xor (taps_in (17) and taps_in(16)) xor (taps_in (15) and taps_in(14)) xor (taps_in (13) and taps_in(12)) xor (taps_in (11) and taps_in(10))
            xor (taps_in (9) and taps_in(8) and taps_in(7)) xor (taps_in (6) and taps_in(5) and taps_in(4)) xor (taps_in (3) and taps_in(2) and taps_in(1) and taps_in(0));
end if;
end process;
end architecture;
