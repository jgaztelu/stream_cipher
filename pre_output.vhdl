library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pre_output is
  port (
  lfsr_in : in std_logic;
  nfsr_in : in std_logic_vector (6 downto 0);
  h_in    : in std_logic;
  pre_out : out std_logic
  );
end entity;

architecture behavioural of pre_output is

begin
pre_out <= h_in xor lfsr_in xor nfsr_in (6) xor nfsr_in (5) xor nfsr_in (4) xor nfsr_in (3) xor nfsr_in (2) xor nfsr_in (1) xor nfsr_in (0);
end architecture;
