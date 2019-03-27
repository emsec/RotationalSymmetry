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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity STATEModule is
	Port ( 
		clk 		: in  STD_LOGIC;
		Address		: in  STD_LOGIC_VECTOR(4 downto 0);
		Input       : in  STD_LOGIC;
		Row1en		: in  STD_LOGIC;
		Row2en		: in  STD_LOGIC;
		Row3en		: in  STD_LOGIC;
		Row4en		: in  STD_LOGIC;
		enSaveMSB	: in  STD_LOGIC;
		enMC		: in  STD_LOGIC;
		enInput		: in  STD_LOGIC;	
		enSR		: in  STD_LOGIC;
		MClastBit	: in  STD_LOGIC;
		PolyBit		: in  STD_LOGIC;
		SboxOutput	: in  STD_LOGIC;
		Output      : out STD_LOGIC);
end STATEModule;

architecture Behavioral of STATEModule is
	
	signal Row1i, Row2i, Row3i, Row4i    		: std_logic;
	signal Row1o,  Row2o,  Row3o,  Row4o  		: std_logic_vector(1 downto 0);

	signal MC1, MC2, MC3, MC4     				: STD_LOGIC;
	signal Row1x1, Row1x2, Row1x3 				: STD_LOGIC;
	signal Row2x1, Row2x2, Row2x3 				: STD_LOGIC;
	signal Row3x1, Row3x2, Row3x3 				: STD_LOGIC;
	signal Row4x1, Row4x2, Row4x3 				: STD_LOGIC;
	signal Row1MSB, Row2MSB, Row3MSB, Row4MSB : STD_LOGIC;
	
	signal MSBReg, MSBtoSave						: STD_LOGIC_VECTOR(3 downto 0);
	
	signal mid1_1, mid1_2, mid2, mid3, mid4	: STD_LOGIC;
	signal Row4i0									   : STD_LOGIC;
	
	attribute loc : string;

	attribute loc of LUT6_mc4 : label is "SLICE_X52Y56";
	attribute loc of LUT6_mc1 : label is "SLICE_X52Y59"; 
	attribute loc of LUT6_mid3 : label is "SLICE_X50Y58"; 
	

	attribute loc of LUT6_row4i : label is "SLICE_X52Y57";
	attribute loc of LUT6_row3i : label is "SLICE_X52Y61"; 
	attribute loc of LUT6_row2i : label is "SLICE_X52Y60"; 
	
	attribute loc of Row1 : label is "SLICE_X52Y58";
	attribute loc of MSBREGinst_0 : label is "SLICE_X52Y58";
	attribute loc of LUT6_mc2mc3 : label is "SLICE_X52Y58";
	attribute loc of LUT6_2_mid12mid4 : label is "SLICE_X52Y58";
	
	attribute loc of Row2 : label is "SLICE_X52Y59";
	attribute loc of MSBREGinst_1 : label is "SLICE_X52Y59";
	attribute loc of LUT6_2_mid11mid2 : label is "SLICE_X52Y59";
	attribute loc of LUT6_2_1i4i : label is "SLICE_X52Y59";
	
	attribute loc of Row3 : label is "SLICE_X52Y60";
	attribute loc of MSBREGinst_2 : label is "SLICE_X52Y60";
	
	attribute loc of Row4 : label is "SLICE_X52Y61";
	attribute loc of MSBREGinst_3 : label is "SLICE_X52Y61";

begin

	Row1 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row1o(0),
		Q31 	=> Row1o(1),
		A 		=> Address,
		CE 	=> Row1en,
		CLK 	=> clk,
		D 		=> Row1i);		
		
	Row2 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row2o(0),
		Q31 	=> Row2o(1),
		A 		=> "11110",
		CE 	=> Row2en,
		CLK 	=> clk,
		D 		=> Row2i);		
		
	Row3 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row3o(0),
		Q31 	=> Row3o(1),
		A 		=> "11110",
		CE 	=> Row3en,
		CLK 	=> clk,
		D 		=> Row3i);		

	Row4 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row4o(0),
		Q31 	=> Row4o(1),
		A 		=> "11110",
		CE 	=> Row4en,
		CLK 	=> clk,
		D 		=> Row4i);		
		
	--------------------------------------------
		
	Row1MSB 		<= MSBReg(0);
	Row2MSB 		<= MSBReg(1);
	Row3MSB 		<= MSBReg(2);
	Row4MSB 		<= MSBReg(3);
	
	MSBtoSave(0) <= Row1o(1);
	MSBtoSave(1) <= Row2o(1);
	MSBtoSave(2) <= Row3o(1);
	MSBtoSave(3) <= Row4o(1);
	
	------
		
	MSBREGinst_0 : FDRE generic map (INIT => '0') port map (Q => MSBReg(0),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(0));
	MSBREGinst_1 : FDRE generic map (INIT => '0') port map (Q => MSBReg(1),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(1));
	MSBREGinst_2 : FDRE generic map (INIT => '0') port map (Q => MSBReg(2),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(2));
	MSBREGinst_3 : FDRE generic map (INIT => '0') port map (Q => MSBReg(3),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(3));
	
	--------------------------------------------
			

	-- Row1i 		<= MC1 when enMC = '1' else Row2o(1);
	-- Row4i		<= MC4 when enMC = '1' else Row4i0;	
    LUT6_2_1i4i : LUT6_2
    generic map (
    INIT => X"ff33cc00b8b8b8b8") 
    port map (
        O6 => Row4i,
        O5 => Row1i,
       I0 => MC1,
        I1 => enMC,
       I2 => Row2o(1),
        I3 => MC4,
        I4 => Row4i0,
        I5 => '1'
   );

	-- Row2i 		<= MC2 when enMC = '1' else Row3o(1) when enSR = '0' else Row2o(1);
	    LUT6_row2i : LUT6
        generic map (
        INIT => X"bbb888b8bbb888b8")
        port map (
        O => Row2i,
        I0 => MC2,
        I1 => enMC,
        I2 => Row3o(1),
        I3 => enSR,
        I4 => Row2o(1),
        I5 => '1'
    );

	--Row3i 		<= MC3 when enMC = '1' else Row4o(1) when enSR = '0' else Row3o(1);
		 LUT6_row3i : LUT6
        generic map (
        INIT => X"bbb888b8bbb888b8")
        port map (
        O => Row3i,
        I0 => MC3,
        I1 => enMC,
        I2 => Row4o(1),
        I3 => enSR,
        I4 => Row3o(1),
        I5 => '1'
    );

	--Row4i0 		<= Input when enInput = '1' else Row4o(1) when enSR = '1' else SboxOutput;
	LUT6_row4i : LUT6
        generic map (
        INIT => X"bbb888b8bbb888b8")
        port map (
        O => Row4i0,
        I0 => Input,
        I1 => enInput,
        I2 => SboxOutput,
        I3 => enSR,
        I4 => Row4o(1),
        I5 => '1'
    );

	--------------------------------------------

	Row1x1 <= Row1o(1);
	Row2x1 <= Row2o(1);
	Row3x1 <= Row3o(1);
	Row4x1 <= Row4o(1);

	--mid1_1  	<= (Row1MSB NAND PolyBit);
	--mid2		<= (Row2o(0) NAND MClastBit) XOR (Row2MSB NAND PolyBit) ;
	LUT6_2_mid11mid2 : LUT6_2
    generic map (
    INIT => X"3cccf00077777777") 
    port map (
        O6 => mid2,
        O5 => mid1_1,
        I0 => Row1MSB,
        I1 => PolyBit,
        I2 => Row2o(0),
        I3 => MClastBit,
        I4 => Row2MSB,
        I5 => '1'
    );

	--mid3		<= Row1x1 XOR  Row4x1 XOR (Row3o(0) NAND MClastBit) XOR (Row3MSB NAND PolyBit);
	    LUT6_mid3 : LUT6
        generic map (
        INIT => X"6999966696669666")
        port map (
        O => mid3,
        I0 => Row1x1,
        I1 => Row4x1,
        I2 => Row3o(0),
        I3 => MClastBit,
        I4 => Row3MSB,
        I5 => PolyBit
    );

	--mid1_2	<= (Row1o(0) NAND MClastBit);
	--mid4		<=	(Row4o(0) NAND MClastBit) XOR (Row4MSB NAND PolyBit);
	 LUT6_2_mid12mid4 : LUT6_2
    generic map (
    INIT => X"3fc0c0c077777777") 
    port map (
        O6 => mid4,
        O5 => mid1_2,
        I0 => Row1o(0),
        I1 => MClastBit,
        I2 => Row4o(0),
        I3 => Row4MSB,
        I4 => PolyBit,
        I5 => '1'
    );
	
	--MC1 	<= Row2x1 XOR  Row4x1 XOR Row3x1 XOR mid1_1 xor mid1_2 xOR mid2;
	    LUT6_mc1 : LUT6
        generic map (
        INIT => X"6996966996696996")
        port map (
        O => MC1,
        I0 => Row2x1,
        I1 => Row4x1,
        I2 => Row3x1,
        I3 => mid1_1,
        I4 => mid1_2,
        I5 => mid2
    );

	--MC2 <= Row3x1 XOR mid2 xor mid3;
	--MC3 <= Row2x1 XOR mid3 xor mid4;  
	 LUT6_mc2mc3 : LUT6_2
    generic map (
    INIT => X"f00f0ff096969696") 
    port map (
        O6 => MC3,
        O5 => MC2,
        I0 => Row3x1,
        I1 => mid2,
        I2 => mid3,
        I3 => Row2x1,
        I4 => mid4,
        I5 => '1'
    );
	
	--MC4 <= Row1x1 XOR Row2x1 XOR Row3x1 XOR mid4 xor mid1_1 xor mid1_2;
	   LUT6_mc4 : LUT6
      generic map (
      INIT => X"6996966996696996")
      port map (
        O => MC4,
        I0 => Row1x1,
        I1 => Row2x1,
        I2 => Row3x1,
        I3 => mid4,
        I4 => mid1_1,
        I5 => mid1_2
    );

	--------------------------------------------

	Output <= Row1o(0);
		
end Behavioral;

