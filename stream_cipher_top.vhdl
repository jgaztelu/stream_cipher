library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_top is
  port (
  clk : in std_logic;
  rst : in std_logic;
  new_key : in std_logic;
  data_in : in std_logic;
  WEB	  : in std_logic;
  reg_full : out std_logic;
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  espresso_out : out std_logic
   );
end entity;

architecture stream_cipher of stream_cipher_top is

component grain128a_top is
  port (
  clk     : in std_logic;
  rst     : in std_logic;
  new_key : in std_logic;
  key     : in std_logic_vector (127 downto 0);
  IV      : in std_logic_vector (95 downto 0);
  stream  : out std_logic_vector (GRAIN_STEP-1 downto 0);
  lfsr_state : out std_logic_vector (127 downto 0);
  nfsr_state : out std_logic_vector (127 downto 0)
  );
end component;

component espresso_top is
  port (
  clk : in std_logic;
  rst : in std_logic;
  new_key : in std_logic;
  key : in std_logic_vector (127 downto 0);
  IV  : in std_logic_vector (95 downto 0);
  keystream : out std_logic;
  current_state : out std_logic_vector (255 downto 0)
  );
end component;

component input_register is
  port (
  clk          : in std_logic;
  rst          : in std_logic;
  WEB          : in std_logic; -- Write enable
  data_in      : in std_logic;
  new_key	: in std_logic;
  reg_full	: out std_logic;
  key     	: out std_logic_vector (127 downto 0);
  IV		: out std_logic_vector(95 downto 0)
  );
end component;

signal key : std_logic_vector (127 downto 0);
signal IV : std_logic_vector (95 downto 0);
begin

grain128a_i: grain128a_top 
port map (
  clk => clk,
  rst => rst,
  new_key => new_key,
  key => key,
  IV => IV,
  stream => grain128a_out,
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

input_register_i: input_register
port map (
  clk => clk,
  rst => rst,
  WEB => WEB,
  data_in => data_in,
  new_key => new_key,
  reg_full => reg_full,
  key =>  key,
  IV => IV
  );

end architecture;

