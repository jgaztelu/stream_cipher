-----------------------------------------------------------------------------
--  Package: fsr_taps_type
--  Content: This package contains the type to define the taps of a
--           Feedback Shift Register before synthesis.
-----------------------------------------------------------------------------

library IEEE;
  use ieee.std_logic_1164.all;

package fsr_taps_type is
    type TAPS is array (0 to 31) of integer;
end package fsr_taps_type;
