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

entity KEYModule is
	Port ( 
		clk 		 : in  STD_LOGIC;
		Address		 : in  STD_LOGIC_VECTOR(4 downto 0);
		Input        : in  STD_LOGIC;
		en			 : in  STD_LOGIC;
		Rcon		 : in  STD_LOGIC;
		enInput		 : in  STD_LOGIC;
		enAddSbox    : in  STD_LOGIC;
		enAddRow1to3 : in  STD_LOGIC;
		enAddRow4    : in  STD_LOGIC;
		SboxInput	 : out STD_LOGIC;
		SboxOutput	 : in  STD_LOGIC;
		Output       : out STD_LOGIC);
end KEYModule;

architecture Behavioral of KEYModule is

	signal Row1i,  Row2i,  Row3i,  Row4i   : std_logic;
	signal Row1o,  Row2o,  Row3o,  Row4o   : std_logic;
	signal Row1mo, Row2mo, Row3mo, Row4mo  : std_logic;

	signal SelectedAdd, SerialSboxOut			: std_logic;
	
	signal SerialSboxOutXORRcon, OtherInput, Input2	: std_logic;
	signal invenInput : std_logic;
	
	
	attribute loc: string;
	
	attribute loc of KeyRegRow1 : 	label is "SLICE_X52Y54";
	attribute loc of LUT6_otherinput : label is "SLICE_X52Y54"; 
	attribute loc of LUT6_2_r3input : label is "SLICE_X52Y54"; 
	attribute loc of MUXF7_row4 : 	label is  "SLICE_X52Y54"; 
	
	attribute loc of LUT6_2_r12 : label is "SLICE_X52Y55";
	attribute loc of KeyRegRow2 : label is "SLICE_X52Y55";
	
	attribute loc of KeyRegRow3 : label is "SLICE_X52Y56";
	attribute loc of KeyRegRow4 : label is "SLICE_X52Y57";

begin

	KeyRegRow1 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row1mo,
		Q31 	=> Row1o,
		A 		=> Address,
		CE 	=> en,
		CLK 	=> clk,
		D 		=> Row1i);

	KeyRegRow2 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row2mo,
		Q31 	=> Row2o,
		A 		=> "00111",
		CE 	=> en,
		CLK 	=> clk,
		D 		=> Row2i);
		
	KeyRegRow3 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row3mo,
		Q31 	=> Row3o,
		A 		=> "00111",
		CE 	=> en,
		CLK 	=> clk,
		D 		=> Row3i);

	KeyRegRow4 : SRLC32E
	generic map (INIT => X"00000000")
	port map (
		Q 		=> Row4mo,
		Q31 	=> Row4o,
		A 		=> "00111",
		CE 	=> en,
		CLK 	=> clk,
		D 		=> Row4i);
	
	--------------------------------------------


	 LUT6_2_r12 : LUT6_2
    generic map (
    INIT => X"3c3ccccc5aaa5aaa") 
    port map (
        O6 => Row2i,
        O5 => Row1i,
        I0 => Row2o,
        I1 => Row3o,
        I2 => enAddRow1to3,
        I3 => Row1mo,
        I4 => Row2mo,
        I5 => '1'
    );

	   LUT6_otherinput : LUT6
        generic map (
        INIT => X"909fffff6f600000")
        port map (
        O => OtherInput,
        I0 => SboxOutput,
        I1 => Rcon,
        I2 => enAddSbox,
        I3 => Row4mo,
        I4 => enAddRow4,
        I5 => Row1o
    );
	 
 LUT6_2_r3input : LUT6_2
    generic map (
    INIT => X"ff00ff006a6a6a6a") 
    port map (
        O6 => Input2,
        O5 => Row3i,
        I0 => Row4o,
        I1 => enAddRow1to3,
        I2 => Row3mo,
        I3 => Input,
        I4 => '1',
        I5 => '1'
    );
	MUXF7_row4 : MUXF7
	port map (
		O => Row4i, 
		I0 => OtherInput,
		I1 => Input2, 
		S => enInput 
	);
	


	SboxInput 		<= Row2i;
	Output 			<= Row1mo;
		
end Behavioral;

