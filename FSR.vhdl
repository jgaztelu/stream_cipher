library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;
  entity FSR is

    generic (
    r_WIDTH    : integer; -- Register width
    r_STEP     : integer;  -- Update step
    r_FWIDTH   : integer; -- Feedback output width
    r_HWIDTH   : integer; -- h-function output width
    r_PREWIDTH : integer; -- Pre-output function output width
    r_TAPS     : TAPS;    -- Change the size according to the number of taps
    r_STATE    : TAPS;
    r_PRE      : TAPS
    );

    port (
    clk      : in std_logic;
    rst      : in std_logic;
    fb_in    : in std_logic_vector ((r_STEP-1) downto 0);
    init     : in std_logic;
    ini_data : in std_logic_vector ((r_WIDTH-1) downto 0);
    out_data : out std_logic_vector ((r_STEP-1) downto 0);
    fb_out   : out std_logic_vector ((r_FWIDTH-1) downto 0);
    h_out    : out std_logic_vector ((r_HWIDTH-1) downto 0);
    pre_out  : out std_logic_vector ((r_PREWIDTH-1) downto 0);
    current_state : out std_logic_vector ((r_WIDTH-1) downto 0)
    );
  end entity;

architecture behavioural of FSR is
signal shifted,shifted_next  : std_logic_vector((r_WIDTH-1) downto 0);
begin
process(clk,rst)
begin
if rst = '1' then
  shifted <= (others => '0');
elsif clk'event and clk = '1' then
  shifted <= shifted_next;
end if;
end process;

process (fb_in,init,ini_data,shifted)
begin
 -- shifted_next <= shifted;
  if init = '1' then
    shifted_next <= ini_data;
  else
    shifted_next <= fb_in & shifted((r_WIDTH-1) downto r_STEP);
  end if;
end process;
out_data <= shifted ((r_STEP-1) downto 0);
current_state <= shifted;

-- The bits defined in the r_TAPS and r_STATE arrays are connected to the outputs in the same order as they are written (left to right)
-- Example: r_TAPS := (10,6) will create fb_out (1 downto 0) = bit10 & bit 6, in that order
-- Connect taps in the order of r_TAPS
    gen_feedback: for I in (r_FWIDTH-1) downto 0 generate
      fb_out(I) <= shifted(r_TAPS(r_FWIDTH-I-1));
    end generate gen_feedback;

-- Connect output bits for h function
    gen_h: for I in (r_HWIDTH-1) downto 0 generate
      h_out(I) <= shifted(r_STATE(r_HWIDTH-I-1));
    end generate gen_h;

-- Connect output bits for the pre-output function
    gen_pre: for I in (r_PREWIDTH-1) downto 0 generate
      pre_out(I) <= shifted(r_PRE(r_PREWIDTH-I-1));
    end generate gen_pre;

end architecture;
