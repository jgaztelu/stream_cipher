library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity h_function is
  port (
  states_in :  in std_logic_vector(8 downto 0);
  h_out     :  out std_logic
  );
end entity;

architecture arch of h_function is

begin
h_out <= (states_in(0) and states_in (1)) xor (states_in(2) and states_in (3)) xor (states_in(4) and states_in (5))
          xor (states_in(6) and states_in (7)) xor (states_in(0) and states_in (4) and states_in(8));
end architecture;
