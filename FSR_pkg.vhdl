-----------------------------------------------------------------------------
--  Package: fsr_taps_type
--  Content: This package contains the type to define the taps of a
--           Feedback Shift Register before synthesis.
-----------------------------------------------------------------------------

library IEEE;
  use ieee.std_logic_1164.all;

package fsr_taps_type is
    type TAPS is array (0 to 31) of integer;
    type LFSR_TAPS is array (natural range <>) of std_logic_vector (5 downto 0);
    type NFSR_TAPS is array (natural range <>) of std_logic_vector (28 downto 0);
    type LFSR_H is array (natural range <>) of std_logic_vector (6 downto 0);
    type NFSR_H is array (natural range <>) of std_logic_vector (1 downto 0);
    type LFSR_PRE is array (natural range <>) of std_logic_vector (0 downto 0);
    type NFSR_PRE is array (natural range <>) of std_logic_vector (6 downto 0);


end package fsr_taps_type;
