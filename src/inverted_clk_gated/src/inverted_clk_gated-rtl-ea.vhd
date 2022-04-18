-- testing inverted clk.
-- will it instantiate a NOT gate or will it use the inverted clk input of FF?

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity inverted_clk_gated is
	port (
        iClk             : in std_ulogic;
        inResetAsync     : in std_ulogic;

        iA               : in std_ulogic;
        oQa              : out std_ulogic;

        iB               : in std_ulogic;
        oQb              : out std_ulogic;
        
        iC               : in std_ulogic;
        oQc              : out std_ulogic);



end entity;

architecture rtl of inverted_clk_gated is
    signal sigA, sigB, sigC   : std_ulogic;
    signal Qa, Qb, Qc       	: std_ulogic;
    signal nClk         		: std_ulogic;
begin

    -- Experiment 1: Will the usage of the "not" statement instantiate a NOT gate?
    -- Spoiler: No, it doesn't. Inverted Clk input of DFF is used.
    nClk <= not iClk; -- gated Clk

    DFF_A : process (iClk, nClk, inResetAsync) is
    begin
        if inResetAsync = not('1') then
            sigA    <= '0';
            Qa      <= '0';
        elsif rising_edge(iClk) then
            sigA    <= iA;
            Qa      <= Qa;
        elsif rising_edge(nClk) then
            sigA    <= sigA;
            Qa      <= sigA;
        end if;
    end process; 
    oQa <= Qa;


    -- Experiment 2: Will the usage of the "not(rising_edge())" statement instantiate a NOT gate?
    -- Spoiler: No, it doesn't. Inverted Clk input of DFF is used.
    DFF_B : process (iClk, inResetAsync) is
        begin
            if inResetAsync = not('1') then
                sigB    <= '0';
                Qb      <= '0';
            elsif rising_edge(iClk) then
                sigB    <= iB;
                Qb      <= Qb;
            elsif not(rising_edge(iClk)) then
                sigB    <= sigB;
                Qb      <= sigB;
            end if;
        end process; 
        oQb <= Qb;



    -- Experiment 3: Will the usage of the "falling_edge()" statement make use of the inverted clk input of DFF?
    -- Spoiler: Yes it does. Inverted Clk input of DFF is used.
    DFF_C : process (iClk, inResetAsync) is
        begin
            if inResetAsync = not('1') then
                sigC    <= '0';
                Qc      <= '0';
            elsif rising_edge(iClk) then
                sigC    <= iC;
                Qc      <= Qc;
            elsif falling_edge(iClk) then
                sigC    <= sigC;
                Qc      <= sigC;
            end if;
        end process; 
        oQc <= Qc;


    -- Result: 
    -- It doesn't matter which one you chose. The synthesis uses the more efficient way:
    -- Inverted Clk input of DFF.
    -- Using a LUT would unnecessarily waste chip area and would cause clk skew would have to be dealt with.

end architecture;