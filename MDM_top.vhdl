library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;


entity MDM_top is
  port (
  clk              : in std_logic;
  rst              : in std_logic;
  start            : in std_logic;
  key_in           : in std_logic_vector (127 downto 0);
  IV_in            : in std_logic_vector (95 downto 0);
  key_mask         : in std_logic_vector (127 downto 0);
  IV_mask          : in std_logic_vector (95 downto 0);
  comb_counter_max : in unsigned (59 downto 0);
  grain_in         : in std_logic_vector (GRAIN_STEP-1 downto 0);
  grain_init       : in std_logic;
  signature_in     : in std_logic_vector (255 downto 0);
  key_masked       : out std_logic_vector (127 downto 0);
  IV_masked        : out std_logic_vector (95 downto 0);
  new_key          : out std_logic;
  grain_signature  : out std_logic_vector (255 downto 0)
  );
end entity;

architecture structural of MDM_top is
  component MDM_keygen
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    key_in           : in  std_logic_vector (127 downto 0);
    IV_in            : in  std_logic_vector (95 downto 0);
    key_mask         : in  std_logic_vector (127 downto 0);
    IV_mask          : in  std_logic_vector (95 downto 0);
    comb_counter_max : in  unsigned (59 downto 0);
    new_comb         : in  std_logic;
    clr_counter      : in  std_logic;
    key_masked       : out std_logic_vector (127 downto 0);
    IV_masked        : out std_logic_vector (95 downto 0);
    mask_ready       : out std_logic;
    comb_finished    : out std_logic
  );
  end component MDM_keygen;

  component MDM_signature
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    grain_in        : in  std_logic_vector (GRAIN_STEP-1 downto 0);
    grain_init      : in  std_logic;
    signature_in    : in  std_logic_vector (255 downto 0);
    load_signature  : in  std_logic;
	store_enable	: in  std_logic;
    signature_valid : out std_logic;
    grain_signature : out std_logic_vector (255 downto 0)
  );
  end component MDM_signature;

  component MDM_controller
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    start            : in  std_logic;
    signature_valid  : in  std_logic;
    mask_ready       : in  std_logic;
    comb_finished    : in  std_logic;
    clr_comb_counter : out std_logic;
    new_comb         : out std_logic;
    new_key          : out std_logic;
    load_signature   : out std_logic;
	store			 : out std_logic
  );
  end component MDM_controller;


  signal new_comb        : std_logic;
  signal clr_counter     : std_logic;
  signal signature_valid : std_logic;
  signal comb_finished   : std_logic;
  signal mask_ready      : std_logic;
  signal load_signature  : std_logic;
  signal store			 : std_logic;
begin

  MDM_keygen_i : MDM_keygen
  port map (
    clk              => clk,
    rst              => rst,
    key_in           => key_in,
    IV_in            => IV_in,
    key_mask         => key_mask,
    IV_mask          => IV_mask,
    comb_counter_max => comb_counter_max,
    new_comb         => new_comb,
    clr_counter      => clr_counter,
    key_masked       => key_masked,
    IV_masked        => IV_masked,
    mask_ready       => mask_ready,
    comb_finished    => comb_finished
  );

  MDM_signature_i : MDM_signature
  port map (
    clk             => clk,
    rst             => rst,
    grain_in        => grain_in,
    grain_init      => grain_init,
    signature_in    => signature_in,
    load_signature  => load_signature,
	store_enable	=> store,
    signature_valid => signature_valid,
    grain_signature => grain_signature
  );

  MDM_controller_i : MDM_controller
  port map (
    clk              => clk,
    rst              => rst,
    start            => start,
    signature_valid  => signature_valid,
    mask_ready       => mask_ready,
    comb_finished    => comb_finished,
    clr_comb_counter => clr_counter,
    new_comb         => new_comb,
    new_key          => new_key,
    load_signature   => load_signature,
	store			 => store
  );

end architecture;
