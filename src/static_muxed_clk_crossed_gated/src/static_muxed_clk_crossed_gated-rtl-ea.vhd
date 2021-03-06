-- A design using a static Multiplexed Clock using the ALTCLKCTRL Hard-IP
-- This design contains clock crossing between a "normal" clock and a Multiplexed Clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library MuxedClock;


entity static_muxed_clk_crossed_gated is
	port (
        iClkA			: in std_ulogic;
		iClkB			: in std_ulogic;
        inResetAsync    : in std_ulogic;
		
		iClkSel			: in std_ulogic;  -- '0' = iClkA; '1' = iClkB
		
		iDa				: in std_ulogic;
		iDb				: in std_ulogic;
		oQab			: out std_ulogic;
		oQb				: out std_ulogic);

end entity;

architecture rtl of static_muxed_clk_crossed_gated is
	signal Ra, Rb1, Rb2, Rab	: std_ulogic;
	signal ClkEn				: std_ulogic;

	
begin
	
	-- Instantiation of a ALTCLKCCTRL IP
	TheMuxedClk0 : entity MuxedClock.MuxedClock
    port map (
		inclk1x 	=> iClkA,
		inclk0x		=> iClkB,
		clkselect   => iClkSel,
	    outclk		=> ClkEn);


	RegA : process(iClkA, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			Ra <= '0';
		elsif rising_edge(iClkA) then
			Ra <= iDa;
		end if;
	end process;

	RegB1 : process(ClkEn, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			Rb1 <= '0';
		elsif rising_edge(ClkEn) then
			Rb1 <= iDb;
		end if;
	end process;

	RegB2 : process(ClkEn, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			Rb2 <= '0';
		elsif rising_edge(ClkEn) then
			Rb2 <= Rb1;
		end if;
	end process;

	RegAB : process(ClkEn, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			Rab <= '0';
		elsif rising_edge(ClkEn) then
			Rab <= Ra and Rb1;
		end if;
	end process;

	oQab 	<= Rab;
	oQb		<= Rb2;
	
		
end architecture;