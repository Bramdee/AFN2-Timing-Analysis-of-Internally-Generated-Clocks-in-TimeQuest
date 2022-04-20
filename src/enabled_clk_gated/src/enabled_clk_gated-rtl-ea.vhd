-- This file shows how to use the ALTCLKCTRL IP as Enabeld Clock
-- This code also implements an experiment: Can an Enabled Clock be inferenced using VHDL description?

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library EnabledClk;


entity enabled_clk_gated is
	port (
        iClk			: in std_ulogic;
        inResetAsync    : in std_ulogic;
		
		iEn				: in std_ulogic; -- Clock enable
		oClkEn			: out std_ulogic; -- Enabled Clock
		
		iD				: in std_ulogic;
		oQ				: out std_ulogic
        );



end entity;

architecture rtl of enabled_clk_gated is
	signal GateFF, DstFF 	: std_ulogic;
	signal VHDLClkEn			: std_ulogic;

	
begin
	
	-- Instantiation of a ALTCLKCCTRL IP
	TheEnabledClk0 : entity EnabledClk.EnabledClk
    port map (
		inclk 	=> iClk,
		ena   	=> iEn,
	    outclk	=> oClkEn);
		
	-- Experiment: Will this Code cause Clock-Enable inference? 
	-- Note:  Synchrononous method using AND gate; Common circuit for enabling/disabling clocks.
	-- Note : TheEnabledClk0 needs to be commented. Otherwise this description will be removed by the synthesis. Reason? I don't know...
	TheGateFF : process(iClk, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			GateFF <= '0';
		elsif falling_edge(iClk) then
			GateFF <= iEn;
		end if;
	end process;
	
	VHDLClkEn <= GateFF and iClk;
	
	TheDstFF: process(VHDLClkEn, inResetAsync) is
	begin
		if inResetAsync = not('1') then
			DstFF <= '0';
		elsif rising_edge(VHDLClkEn) then
			DstFF <= iD;
		end if;
	end process;
	
	oQ <= DstFF;
	
		
end architecture;