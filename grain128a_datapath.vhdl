library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;


entity grain128a_datapath is
  generic (
  STEP  : integer := 1
  );
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  init     : in std_logic;
  init_FSR : in std_logic;
  auth     : in std_logic;
  key      : in std_logic_vector (127 downto 0);
  IV       : in std_logic_vector (95 downto 0);
  stream   : out std_logic
  );
end entity;

architecture arch of grain128a_datapath is

-- Component declarations
component FSR
generic (
  r_WIDTH    : integer;
  r_STEP     : integer;
  r_FWIDTH   : integer;
  r_HWIDTH   : integer;
  r_PREWIDTH : integer;
  r_TAPS     : TAPS;
  r_STATE    : TAPS;
  r_PRE      : TAPS
);
port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  fb_in    : in  std_logic_vector ((r_STEP-1) downto 0);
  init     : in  std_logic;
  ini_data : in  std_logic_vector ((r_WIDTH-1) downto 0);
  out_data : out std_logic_vector ((r_STEP-1) downto 0);
  fb_out   : out std_logic_vector ((r_FWIDTH-1) downto 0);
  h_out    : out std_logic_vector ((r_HWIDTH-1) downto 0);
  pre_out  : out std_logic_vector ((r_PREWIDTH-1) downto 0)
);
end component FSR;


component grain_nonlinear_fb
port (
  taps_in    : in  std_logic_vector(28 downto 0);
  pre_out_in : in  std_logic;
  initialising       : in  std_logic;
  lfsr_in    : in  std_logic;
  fb_out     : out std_logic
);
end component grain_nonlinear_fb;

component grain_linear_fb
port (
  taps_in    : in  std_logic_vector  (5 downto 0);
  pre_out_in : in  std_logic;
  initialising       : in  std_logic;
  fb_out     : out std_logic
);
end component grain_linear_fb;

component h_function
port (
  nfsr_in : in std_logic_vector (1 downto 0);
  lfsr_in : in std_logic_vector (6 downto 0);
  h_out   : out std_logic
);
end component h_function;

component pre_output
port (
lfsr_in : in std_logic;
nfsr_in : in std_logic_vector (6 downto 0);
h_in    : in std_logic;
pre_out : out std_logic
);
end component pre_output;


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
signal lfsr_pre     : std_logic_vector (0 downto 0);
signal pre_out      : std_logic;


begin
--Component instantiations

LFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => STEP,
  r_FWIDTH => 6,
  r_HWIDTH => 7,
  r_PREWIDTH => 1,
  r_TAPS   => (128,121,90,58,47,32,others => 0),
  r_STATE  => (34,49,68,86,108,115,120,others => 0),
  r_PRE   =>  (35,others => 0) --(128-93)
)
port map (
  clk      => clk,
  rst      => rst,
  fb_in    => lfsr_fb,
  init     => init_FSR,
  ini_data => key,
  out_data => lfsr_out,
  fb_out   => lfsr_fb_taps,
  h_out    => lfsr_h,
  pre_out  => lfsr_pre
);

NFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => STEP,
  r_FWIDTH => 29,
  r_HWIDTH => 2,
  r_PREWIDTH => 7,
  r_TAPS   => (40,36,35,33,106,104,103,58,50,46,117,115,111,110,88,80,101,69,67,63,125,61,60,44,128,102,72,37,32,others => 0),
  r_STATE  => (33,116,others => 0),
  r_PRE   =>  (126,113,92,83,64,55,39,others => 0) --(128-93)
)
port map (
  clk      => clk,
  rst      => rst,
  fb_in    => nfsr_fb,
  init     => init_FSR,
  ini_data (127 downto 32) => IV,
  ini_data (31 downto 1) => (others => '0'),
  ini_data (0) => '1',
  out_data => open,
  fb_out   => nfsr_fb_taps,
  h_out    => nfsr_h,
  pre_out  => nfsr_pre
);


grain_linear_fb_i : grain_linear_fb
port map (
  taps_in    => lfsr_fb_taps,
  pre_out_in => pre_out,
  initialising       => init,
  fb_out     => lfsr_fb (0)
);

grain_nonlinear_fb_i : grain_nonlinear_fb
port map (
  taps_in    => nfsr_fb_taps,
  pre_out_in => pre_out,
  initialising       => init,
  lfsr_in    => lfsr_out(0),
  fb_out     => nfsr_fb (0)
);

h_function_i : h_function
port map (
  nfsr_in => nfsr_h,
  lfsr_in => lfsr_h,
  h_out   => h_out
);

pre_output_i : pre_output
port map (
  lfsr_in => lfsr_pre(0),
  nfsr_in => nfsr_pre,
  h_in    => h_out,
  pre_out => pre_out
);

stream <= pre_out;


end architecture;
