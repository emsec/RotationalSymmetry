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

entity BitSerialAESENC is
	Port ( 
		clk 			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		Plaintext   : in  STD_LOGIC;
		Key         : in  STD_LOGIC;
		Ciphertext  : out STD_LOGIC;
		Done  		: out STD_LOGIC);
end BitSerialAESENC;

architecture Behavioral of BitSerialAESENC is

	signal Address				:  STD_LOGIC_VECTOR(4 downto 0);

	signal STATEenRow1      :  STD_LOGIC;
	signal STATEenRow2      :  STD_LOGIC;
	signal STATEenRow3      :  STD_LOGIC;
	signal STATEenRow4      :  STD_LOGIC;
	
	signal STATEenMC		 	:  STD_LOGIC;
	signal STATEenInput	 	:  STD_LOGIC;	
	signal STATEenSR		 	:  STD_LOGIC;
	signal STATEenSaveMSB  	:  STD_LOGIC;
	signal STATEMClastBit	:  STD_LOGIC;
	signal STATEPolyBit	 	:  STD_LOGIC;
			
	signal KEYen				:  STD_LOGIC;
	signal KEYRcon			 	:  STD_LOGIC;
	signal KEYenInput		 	:  STD_LOGIC;
	signal KEYenAddSbox     :  STD_LOGIC;
	signal KEYenAddRow1to3 	:  STD_LOGIC;
	signal KEYenAddRow4    	:  STD_LOGIC;

	signal Sbox_Shift_en		:  STD_LOGIC;
	signal SboxSel			 	:  STD_LOGIC;	
	signal Sbox_s0			 	:  STD_LOGIC;	
	signal Sbox_s1			 	:  STD_LOGIC;	

	signal STATEoutput		:  STD_LOGIC;
	signal RoundKey			:  STD_LOGIC;
	
	signal KEYSboxInput 		:  STD_LOGIC;

	signal SboxInputMux  	:  STD_LOGIC;
	signal STATESboxOutput	:  STD_LOGIC;
	signal KEYSboxOutput		:  STD_LOGIC;
	signal rotReg7				:  STD_LOGIC;
	
	attribute loc: string;
	
	
begin

	ControllerInst: entity work.controller
	Port Map(
		clk 				 => clk,
		reset				 => reset,
		Address			 => Address,

		STATEenRow1		 => STATEenRow1,
		STATEenRow2		 => STATEenRow2,
		STATEenRow3		 => STATEenRow3,
		STATEenRow4		 => STATEenRow4,
		STATEenMC		 => STATEenMC,
		STATEenInput	 => STATEenInput,
		STATEenSR		 => STATEenSR,
		STATEenSaveMSB  => STATEenSaveMSB,
		STATEMClastBit	 => STATEMClastBit,
		STATEPolyBit	 => STATEPolyBit,

		KEYen				 => KEYen,
		KEYRcon			 => KEYRcon,
		KEYenInput		 => KEYenInput,
		KEYenAddSbox    => KEYenAddSbox,
		KEYenAddRow1to3 => KEYenAddRow1to3,
		KEYenAddRow4    => KEYenAddRow4,

		Sbox_Shift_en	 => Sbox_Shift_en,
		SboxSel			 => SboxSel,
		Sbox_s0			 => Sbox_s0,
		Sbox_s1			 => Sbox_s1,

		Done				 => Done);		

	STATEInst: entity work.STATEModule
	Port Map(
		clk 			=> clk,
		Address		=> Address,
		Input       => Plaintext,
		Row1en		=> STATEenRow1,
		Row2en		=> STATEenRow2,
		Row3en		=> STATEenRow3,
		Row4en		=> STATEenRow4,
		enSaveMSB	=> STATEenSaveMSB,
		enMC			=> STATEenMC,
		enInput		=> STATEenInput,
		enSR			=> STATEenSR,
		MClastBit	=> STATEMClastBit,
		PolyBit		=> STATEPolyBit,
		SboxOutput	=> STATESboxOutput,
		Output      => STATEoutput);
		
	KEYInst: entity work.KEYModule
	Port Map(
		clk 			 => clk,
		Address		 => Address,
		Input        => Key,
		en				 => KEYen,
		Rcon			 => KEYRcon,
		enInput		 => KEYenInput,
		enAddSbox    => KEYenAddSbox,
		enAddRow1to3 => KEYenAddRow1to3,
		enAddRow4    => KEYenAddRow4,
		SboxInput	 => KEYSboxInput,
		SboxOutput	 => KEYSboxOutput,
		Output       => RoundKey);
		
	-------------------------------------------
		
		
		LUT6_inst : LUT6
        generic map (
        INIT => X"f606fffff6060000")
        port map (
        O => SboxInputMux,
        I0 => stateoutput,
        I1 => roundkey,
        I2 => sboxsel,
        I3 => keysboxinput,
        I4 => sbox_s0,
        I5 => rotreg7
	);
		
	SboxIns: entity work.Sbox
	Port Map( 
		x		=> SboxInputMux, 
		y 		=> STATESboxOutput,
		en		=> Sbox_Shift_en,
		s		=> Sbox_s1,
		rotReg7 => rotReg7,
		clk	=> clk);
		
	ShiftReg_inst : SRL16E
	generic map (INIT => X"0000")
	port map (
		CE 	=> '1',
		CLK 	=> clk,
		D 		=> STATESboxOutput,
		Q 		=> KEYSboxOutput,
		A0 	=> '1',
		A1 	=> '1',
		A2 	=> '1',
		A3 	=> '1');
		
	-------------------------------------------		
	Ciphertext		<= SboxInputMUX;
		
end Behavioral;

