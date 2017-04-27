library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;
  entity FSR is

    generic (
    r_WIDTH  : integer :=  128; -- Register width
    r_STEP   : integer := 1;  -- Update step
    r_FWIDTH  : integer := 6; -- Feedback output width
    r_HWIDTH  : integer := 2; -- h-function output width
    r_TAPS    : TAPS (0 to 31):= (128,121,90,58,47,32,others=>-1);           -- Change the size according to the number of taps
    r_STATE   : TAPS (0 to 15):= (116,33, others => -1)
    );

    port (
    clk      : in std_logic;
    rst      : in std_logic;
    feedback : in std_logic_vector ((r_STEP-1) downto 0);
    init     : in std_logic;
    ini_data : in std_logic_vector ((r_WIDTH-1) downto 0);
    out_data : out std_logic_vector ((r_STEP-1) downto 0);
    fb_out   : out std_logic_vector ((r_FWIDTH-1) downto 0);
    h_out    : out std_logic_vector ((r_HWIDTH-1) downto 0)
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

process (feedback,init,ini_data,shifted)
begin
  if init = '1' then
    shifted_next <= ini_data;
  else
    shifted_next <= shifted((r_WIDTH-r_STEP-1) downto 0) & feedback;
  end if;
end process;
out_data <= shifted ((r_WIDTH-1) downto (r_WIDTH-r_STEP));

-- Connect taps in the order of r_TAPS, from LSB to MSB (First value in the array goes to LSB of the output)
    gen_feedback: for I in 0 to (r_FWIDTH-1)  generate
      fb_out(I) <= shifted(r_TAPS(I)-1);
    end generate gen_feedback;

-- Connect output bits for h function
    gen_h: for I in 0 to (r_HWIDTH-1)  generate
      h_out(I) <= shifted(r_STATE(I)-1);
    end generate gen_h;

end architecture;
