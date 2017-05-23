library ieee;
  	use ieee.std_logic_1164.all;
  	use ieee.numeric_std.all;
	use work.fsr_taps_type.all;

entity MDM is
	port (
	clk : in std_logic;
	rst : in std_logic;
	grain_in : in std_logic_vector (GRAIN_STEP-1 downto 0);
	signature : out std_logic_vector (255 downto 0)
	);
end entity;

architecture behavioural of MDM is

signal current_signature, current_signature_next : std_logic_vector (255 downto 0);
signal acc_signature, acc_signature_next	:	std_logic_vector (255 downto 0);
begin

process (clk,rst)
begin
	if rst = '1' then
		current_signature <= (others => '0');
		acc_signature <= (others => '0');
	elsif clk'event and clk = '1' then
		current_signature <= current_signature_next;
		acc_signature <= acc_signature_next;
	end if;
end process;

process (grain_in,
