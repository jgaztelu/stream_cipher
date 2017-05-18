library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity grain128a_top_p is
  port (
  clk     : in std_logic;
  rst     : in std_logic;
  new_key : in std_logic;
  key     : in std_logic_vector (127 downto 0);
  IV      : in std_logic_vector (95 downto 0);
  stream  : out std_logic_vector (GRAIN_STEP-1 downto 0);
  );
end entity;

architecture grain128a_top_p of grain128a_top_p is

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

component CPAD_S_74x50u_IN --input PAD

port (
COREIO : out std_logic;
PADIO : in std_logic);
end component;

component CPAD_S_74x50u_OUT --output PAD
port (
COREIO : in std_logic;
PADIO : out std_logic);
end component; 

signal clk_i : std_logic;
signal rst_i : std_logic;
signal new_key_i : std_logic;
signal key_i : std_logic_vector(127 downto 0);
signal IV_i : std_logic_vector (95 downto 0);
signal stream_i : std_logic_vector (GRAIN_STEP-1 downto 0);
signal lfsr_state_i : std_logic_vector (127 downto 0);
signal nfsr_state_i : std_logic_vector (127 downto 0);

begin

ClkPad : CPAD_S_74x50u_IN
  port map (COREIO => clk_i, PADIO => clk);

RstPad : CPAD_S_74x50u_IN
  port map (COREIO => rst_i, PADIO => rst);

NewKeyPad : CPAD_S_74x50u_IN
  port map (COREIO => new_key_i, PADIO => new_key);

KeyPads : for I in 0 to 127 generate
 KeyPad : CPAD_S_74x50u_IN
  port map (COREIO => key_i(I), PADIO => key(I));
end generate;

IVPads : for I in 0 to 95 generate
 KeyPad : CPAD_S_74x50u_IN
  port map (COREIO => IV_i(I), PADIO => IV(I));
end generate;

streamPads : for I in 0 to (GRAIN_STEP-1) generate
  streamPad : CPAD_S_74x50u_OUT
  port map (COREIO => stream_i(I), PADIO => stream(I));
end generate;



--lfsrPads : for I in 0 to 127 generate
  --lfsr_statePad : CPAD_S_74x50u_OUT
  --port map (COREIO => lfsr_state_i(I), PADIO => lfsr_state(I));
--end generate;

--nfsrPads : for I in 0 to 127 generate
  --nfsr_statePad : CPAD_S_74x50u_OUT
  --port map (COREIO => nfsr_state_i(I), PADIO => nfsr_state(I));
--end generate;

grain128a_top_i: grain128a_top
port map (
	clk => clk_i,
	rst => rst_i,
	new_key => new_key_i,
	key => key_i,
	IV => IV_i,
	stream => stream_i,
	lfsr_state => open,
	nfsr_state => open
	);

end architecture;

