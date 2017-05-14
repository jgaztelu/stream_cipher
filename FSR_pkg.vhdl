-----------------------------------------------------------------------------
--  Package: fsr_taps_type
--  Content: This package contains the type to define the taps of a
--           Feedback Shift Register before synthesis.
-----------------------------------------------------------------------------

library IEEE;
  use ieee.std_logic_1164.all;

package fsr_taps_type is

-- Types
  type TAPS is array (0 to 31) of integer;    -- Type used to define an array of integers which determine the feedback taps of the FSR.

-- Constants for Grain cipher
  constant GRAIN_STEP : natural range 0 to 32 := 1;       --Step size for the Grain cipher (bits/cycle). Determines the amount of parallel hardware (max 32).

  -- LFSR constants
  constant GRAIN_LFSR_WIDTH  : natural := 128;            -- Width of the Linear Feedback Shift Register
  constant GRAIN_LFSR_FWIDTH : natural := 6;              -- Width of the Feedback output port for the LFSR.
  constant GRAIN_LFSR_HWIDTH : natural := 7;              -- Width of the h-function output port for the LFSR.
  constant GRAIN_LFSR_PREWIDTH : natural := 1;            -- Width of the pre-output port for the LFSR.
  constant GRAIN_LFSR_TAPS  : TAPS := (96,81,70,38,7,0,others => 0);      -- LFSR bits to be connected to the Feedback output (reversed)
  constant GRAIN_LFSR_STATE : TAPS := (8,13,20,42,60,79,94,others => 0);  -- LFSR bits to be connected to the h-function output (reversed)
  constant GRAIN_LFSR_PRE : TAPS := (93,others => 0);                     -- LFSR bits to be connected to the pre-output port (reversed)


  -- NFSR constants
  constant GRAIN_NFSR_WIDTH    : natural := 128;            -- Width of the Non-linear Feedback Shift Register
  constant GRAIN_NFSR_FWIDTH   : natural := 29;             -- Width of the Feedback output port for the NFSR.
  constant GRAIN_NFSR_HWIDTH   : natural := 2;              -- Width of the h-function output port for the NFSR.
  constant GRAIN_NFSR_PREWIDTH : natural := 7;              -- Width of the pre-output port for the NFSR.
  constant GRAIN_NFSR_TAPS     : TAPS := (96,91,56,26,0,84,68,67,3,65,61,59,27,48,40,18,17,13,11,82,78,70,25,24,22,95,93,92,88,others => 0); -- NFSR bits to be connected to the Feedback output (reversed)
  constant GRAIN_NFSR_STATE    : TAPS := (12,95,others => 0);                                                                                -- NFSR bits to be connected to the h-function output (reversed)
  constant GRAIN_NFSR_PRE      : TAPS := (2,15,36,45,64,73,89,others => 0);                                                                  -- NFSR bits to be connected to the pre-output port (reversed)







end package fsr_taps_type;
