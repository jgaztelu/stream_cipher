library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_z is
  port (
  clk   : in std_logic;
  rst   : in std_logic;
  z_in  : in std_logic_vector (25 downto 0);
  z_out : out std_logic
  );
end entity;

architecture arch of espresso_z is
signal z1,z2,z3,z4,z5,z6,z7,z8  : std_logic;
signal z1_next,z2_next,z3_next,z4_next,z5_next,z6_next,z7_next,z8_next  : std_logic;
begin
synchronous : process(clk,rst)
begin
  if rst = '1' then
    z1 <= '0';
    z2 <= '0';
    z3 <= '0';
    z4 <= '0';
    z5 <= '0';
    z6 <= '0';
    z7 <= '0';
    z8 <= '0';
  elsif clk = '1' and clk'event then
    z1 <= z1_next;
    z2 <= z2_next;
    z3 <= z3_next;
    z4 <= z4_next;
    z5 <= z5_next;
    z6 <= z6_next;
    z7 <= z7_next;
    z8 <= z8_next;
  end if;
end process;

combinational : process(z1,z2,z3,z4,z5,z6,z7,z8,z_in)
begin
  z1_next <= z_in(25) xor z_in(24) xor z_in(23) xor z_in(22);
  z2_next <= z_in(21) xor z_in(20) xor (z_in(19) and z_in(18));
  z3_next <= (z_in(17) and z_in(16)) xor (z_in(15) and z_in(14));
  z4_next <= (z_in(13) and z_in(12)) xor (z_in(11) and z_in(10));
  z5_next <= (z_in(9) and z_in(8)) xor (z_in(7) and z_in(6));
  z6_next <= z_in(5) and z_in(4) and z_in(3) and z_in(2) and z_in(1) and z_in(0);
  z7_next <= z1 xor z2 xor z3 xor z4;
  z8_next <= z5 xor z6;
  --z_out <= z7 xor z8;
  z_out <= z_in(25) xor z_in(24) xor z_in(23) xor z_in(22) xor z_in(21) xor z_in(20) xor (z_in(19) and z_in(18)) xor (z_in(17) and z_in(16)) xor (z_in(15) and z_in(14)) xor
	   (z_in(13) and z_in(12)) xor (z_in(11) and z_in(10)) xor (z_in(9) and z_in(8)) xor (z_in(7) and z_in(6)) xor (z_in(5) and z_in(4) and z_in(3) and z_in(2) and z_in(1) and z_in(0));
end process;
end architecture;
