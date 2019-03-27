----------------------------------------------------------------------------------
-- COMPANY:		Ruhr University Bochum, Embedded Security & KU Leuven, COSIC
-- AUTHOR:		Felix Wegener, Lauren De Meyer, Amir Moradi
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

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Rcon_counter is
	port(
		CLK		: in  std_logic;
		RST   	: in  std_logic;
		EN    	: in  std_logic;
		STATE2 	: in std_logic;
		Q		: out std_logic_vector(7 downto 0);
		Rcon	: out std_logic);

end entity Rcon_counter;

architecture dfl of Rcon_counter  is

	SIGNAL CNT, NEWCNT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	attribute loc: string;
	attribute loc of FF0 : label is "SLICE_X50Y56";
	attribute loc of FF1 : label is "SLICE_X50Y58";
	attribute loc of FF2 : label is "SLICE_X50Y58";
	attribute loc of FF3 : label is "SLICE_X50Y58";
	attribute loc of FF4 : label is "SLICE_X50Y58";
	attribute loc of FF5 : label is "SLICE_X50Y58";
	attribute loc of FF6 : label is "SLICE_X50Y58";
	attribute loc of FF7 : label is "SLICE_X50Y58";
	attribute loc of LUT0 : label is "SLICE_X50Y58";
	attribute loc of LUT1 : label is "SLICE_X50Y58";
	
begin
	
	
	FF0 : FDSE GENERIC MAP (INIT => '1') PORT MAP (C => CLK, CE => EN, S => RST, D => NEWCNT(0), Q => CNT(0));
	FF1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(1), Q => CNT(1));
	FF2 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(2), Q => CNT(2));	
	FF3 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(3), Q => CNT(3));
	FF4 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(4), Q => CNT(4));
	FF5 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(5), Q => CNT(5));
	FF6 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(6), Q => CNT(6));
	FF7 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(7), Q => CNT(7));
	
	NEWCNT(0) <= CNT(7);
	NEWCNT(2) <= CNT(1);
	NEWCNT(5) <= CNT(4);
	NEWCNT(6) <= CNT(5);
	NEWCNT(7) <= CNT(6);
	

	LUT0 : LUT6_2 GENERIC MAP (INIT => X"CC3C3C3CAA5A5A5A") PORT MAP(NEWCNT(1),NEWCNT(3), CNT(0), CNT(2), CNT(7), EN, STATE2, '1');

	LUT1 : LUT6_2 GENERIC MAP (INIT => X"F0000000AA5A5A5A") PORT MAP(NEWCNT(4), Rcon, CNT(3), '0', CNT(7), EN, STATE2, '1');

	
	Q <= CNT;
	
end architecture dfl;
