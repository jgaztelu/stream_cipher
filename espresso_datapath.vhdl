library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_datapath is
  port (
  clk       : in std_logic;
  rst       : in std_logic;
  init      : in std_logic;
  init_FSR  : in std_logic;
  key       : in std_logic_vector (127 downto 0);
  IV        : in std_logic_vector (95 downto 0);
  keystream : out std_logic
  );
end entity;

architecture arch of espresso_datapath is

--Component declarations
  component espresso_FSR
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    init_FSR : in  std_logic;
    init     : in  std_logic;
    ini_data : in  std_logic_vector (255 downto 0);
    z_in     : in  std_logic;
    z_out    : out std_logic_vector (25 downto 0);
    out_data : out std_logic
  );
  end component espresso_FSR;

  component espresso_z
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    z_in  : in  std_logic_vector (25 downto 0);
    z_out : out std_logic
  );
  end component espresso_z;

signal z_bits  : std_logic_vector (25 downto 0);
signal z_result   : std_logic;
begin
  espresso_FSR_i : espresso_FSR
  port map (
    clk      => clk,
    rst      => rst,
    init_FSR => init_FSR,
    init     => init,
    ini_data (127 downto 0) => key,
    ini_data (223 downto 128) => IV,
    ini_data (254 downto 224) => (others => '1'),
    ini_data (255) =>   '0',
    z_in     => z_result,
    z_out    => z_bits,
    out_data => open
  );

  espresso_z_i : espresso_z
  port map (
    clk   => clk,
    rst   => rst,
    z_in  => z_bits,
    z_out => z_result
  );

keystream <= z_result;

end architecture;
