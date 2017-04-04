library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity FSR is
  generic (
  r_WIDTH  : integer :=  128;
  r_STEP   : integer := 1;
  r_FWIDTH  : integer := 6
  );
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  feedback : in std_logic_vector ((r_STEP-1) downto 0);
  init     : in std_logic;
  ini_data : in std_logic_vector ((r_WIDTH-1) downto 0);
  out_data : out std_logic_vector ((r_STEP-1) downto 0);
  fb_out   : out std_logic_vector ((r_FWIDTH-1) downto 0)
  );
end entity;

architecture behavioural of FSR is
signal shifted,shifted_next  : std_logic_vector((r_WIDTH-1) downto 0);
begin
process(clk,rst)
begin
if rst = '1' then
  shifted <= (others => '0');
elsif clk'event and clk = '1' then
  shifted <= shifted_next;
end if;
end process;

process (feedback,init,ini_data)
begin
  if init = '1' then
    shifted_next <= ini_data;
  else
    shifted_next <= shifted((r_WIDTH-r_STEP-1) downto 0) & feedback;
  end if;
end process;
out_data <= shifted ((r_WIDTH-1) downto (r_WIDTH-r_STEP-1));

gen_feedback: for I in r_FWIDTH to 0 generate
  fb_out(I) <= shifted (I);
end generate gen_feedback;

end architecture;
