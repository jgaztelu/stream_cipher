library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;
entity keygen_tb is

end entity;

architecture arch of keygen_tb is
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


signal clk              : std_logic;
signal rst              : std_logic;
signal start            : std_logic;
signal key_in           : std_logic_vector (127 downto 0);
signal IV_in            : std_logic_vector (95 downto 0);
signal key_mask         : std_logic_vector (127 downto 0);
signal IV_mask          : std_logic_vector (95 downto 0);
signal comb_counter_max : unsigned (59 downto 0);
signal grain_in         : std_logic_vector (GRAIN_STEP-1 downto 0);
signal grain_init       : std_logic;
signal signature_in     : std_logic_vector (255 downto 0);
--signal new_comb         : std_logic;
signal key_masked       : std_logic_vector (127 downto 0);
signal IV_masked        : std_logic_vector (95 downto 0);
signal new_key          : std_logic;
signal grain_signature  : std_logic_vector (255 downto 0);



constant clk_period : time  := 10 ns;

begin

clk_proc : process
begin
  clk <= '1';
  wait for clk_period/2;
  clk <= '0';
  wait for clk_period/2;
end process;

stim_proc : process
begin
  rst <= '1';
  start <= '0';
  key_in <= (others => '0');
  IV_in <= (others => '0');
  key_mask <= (0 => '1', 2 => '1', others => '0');
  IV_mask <= (1 => '1', 3 => '1', others => '0');
  comb_counter_max <= (3 downto 0 => '1', others => '0');
  grain_in <= "0";
  grain_init <= '0';
  wait for clk_period;
  rst <= '0';
  start <= '1';
  wait for clk_period;
  start <= '0';
  grain_init <= '1';
  wait;
end process;

MDM_top_i : MDM_top
port map (
  clk              => clk,
  rst              => rst,
  start            => start,
  key_in           => key_in,
  IV_in            => IV_in,
  key_mask         => key_mask,
  IV_mask          => IV_mask,
  comb_counter_max => comb_counter_max,
  grain_in         => grain_in,
  grain_init       => grain_init,
  signature_in     => signature_in,
  key_masked       => key_masked,
  IV_masked        => IV_masked,
  new_key          => new_key,
  grain_signature  => grain_signature
);


end architecture;
