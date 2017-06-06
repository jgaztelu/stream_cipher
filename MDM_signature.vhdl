library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity MDM_signature is
	port (
		clk : in std_logic;
		rst : in std_logic;
		grain_in : in std_logic_vector (GRAIN_STEP-1 downto 0);
		grain_init : in std_logic;
		signature_in : in std_logic_vector (255 downto 0);
		load_signature : in std_logic;
		signature_valid : out std_logic;
		grain_signature : out std_logic_vector (255 downto 0)
		);
end entity;

architecture behavioural of MDM_signature is
type state_type is (idle,store,acc_sign);
signal current_state : state_type;
signal next_state : state_type;
signal shifted_in : std_logic_vector (255 downto 0);
signal shifted_in_next : std_logic_vector (255 downto 0);
signal prev_signature	: std_logic_vector (255 downto 0);
signal prev_signature_next : std_logic_vector (255 downto 0);

begin

process (clk,rst)
begin
	if rst = '1' then
		shifted_in <= (others => '0');
		prev_signature <= (others => '0');
		current_state <= idle;
	elsif clk'event and clk = '1' then
		shifted_in <= shifted_in_next;
		prev_signature <= prev_signature_next;
		current_state <= next_state;
	end if;
end process;

process (grain_in,grain_init,current_state,prev_signature,shifted_in,load_signature,signature_in)
begin

	-- Default assignations
	shifted_in_next <= shifted_in;
	prev_signature_next <= prev_signature;
	signature_valid <= '0';

	if load_signature = '1' then
		prev_signature_next <= signature_in;
    next_state <= idle;
	else
		case current_state is
			when idle =>
				shifted_in_next <= (others => '0');
				if grain_init = '1' then
					next_state <= store;
					--shifted_in_next <= grain_in & shifted_in (255 downto GRAIN_STEP);
					shifted_in_next <= shifted_in (255-GRAIN_STEP downto 0) & grain_in;  -- Avoid losing one bit in the transition
				else
					next_state <= idle;
				end if;

			when store =>
				--shifted_in_next <= grain_in & shifted_in (255 downto GRAIN_STEP);
				shifted_in_next <= shifted_in (255-GRAIN_STEP downto 0) & grain_in;
				if grain_init = '1' then
					next_state <= store;
				else
					next_state <= acc_sign;
          			prev_signature_next <= prev_signature xor shifted_in;
				end if;

			when acc_sign =>
				signature_valid <= '1';
				next_state <= idle;
		end case;
  end if;
end process;
grain_signature <= prev_signature;
end architecture;
