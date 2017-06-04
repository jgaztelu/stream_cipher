library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_FSR is
  port (
  clk   : in std_logic;
  rst   : in std_logic;
  init_FSR  : in std_logic;
  init      : in std_logic;
  ini_data  : in std_logic_vector (255 downto 0);
  z_in      : in std_logic;
  z_out     : out std_logic_vector (25 downto 0);
  out_data  : out std_logic;
  current_state : out std_logic_vector (255 downto 0)
  );
end entity;

architecture arch of espresso_FSR is
signal shifted  : std_logic_vector (255 downto 0);
signal shifted_next  : std_logic_vector (255 downto 0);
begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    shifted <= (others => '0');
  elsif clk='1' and clk'event then
    shifted <= shifted_next;
  end if;
end process;

  combinational : process(shifted,init,ini_data,z_in,init_FSR)
  begin
    if init_FSR = '1' then
      shifted_next <= ini_data;
    else
      shifted_next (254 downto 0) <= shifted (255 downto 1);
      shifted_next (255) <= shifted (0) xor (shifted(41) and shifted(70));
      shifted_next (251) <= shifted (252) xor (shifted(42) and shifted(83)) xor shifted(8);
      shifted_next (247) <= shifted (248) xor (shifted(44) and shifted(102)) xor shifted(40);
      shifted_next (243) <= shifted (244) xor (shifted(43) and shifted(118)) xor shifted(103);
      shifted_next (239) <= shifted (240) xor (shifted(46) and shifted(141)) xor shifted(117);
      shifted_next (235) <= shifted (236) xor (shifted(67) and shifted(90) and shifted(110) and shifted(137));
      shifted_next (231) <= shifted (232) xor (shifted(50) and shifted(159)) xor shifted(189);
      shifted_next (217) <= shifted (218) xor (shifted(3) and shifted(32));
      shifted_next (213) <= shifted (214) xor (shifted(4) and shifted(45));
      shifted_next (209) <= shifted (210) xor (shifted(6) and shifted(64));
      shifted_next (205) <= shifted (206) xor (shifted(5) and shifted(80));
      shifted_next (201) <= shifted (202) xor (shifted(8) and shifted(103));
      shifted_next (197) <= shifted (198) xor (shifted(29) and shifted(52) and shifted(72) and shifted(99));
      shifted_next (193) <= shifted (194) xor (shifted(12) and shifted(121));

      if init='1' then
        shifted_next (255) <= shifted (0) xor (shifted(41) and shifted(70)) xor z_in;
        shifted_next (217) <= shifted (218) xor (shifted(3) and shifted(32)) xor z_in;
      end if;
    end if;
end process;

z_out(25) <= shifted(80);
z_out(24) <= shifted(99);
z_out(23) <= shifted(137);
z_out(22) <= shifted(227);
z_out(21) <= shifted(222);
z_out(20) <= shifted(187);
z_out(19) <= shifted(243);
z_out(18) <= shifted(217);
z_out(17) <= shifted(247);
z_out(16) <= shifted(231);
z_out(15) <= shifted(213);
z_out(14) <= shifted(235);
z_out(13) <= shifted(255);
z_out(12) <= shifted(251);
z_out(11) <= shifted(181);
z_out(10) <= shifted(239);
z_out(9) <= shifted(174);
z_out(8) <= shifted(44);
z_out(7) <= shifted(164);
z_out(6) <= shifted(29);
z_out(5) <= shifted(255);
z_out(4) <= shifted(247);
z_out(3) <= shifted(243);
z_out(2) <= shifted(213);
z_out(1) <= shifted(181);
z_out(0) <= shifted(174);
out_data <= shifted(0);
current_state <= shifted;
end architecture;
