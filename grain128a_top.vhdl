library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity grain128a_top is
  port (
  clk     : in std_logic;
  rst     : in std_logic;
  new_key : in std_logic;
  key     : in std_logic_vector (127 downto 0);
  IV      : in std_logic_vector (95 downto 0);
  stream  : out std_logic;
  lfsr_state : out std_logic_vector (127 downto 0);
  nfsr_state : out std_logic_vector (127 downto 0)
  );
end entity;

architecture arch of grain128a_top is

-- Component declarations
  component grain128a_controller
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    IV0      : in  std_logic;
    new_key  : in std_logic;
    auth     : out std_logic;
    init_FSR : out std_logic;
    init     : out std_logic    -- Set to 1 during initialisation rounds
  );
  end component grain128a_controller;

  component grain128a_datapath
  generic (
    STEP : integer := 1
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    init     : in  std_logic;
    init_FSR : in  std_logic;
    auth     : in  std_logic;
    key      : in  std_logic_vector (127 downto 0);
    IV       : in  std_logic_vector (95 downto 0);
    stream   : out std_logic;
    lfsr_state : out std_logic_vector (127 downto 0);
    nfsr_state : out std_logic_vector (127 downto 0)
  );
  end component grain128a_datapath;

  signal  init  : std_logic;
  signal  init_FSR  : std_logic;
  signal  auth  : std_logic;
begin

-- Component instantiations
  grain128a_controller_i : grain128a_controller
  port map (
    clk      => clk,
    rst      => rst,
    IV0      => IV(0),
    new_key  => new_key,
       auth     => auth,
    init_FSR => init_FSR,
    init     => init
  );

  grain128a_datapath_i : grain128a_datapath
  generic map (
    STEP => 1
  )
  port map (
    clk      => clk,
    rst      => rst,
    init     => init,
    init_FSR => init_FSR,
    auth     => auth,
    key      => key,
    IV       => IV,
    stream   => stream,
    lfsr_state => lfsr_state,
    nfsr_state => nfsr_state
  );

end architecture;
