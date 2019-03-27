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


-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY UNISIM;
USE UNISIM.VCOMPONENTS.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY Counter3 IS
	PORT ( CLK 	: IN  STD_LOGIC;
		   RST 	: IN  STD_LOGIC;
           EN  	: IN  STD_LOGIC;
           Q   	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
           Counter1B : OUT STD_LOGIC );
END Counter3;



-- ARCHITECTURE
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF Counter3 IS



-- SIGNALS
----------------------------------------------------------------------------------
SIGNAL CNT, NEWCNT : STD_LOGIC_VECTOR(2 DOWNTO 0);




-- STRUCTURAL
----------------------------------------------------------------------------------
BEGIN

	-- LUTS -----------------------------------------------------------------------
	LT0 : LUT6_2 GENERIC MAP (INIT => X"6666666655555555") PORT MAP (NEWCNT(0), NEWCNT(1), CNT(0), CNT(1), CNT(2), '0', '0', '1');
	LT1 : LUT6_2 GENERIC MAP (INIT => X"D8D8D8D878787878") PORT MAP (NEWCNT(2), Counter1B, CNT(0), CNT(1), CNT(2), '0', '0', '1');
	-------------------------------------------------------------------------------

	-- FLIP-FLOPS -----------------------------------------------------------------
	FF0 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(0), Q => CNT(0));
	FF1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(1), Q => CNT(1));
	FF2 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => EN, R => RST, D => NEWCNT(2), Q => CNT(2));
	-------------------------------------------------------------------------------
	
	-- COUNTER OUTPUT -------------------------------------------------------------
	Q <= CNT;

	-------------------------------------------------------------------------------
	
END Structural;