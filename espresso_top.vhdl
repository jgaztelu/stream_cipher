library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity espresso_top is
  port (
  clk : in std_logic;
  rst : in std_logic;
  new_key : in std_logic;
  key : in std_logic_vector (127 downto 0);
  IV  : in std_logic_vector (95 downto 0);
  keystream : out std_logic
  );
end entity;

architecture arch of espresso_top is

-- Component declarations

component espresso_controller
port (
  clk      : in  std_logic;
  rst      : in  std_logic;
  new_key  : in  std_logic;
  init_FSR : out std_logic;
  init     : out std_logic
);
end component espresso_controller;


component espresso_datapath
port (
  clk       : in  std_logic;
  rst       : in  std_logic;
  init      : in  std_logic;
  init_FSR  : in  std_logic;
  key       : in  std_logic_vector (127 downto 0);
  IV        : in  std_logic_vector (95 downto 0);
  keystream : out std_logic
);
end component espresso_datapath;

signal init : std_logic;
signal init_FSR : std_logic;

begin

  espresso_controller_i : espresso_controller
  port map (
    clk      => clk,
    rst      => rst,
    new_key  => new_key,
    init_FSR => init_FSR,
    init     => init
  );


  espresso_datapath_i : espresso_datapath
  port map (
    clk       => clk,
    rst       => rst,
    init      => init,
    init_FSR  => init_FSR,
    key       => key,
    IV        => IV,
    keystream => keystream
  );

end architecture;
