library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_top is
  port (
  clk           : in std_logic;
  rst           : in std_logic;
  start_attack  : in std_logic;
  new_key       : in std_logic;
  key_in        : in std_logic;
  mask_in       : in std_logic;
  WEB           : in std_logic;
  reg_full      : out std_logic;
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  espresso_out  : out std_logic
   );
end entity;

architecture stream_cipher of stream_cipher_top is

  component grain128a_top
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    new_key    : in  std_logic;
    key        : in  std_logic_vector (127 downto 0);
    IV         : in  std_logic_vector (95 downto 0);
    stream     : out std_logic_vector (GRAIN_STEP-1 downto 0);
    initial    : out std_logic;
    lfsr_state : out std_logic_vector (127 downto 0);
    nfsr_state : out std_logic_vector (127 downto 0)
  );
  end component grain128a_top;


component espresso_top is
  port (
  clk           : in std_logic;
  rst           : in std_logic;
  new_key       : in std_logic;
  key           : in std_logic_vector (127 downto 0);
  IV            : in std_logic_vector (95 downto 0);
  keystream     : out std_logic;
  current_state : out std_logic_vector (255 downto 0)
  );
end component;

component MDM_top
port (
  clk              : in  std_logic;
  rst              : in  std_logic;
  start            : in  std_logic;
  key_in           : in  std_logic_vector (127 downto 0);
  IV_in            : in  std_logic_vector (95 downto 0);
  key_mask         : in  std_logic_vector (127 downto 0);
  IV_mask          : in  std_logic_vector (95 downto 0);
  comb_counter_max : in  unsigned (59 downto 0);
  grain_in         : in  std_logic_vector (GRAIN_STEP-1 downto 0);
  grain_init       : in  std_logic;
  signature_in     : in  std_logic_vector (255 downto 0);
  key_masked       : out std_logic_vector (127 downto 0);
  IV_masked        : out std_logic_vector (95 downto 0);
  new_key          : out std_logic;
  grain_signature  : out std_logic_vector (255 downto 0)
);
end component MDM_top;


component input_register
port (
  clk       : in  std_logic;
  rst       : in  std_logic;
  WEB       : in  std_logic;
  key_in    : in  std_logic;
  mask_in   : in  std_logic;
  new_key   : in  std_logic;
  reg_full  : out std_logic;
  key       : out std_logic_vector (127 downto 0);
  key_mask  : out std_logic_vector (127 downto 0);
  IV        : out std_logic_vector (95 downto 0);
  IV_mask   : out std_logic_vector (95 downto 0);
  mask_ones : out unsigned (59 downto 0)
);
end component input_register;




signal key           : std_logic_vector (127 downto 0);
signal IV            : std_logic_vector (95 downto 0);
signal key_mask      : std_logic_vector (127 downto 0);
signal IV_mask       : std_logic_vector (95 downto 0);
signal key_masked    : std_logic_vector (127 downto 0);
signal IV_masked     : std_logic_vector (95 downto 0);
signal mask_ones     : unsigned (59 downto 0);
signal grain_stream  : std_logic_vector (GRAIN_STEP-1 downto 0);
signal grain_init    : std_logic;
signal grain_new_key : std_logic;
begin

  grain128a_top_i : grain128a_top
  port map (
    clk        => clk,
    rst        => rst,
    new_key    => grain_new_key,
    key        => key_masked,
    IV         => IV_masked,
    stream     => grain_stream,
    initial    => grain_init,
    lfsr_state => open,
    nfsr_state => open
  );


espresso_i: espresso_top
port map (
  clk => clk,
  rst => rst,
  new_key => new_key,
  key => key,
  IV => IV,
  keystream => espresso_out,
  current_state => open
  );

  input_register_i : input_register
  port map (
    clk       => clk,
    rst       => rst,
    WEB       => WEB,
    key_in    => key_in,
    mask_in   => mask_in,
    new_key   => new_key,
    reg_full  => reg_full,
    key       => key,
    key_mask  => key_mask,
    IV        => IV,
    IV_mask   => IV_mask,
    mask_ones => mask_ones
  );



MDM_top_i : MDM_top
port map (
  clk              => clk,
  rst              => rst,
  start            => start_attack,
  key_in           => key,
  IV_in            => IV,
  key_mask         => key_mask,
  IV_mask          => IV_mask,
  comb_counter_max => mask_ones,
  grain_in         => grain_stream,
  grain_init       => grain_init,
  signature_in     => (others => '0'),
  key_masked       => key_masked,
  IV_masked        => IV_masked,
  new_key          => grain_new_key,
  grain_signature  => open
);

grain128a_out <= grain_stream;

end architecture;
