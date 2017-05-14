library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;


entity grain128a_datapath is
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  init     : in std_logic;
  init_FSR : in std_logic;
  auth     : in std_logic;
  key      : in std_logic_vector (127 downto 0);
  IV       : in std_logic_vector (95 downto 0);
  pre_64   : in  std_logic;
  stream   : out std_logic_vector (GRAIN_STEP-1 downto 0);
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
  clk           : in  std_logic;
  rst           : in  std_logic;
  fb_in         : in  std_logic_vector ((r_STEP-1) downto 0);
  init          : in  std_logic;
  ini_data      : in  std_logic_vector ((r_WIDTH-1) downto 0);
  out_data      : out std_logic_vector ((r_STEP-1) downto 0);
  fb_out        : out std_logic_vector ((r_FWIDTH*r_STEP-1) downto 0);
  h_out         : out std_logic_vector ((r_HWIDTH*r_STEP-1) downto 0);
  pre_out       : out std_logic_vector ((r_PREWIDTH*r_STEP-1) downto 0);
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

component grain_auth
port (
  clk        : in  std_logic;
  rst        : in  std_logic;
  auth       : in  std_logic;
  pre_64     : in  std_logic;
  pre_out_in : in  std_logic;
  keystream  : out std_logic
);
end component grain_auth;


-- Signal declarations

signal lfsr_fb_taps : std_logic_vector ((GRAIN_STEP*GRAIN_LFSR_FWIDTH-1) downto 0);   -- Feedback out of the LFSR
signal nfsr_fb_taps : std_logic_vector ((GRAIN_STEP*GRAIN_NFSR_FWIDTH-1) downto 0);                                 -- Feedback out of the NFSR
signal nfsr_fb      : std_logic_vector (GRAIN_STEP-1 downto 0);
signal lfsr_fb      : std_logic_vector (GRAIN_STEP-1 downto 0);
signal lfsr_out     : std_logic_vector (GRAIN_STEP-1 downto 0);
signal h_out        : std_logic_vector (GRAIN_STEP-1 downto 0);
signal nfsr_h       : std_logic_vector ((GRAIN_STEP*GRAIN_NFSR_HWIDTH-1) downto 0);
signal lfsr_h       : std_logic_vector ((GRAIN_STEP*GRAIN_LFSR_HWIDTH-1) downto 0);
signal nfsr_pre     : std_logic_vector ((GRAIN_STEP*GRAIN_NFSR_PREWIDTH-1) downto 0);
signal lfsr_pre     : std_logic_vector ((GRAIN_STEP*GRAIN_LFSR_PREWIDTH-1) downto 0);
signal pre_out      : std_logic_vector (GRAIN_STEP-1 downto 0);
signal keystream    : std_logic_vector (GRAIN_STEP-1 downto 0);


begin
--Component instantiations

LFSR : FSR
generic map (
  r_WIDTH  => GRAIN_LFSR_WIDTH,
  r_STEP   => GRAIN_STEP,
  r_FWIDTH => GRAIN_LFSR_FWIDTH,
  r_HWIDTH => GRAIN_LFSR_HWIDTH,
  r_PREWIDTH => GRAIN_LFSR_PREWIDTH,
  r_TAPS   => GRAIN_LFSR_TAPS,
  r_STATE  => GRAIN_LFSR_STATE,
  r_PRE   =>  GRAIN_LFSR_PRE
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
  r_WIDTH  => GRAIN_NFSR_WIDTH,
  r_STEP   => GRAIN_STEP,
  r_FWIDTH => GRAIN_NFSR_FWIDTH,
  r_HWIDTH => GRAIN_NFSR_HWIDTH,
  r_PREWIDTH => GRAIN_NFSR_PREWIDTH,
  r_TAPS   => GRAIN_NFSR_TAPS,--reversed
  r_STATE  => GRAIN_NFSR_STATE,--reversed
  r_PRE   =>  GRAIN_NFSR_PRE --reversed
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


--grain_linear_fb_i : grain_linear_fb
--port map (
--  taps_in    => lfsr_fb_taps,
--  pre_out_in => pre_out,
--  initialising       => init,
--  fb_out     => lfsr_fb (0)
--);

--grain_nonlinear_fb_i : grain_nonlinear_fb
--port map (
--  taps_in    => nfsr_fb_taps,
--  pre_out_in => pre_out,
--  initialising       => init,
--  lfsr_in    => lfsr_out(0),
--  fb_out     => nfsr_fb (0)
--);

--h_function_i : h_function
--port map (
--  nfsr_in => nfsr_h,
--  lfsr_in => lfsr_h,
--  h_out   => h_out
--);

--pre_output_i : pre_output
--port map (
--  lfsr_in => lfsr_pre(0),
--  nfsr_in => nfsr_pre,
--  h_in    => h_out,
--  pre_out => pre_out
--);

--grain_auth_i : grain_auth
--port map (
--  clk        => clk,
--  rst        => rst,
--  auth       => auth,
--  pre_64     => pre_64,
--  pre_out_in => pre_out,
--  keystream  => keystream
--);

gen_parallel: for I in 0 to GRAIN_STEP-1 generate
  grain_linear_fb_i : grain_linear_fb
  port map (
    taps_in    => lfsr_fb_taps((GRAIN_LFSR_FWIDTH*(I+1) - 1) downto GRAIN_LFSR_FWIDTH*I),
    pre_out_in => pre_out(I),
    initialising       => init,
    fb_out     => lfsr_fb (I)
  );

  grain_nonlinear_fb_i : grain_nonlinear_fb
  port map (
    taps_in    => nfsr_fb_taps((GRAIN_NFSR_FWIDTH*(I+1) - 1) downto GRAIN_NFSR_FWIDTH*I),
    pre_out_in => pre_out(I),
    initialising       => init,
    lfsr_in    => lfsr_out(I),
    fb_out     => nfsr_fb (I)
  );

  h_function_i : h_function
  port map (
    nfsr_in => nfsr_h((GRAIN_NFSR_HWIDTH*(I+1) - 1) downto GRAIN_NFSR_HWIDTH*I),
    lfsr_in => lfsr_h((GRAIN_LFSR_HWIDTH*(I+1) - 1) downto GRAIN_LFSR_HWIDTH*I),
    h_out   => h_out(I)
  );

  pre_output_i : pre_output
  port map (
    lfsr_in => lfsr_pre (I),
    nfsr_in => nfsr_pre ((GRAIN_NFSR_PREWIDTH*(I+1) -1) downto GRAIN_NFSR_PREWIDTH*I),
    h_in    => h_out(I),
    pre_out => pre_out(I)
  );

  grain_auth_i : grain_auth
  port map (
    clk        => clk,
    rst        => rst,
    auth       => auth,
    pre_64     => pre_64,
    pre_out_in => pre_out(I),
    keystream  => keystream(I)
  );

end generate gen_parallel;

stream <= keystream;


end architecture;
