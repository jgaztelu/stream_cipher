library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity output_register is
	port (
		clk	: in std_logic;
		rst : in std_logic;
		attack_finished : in std_logic;
		REN	: in std_logic;
		signature_in :	in std_logic_vector(255 downto 0);
		signature_out : out std_logic_vector (7 downto 0)
		);
end entity;

architecture behavioural of output_register is
signal input,input_next	:	std_logic_vector (255 downto 0);


begin

process (clk,rst)
begin
	if rst = '1' then
		input <= (others => '0');
	elsif clk='1' and clk'event then
		input <= input_next;
	end if;
end process;

process (attack_finished,REN,signature_in,input)
begin
input_next <= input;

	if attack_finished = '1' then
		input_next <= signature_in;
	elsif REN = '1' then
		input_next <= "00000000" & input(255 downto 8);
	end if;
end process;
signature_out <= input (7 downto 0);
end architecture;
		



