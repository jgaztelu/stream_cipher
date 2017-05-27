library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity keygen_tb is

end entity;

architecture arch of keygen_tb is
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
    key_masked       : out std_logic_vector (127 downto 0);
    IV_masked        : out std_logic_vector (95 downto 0);
    mask_ready       : out std_logic;
    comb_finished    : out std_logic
  );
  end component MDM_keygen;

signal clk              : std_logic;
signal rst              : std_logic;
signal key_in           : std_logic_vector (127 downto 0);
signal IV_in            : std_logic_vector (95 downto 0);
signal key_mask         : std_logic_vector (127 downto 0);
signal IV_mask          : std_logic_vector (95 downto 0);
signal comb_counter_max : unsigned (59 downto 0);
signal new_comb         : std_logic;
signal key_masked       : std_logic_vector (127 downto 0);
signal IV_masked        : std_logic_vector (95 downto 0);
signal mask_ready       : std_logic;
signal comb_finished    : std_logic;

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
  key_in <= (others => '0');
  IV_in <= (others => '0');
  key_mask <= (0 => '1', 2 => '1', others => '0');
  IV_mask <= (1 => '1', 3 => '1', others => '0');
  comb_counter_max <= (3 downto 0 => '1', others => '0');
  new_comb <= '0';
  wait for clk_period;
  rst <= '0';
  for I in 0 to 4 loop
    wait until mask_ready = '1';
    wait for clk_period;
    new_comb <= '1';
    wait for clk_period;
    new_comb <= '0';
    wait for clk_period;
  end loop;
  --wait until mask_ready = '1';
  wait;
end process;

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
  key_masked       => key_masked,
  IV_masked        => IV_masked,
  mask_ready       => mask_ready,
  comb_finished    => comb_finished
);

end architecture;
