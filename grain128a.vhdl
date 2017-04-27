library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;


entity grain128a is
  generic (
  STEP :  integer := 1
  );
  port (
  clk  : in std_logic;
  rst  : in std_logic;
  init : in std_logic;
  auth : in std_logic;
  key  : in std_logic_vector (127 downto 0);
  IV   : in std_logic_vector (95 downto 0)
  );
end entity;

architecture arch of grain128a is

-- Component declarations
component FSR
generic (
  r_WIDTH  : integer;
  r_STEP   : integer;
  r_FWIDTH : integer;
  r_HWIDTH : integer;
  r_TAPS   : TAPS;
  r_STATE  : TAPS
);
port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  fb_in : in  std_logic_vector ((r_STEP-1) downto 0);
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

signal lfsr_fb_taps : std_logic_vector (5 downto 0);
signal nfsr_fb_taps : std_logic_vector (28 downto 0);
signal nfsr_fb      : std_logic_vector (STEP-1 downto 0);
signal lfsr_fb      : std_logic_vector (STEP-1 downto 0);
signal lfsr_out     : std_logic_vector (STEP-1 downto 0);
signal h_out        : std_logic;
signal nfsr_h       : std_logic_vector (1 downto 0);
signal lfsr_h       : std_logic_vector (6 downto 0);
signal nfsr_pre     : std_logic_vector (6 downto 0);
signal lfsr_pre     : std_logic_vector (1 downto 0);
signal pre_out      : std_logic;


begin
--Component instantiations

LFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => 1,
  r_FWIDTH => 6,
  r_HWIDTH => 2,
  r_TAPS   => (128,121,90,58,47,32,others=>-1),
  r_STATE  => (33,116,others => -1)
)
port map (
  clk      => clk,
  rst      => rst,
  fb_in    => lfsr_fb,
  init     => init,
  ini_data => key,
  out_data => lfsr_out,
  fb_out   => lfsr_fb_taps,
  h_out    => lfsr_h
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
  fb_in    => nfsr_fb,
  init     => init,
  ini_data (127 downto 32) => IV,
  ini_data (31 downto 1) => '0',
  ini_data (0)      => '1',
  out_data => open,
  fb_out   => nfsr_fb_taps,
  h_out    => nfsr_h
);

grain_linear_fb_i : grain_linear_fb
port map (
  taps_in    => lfsr_fb_taps,
  pre_out_in => pre_out,
  init       => init,
  fb_out     => lfsr_fb (0)
);

grain_nonlinear_fb_i : grain_nonlinear_fb
port map (
  taps_in    => nfsr_fb_taps,
  pre_out_in => pre_out,
  init       => init,
  lfsr_in    => lfsr_out(0),
  fb_out     => nfsr_fb (0)
);

h_function_i : h_function
port map (
  states_in => states_in,
  h_out     => h_out
);


end architecture;
