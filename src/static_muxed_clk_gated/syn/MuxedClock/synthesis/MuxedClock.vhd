-- MuxedClock.vhd

-- Generated using ACDS version 21.1 842

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MuxedClock is
	port (
		inclk1x   : in  std_logic := '0'; --  altclkctrl_input.inclk1x
		inclk0x   : in  std_logic := '0'; --                  .inclk0x
		clkselect : in  std_logic := '0'; --                  .clkselect
		outclk    : out std_logic         -- altclkctrl_output.outclk
	);
end entity MuxedClock;

architecture rtl of MuxedClock is
	component MuxedClock_altclkctrl_0 is
		port (
			inclk1x   : in  std_logic := 'X'; -- inclk1x
			inclk0x   : in  std_logic := 'X'; -- inclk0x
			clkselect : in  std_logic := 'X'; -- clkselect
			outclk    : out std_logic         -- outclk
		);
	end component MuxedClock_altclkctrl_0;

begin

	altclkctrl_0 : component MuxedClock_altclkctrl_0
		port map (
			inclk1x   => inclk1x,   --  altclkctrl_input.inclk1x
			inclk0x   => inclk0x,   --                  .inclk0x
			clkselect => clkselect, --                  .clkselect
			outclk    => outclk     -- altclkctrl_output.outclk
		);

end architecture rtl; -- of MuxedClock
