----------------------------------------------------------------------------------
-- COMPANY:   Ruhr University Bochum, Embedded Security & KU Leuven, COSIC
-- AUTHOR:    Felix Wegener, Lauren De Meyer, Amir Moradi
----------------------------------------------------------------------------------
-- Copyright (c) 2019, Felix Wegener, Lauren De Meyer, Amir Moradi
-- All rights reserved.

-- BSD-3-Clause License
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the copyright holder, their organization nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity sstar is
    Port ( x : in  STD_LOGIC_VECTOR (7 downto 0);
           y : out  STD_LOGIC);
end sstar;

architecture Behavioral of sstar is
	
    signal X1,X2,X3,X4,X5,X6,X7,X8, S00, S01, S10, S11, S0, S1, Y2 : std_logic;
begin

	X1 <= X(0);
	X2 <= X(1);
	X3 <= X(2);
	X4 <= X(3);
	X5 <= X(4);
	X6 <= X(5);
	X7 <= X(6);
	X8 <= X(7);
	
   LUT6_S_low : LUT6
        generic map (
        INIT => X"7a89e6246101fda8")
        port map (
        O =>  S00,
        I0 => X1,
        I1 => X2,
        I2 => X3,
        I3 => X4,
        I4 => X5,
        I5 => X6
	);

        LUT6_S_mlow : LUT6
        generic map (
        INIT => X"52ffee4fba60a784")
        port map (
        O =>  S01,
        I0 => X1,
        I1 => X2,
        I2 => X3,
        I3 => X4,
        I4 => X5,
        I5 => X6
	);

        LUT6_S_mhigh : LUT6
        generic map (
        INIT => X"4745c3b367d55c2b")
        port map (
        O =>  S10,
        I0 => X1,
        I1 => X2,
        I2 => X3,
        I3 => X4,
        I4 => X5,
        I5 => X6
	);

        LUT6_S_high : LUT6
        generic map (
        INIT => X"cb0f49b4c348acc8")
        port map (
        O =>  S11,
        I0 => X1,
        I1 => X2,
        I2 => X3,
        I3 => X4,
        I4 => X5,
        I5 => X6
	);
	
	MUXF7_l : MUXF7
port map (
	O => S0, 
	I0 => S00, 
	I1 => S01, 
	S => X7
);

MUXF7_h : MUXF7
port map (
	O => S1, 
	I0 => S10, 
	I1 => S11, 
	S => X7 
);

MUXF8_1 : MUXF8
port map (
	O => Y2, 
	I0 => S0, 
	I1 => S1, 
	S => X8 
);

Y <= Y2;

end Behavioral;

