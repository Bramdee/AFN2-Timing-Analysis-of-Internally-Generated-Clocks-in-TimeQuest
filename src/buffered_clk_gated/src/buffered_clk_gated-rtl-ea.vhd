-- Testing clk from regular I/O input and clk from dedicated clock input
-- Will buffered clock have worse timing?
-- This design uses the *.qsf and *.sdc of the Terasic DE1-SoC Board

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity buffered_clk_gated is
    generic (
        gBits            : natural := 512
    );
	port (
        CLOCK_50        : in std_ulogic;
        GPIO_0_0        : in std_ulogic;
        inResetAsync    : in std_ulogic;

        oStrobe0        : out std_ulogic;
        oStrobe1        : out std_ulogic
        );



end entity;

architecture rtl of buffered_clk_gated is
    signal reg0, reg1 : std_ulogic_vector(gBits-1 downto 0);
    constant cMaxVal : std_ulogic_vector(gBits-1 downto 0) := (others => '1');

    -- tell the quartus to not optimize (=remove) the registers
    attribute preserve: boolean; 
    attribute preserve of reg0: signal is true;
    attribute preserve of reg1: signal is true;
begin

    -- 255 registers which are clocked by dedicated clock input
    Regular: process (CLOCK_50, inResetAsync) is
    begin
        if inResetAsync = not('1') then
            reg0 <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            reg0 <= not(reg0);

            -- this is only need becauce the synthesis removes
            -- all registers if they aren't used for output
            if reg0 = cMaxVal then
                oStrobe0 <= '1';
            else
                oStrobe0 <= '0';
            end if;
        end if;
    end process;

    -- 255 registers which are clocked by GPIO input (I/O buffer)
    Buffered: process (GPIO_0_0, inResetAsync) is
    begin
        if inResetAsync = not('1') then
            reg1 <= (others => '0');
        elsif rising_edge(GPIO_0_0) then
            reg1 <= not(reg1);

            -- this is only need becauce the synthesis removes
            -- all registers if they aren't used for output
            if reg1 = cMaxVal then
                oStrobe1 <= '1';
            else
                oStrobe1 <= '0';
            end if;
        end if;
    end process;

end architecture;