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
  stream   : out std_logic;
  lfsr_state : out std_logic_vector (127 downto 0);
  nfsr_state : out std_logic_vector (127 downto 0)
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
  pre_out  : out std_logic_vector ((r_PREWIDTH-1) downto 0);
  current_state : out std_logic_vector ((r_WIDTH-1) downto 0)
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
  r_TAPS   => (96,81,70,38,7,0,others => 0), --reversed
  r_STATE  => (8,13,18,42,60,79,94,others => 0), --reversed
  r_PRE   =>  (93,others => 0) --reversed
)
port map (
  clk      => clk,
  rst      => rst,
  fb_in    => lfsr_fb,
  init     => init_FSR,
  ini_data (95 downto 0) => IV,
  ini_data (126 downto 96) => (others => '1'),
  ini_data (127) => '0',	
  out_data => lfsr_out,
  fb_out   => lfsr_fb_taps,
  h_out    => lfsr_h,
  pre_out  => lfsr_pre,
  current_state => lfsr_state
);

NFSR : FSR
generic map (
  r_WIDTH  => 128,
  r_STEP   => STEP,
  r_FWIDTH => 29,
  r_HWIDTH => 2,
  r_PREWIDTH => 7,
  r_TAPS   => (96,91,56,26,0,84,68,67,3,65,61,59,27,48,40,18,17,13,11,82,78,70,25,24,22,95,93,92,88,others => 0),--reversed
  r_STATE  => (12,95,others => 0),--reversed
  r_PRE   =>  (2,15,36,45,64,73,89,others => 0) --reversed
)
port map (
  clk      => clk,
  rst      => rst,
  fb_in    => nfsr_fb,
  init     => init_FSR,
  ini_data => key,
  out_data => open,
  fb_out   => nfsr_fb_taps,
  h_out    => nfsr_h,
  pre_out  => nfsr_pre,
  current_state => nfsr_state
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
