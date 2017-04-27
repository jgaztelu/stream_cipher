library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a is
  port (
  clock
  );
end entity;

architecture arch of grain128a is

-- Component declarations
component FSR
generic (
  r_WIDTH  : integer := 128;
  r_STEP   : integer := 1;
  r_FWIDTH : integer := 6;
  r_HWIDTH : integer := 2;
  r_TAPS   : TAPS;
  r_STATE  : TAPS
);
port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  feedback : in  std_logic_vector ((r_STEP-1) downto 0);
  init     : in  std_logic;
  ini_data : in  std_logic_vector ((r_WIDTH-1) downto 0);
  out_data : out std_logic_vector ((r_STEP-1) downto 0);
  fb_out   : out std_logic_vector ((r_FWIDTH-1) downto 0);
  h_out    : out std_logic_vector ((r_HWIDTH-1) downto 0)
);
end component FSR;

component grain_nonlinear_fb
port (
  taps_in    : in  std_logic_vector(28 downto 0);
  pre_out_in : in  std_logic;
  init       : in  std_logic;
  lfsr_in    : in  std_logic;
  fb_out     : out std_logic
);
end component grain_nonlinear_fb;

component grain_linear_fb
port (
  taps_in    : in  std_logic_vector  (5 downto 0);
  pre_out_in : in  std_logic;
  init       : in  std_logic;
  fb_out     : out std_logic
);
end component grain_linear_fb;

component h_function
port (
  states_in : in  std_logic_vector(8 downto 0);
  h_out     : out std_logic
);
end component h_function;

-- Signal declarations
signal lfsr_fb_taps  : std_logic_vector (5 downto 0);
signal nfsr_fb_taps  : std_logic_vector (28 downto 0);
begin

--Component instantiations

LFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => 2,
  r_FWIDTH => 6,
  r_HWIDTH => 2,
  r_TAPS   => (128,121,90,58,47,32,others=>-1),
  r_STATE  => (33,116,others => -1)
)
port map (
  clk      => clk,
  rst      => rst,
  feedback => feedback,
  init     => init,
  ini_data => ini_data,
  out_data => out_data,
  fb_out   => lfsr_fb_taps,
  h_out    => h_out
);

NFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => 1,
  r_FWIDTH => 29,
  r_HWIDTH => 7,
  r_TAPS   => (40,36,35,33,106,104,106,58,50,46,117,115,111,110,88,80,101,69,67,63,125,61,60,44,128,102,72,37,32,others => -1),
  r_STATE  => (34,49,68,86,108,115,120,others =>-1)
)
port map (
  clk      => clk,
  rst      => rst,
  feedback => feedback,
  init     => init,
  ini_data => ini_data,
  out_data => out_data,
  fb_out   => nfsr_fb_taps,
  h_out    => h_out
);

grain_linear_fb_i : grain_linear_fb
port map (
  taps_in    => taps_in,
  pre_out_in => pre_out_in,
  init       => init,
  fb_out     => fb_out
);

grain_nonlinear_fb_i : grain_nonlinear_fb
port map (
  taps_in    => taps_in,
  pre_out_in => pre_out_in,
  init       => init,
  lfsr_in    => lfsr_in,
  fb_out     => fb_out
);

h_function_i : h_function
port map (
  states_in => states_in,
  h_out     => h_out
);


end architecture;
