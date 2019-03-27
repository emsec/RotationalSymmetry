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
	Generic (KeyMasked : NATURAL := 1);
	Port ( 
		clk 			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		PlaintextA  : in  STD_LOGIC;
		PlaintextB  : in  STD_LOGIC;
		KeyA        : in  STD_LOGIC;
		KeyB        : in  STD_LOGIC;
		FreshRandom : in  STD_LOGIC_VECTOR(5 downto 0);
		CiphertextA : out STD_LOGIC;
		CiphertextB : out STD_LOGIC;
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
	signal Sbox_s2			 	:  STD_LOGIC;	
	signal Sbox_fromBottom 		:  STD_LOGIC;

	signal RoundKeyA			:  STD_LOGIC;
	signal RoundKeyB			:  STD_LOGIC;
	
	signal KEYSboxInputA 	:  STD_LOGIC;
	signal KEYSboxInputB 	:  STD_LOGIC;
	
	signal KEYSboxShiftEN   :  STD_LOGIC;
	
	signal SboxInputMuxA  	:  STD_LOGIC;
	signal SboxInputMuxB  	:  STD_LOGIC;
	
	signal STATESboxOutputA	:  STD_LOGIC;
	signal STATESboxOutputB	:  STD_LOGIC;
	
	signal KEYSboxOutputA	:  STD_LOGIC;
	signal KEYSboxOutputB	:  STD_LOGIC;
	
	signal rotReg7_A			:  STD_LOGIC;
	signal rotReg7_B			:  STD_LOGIC;
	
	signal STATEoutputA     : STD_LOGIC;
	signal STATEoutputB     : STD_LOGIC;

	signal to_sstarA   		: std_logic_vector(7 downto 0);
	signal to_sstarB   		: std_logic_vector(7 downto 0);
	signal from_sstarA 		: std_logic_vector(7 downto 0);
	signal from_sstarB 		: std_logic_vector(7 downto 0);

   signal x0 : std_logic_vector(0 to 1); -- bit 0, 2 shares
   signal x1 : std_logic_vector(0 to 1); -- bit 1, 2 shares
   signal x2 : std_logic_vector(0 to 1); -- ...
   signal x3 : std_logic_vector(0 to 1);
   signal x4 : std_logic_vector(0 to 1);
   signal x5 : std_logic_vector(0 to 1);
   signal x6 : std_logic_vector(0 to 1);
   signal x7 : std_logic_vector(0 to 1);

	signal notclk      : STD_LOGIC;
	
	signal core_clk    : STD_LOGIC;  -- the main clock
	signal PC_clk      : STD_LOGIC;  -- pre-charge circuit clock
	signal PC_rst      : STD_LOGIC;	-- pre-charge circuit reset	
	
	attribute keep_hierarchy : string;

	attribute keep_hierarchy of ControllerInst : label is "yes";	
	attribute keep_hierarchy of function_A     : label is "yes";	
	attribute keep_hierarchy of function_B     : label is "yes";	
	attribute keep_hierarchy of Mshare0        : label is "yes";	
	attribute keep_hierarchy of Mshare1        : label is "yes";	
	attribute keep_hierarchy of Mshare2        : label is "yes";	
	attribute keep_hierarchy of Mshare3        : label is "yes";	
	attribute keep_hierarchy of Mshare4        : label is "yes";	
	attribute keep_hierarchy of Mshare5        : label is "yes";	
	attribute keep_hierarchy of Mshare6        : label is "yes";	
	attribute keep_hierarchy of Mshare7        : label is "yes";	
	attribute keep_hierarchy of Mshare8        : label is "yes";	
	attribute keep_hierarchy of Mshare9        : label is "yes";	
	attribute keep_hierarchy of Mshare10       : label is "yes";	
	attribute keep_hierarchy of Mshare11       : label is "yes";	
	attribute keep_hierarchy of Mshare12       : label is "yes";	
	attribute keep_hierarchy of Mshare13       : label is "yes";	
	attribute keep_hierarchy of Mshare14       : label is "yes";	
	attribute keep_hierarchy of Mshare15       : label is "yes";	
	
begin

   BUFG_inst1 : BUFG
   port map (
      O => core_clk, -- 1-bit output: Clock buffer output
      I => clk       -- 1-bit input: Clock buffer input
	  );

	notclk <= NOT clk;

   BUFG_inst2 : BUFG
   port map (
      O => PC_clk, -- 1-bit output: Clock buffer output
      I => notclk  -- 1-bit input: Clock buffer input
	  );
	
	PC_rst	<= clk;
	
	-----------------------------------

	ControllerInst: entity work.controller
	Port Map(
		clk 			 => core_clk,
		reset		     => reset,
		Address			 => Address,

		STATEenRow1		 => STATEenRow1,
		STATEenRow2		 => STATEenRow2,
		STATEenRow3		 => STATEenRow3,
		STATEenRow4		 => STATEenRow4,
		STATEenMC		 => STATEenMC,
		STATEenInput	 => STATEenInput,
		STATEenSR		 => STATEenSR,
		STATEenSaveMSB   => STATEenSaveMSB,
		STATEMClastBit	 => STATEMClastBit,
		STATEPolyBit	 => STATEPolyBit,

		KEYen			 => KEYen,
		KEYRcon			 => KEYRcon,
		KEYenInput		 => KEYenInput,
		KEYenAddSbox     => KEYenAddSbox,
		KEYenAddRow1to3  => KEYenAddRow1to3,
		KEYenAddRow4     => KEYenAddRow4,

		Sbox_Shift_en	 => Sbox_Shift_en,
		SboxSel			 => SboxSel,
		Sbox_s0			 => Sbox_s0,
		Sbox_s1			 => Sbox_s1,
		Sbox_s2			 => Sbox_s2,
		Sbox_fromBottom  => Sbox_fromBottom,
		KEYSboxShiftEN   => KEYSboxShiftEN,
		
		Done				 => Done);		

	-----------------------------------------------

	function_A: entity work.AES_functions generic map (affine => 1, KeyExist => 1, KeyMasked => KeyMasked) port map(
			Address			=> Address,
			Input       	=> PlaintextA,
			Row1en			=> STATEenRow1,
			Row2en			=> STATEenRow2,
			Row3en			=> STATEenRow3,
			Row4en			=> STATEenRow4,
			enSaveMSB		=> STATEenSaveMSB,
			enMC			=> STATEenMC,
			enInput			=> STATEenInput,
			enSR			=> STATEenSR,
			MClastBit		=> STATEMClastBit,
			PolyBit			=> STATEPolyBit,

			K_Input         => KeyA,
			K_en			=> KEYen,
			K_Rcon			=> KEYRcon,
			K_enInput		=> KEYenInput,
			K_enAddSbox     => KEYenAddSbox,
			K_enAddRow1to3  => KEYenAddRow1to3,
			K_enAddRow4     => KEYenAddRow4,
			KEYSboxShiftEN	=> KEYSboxShiftEN,
			KEYSboxOutput	=> open,
			KEYSboxOutput2  => KEYSboxOutputB,
			
			SboxSel			=> SboxSel,
			Sbox_s0			=> Sbox_s0,
			sel_p2n 		=> Sbox_s1, 
			sel 			=> Sbox_fromBottom, 
			en 				=> Sbox_Shift_en, 
			clk 			=> core_clk, 
			PC_clk 			=> PC_clk, 
			PC_rst 			=> PC_rst, 
			to_sstar			=> to_sstarA,
			from_sstar		=> from_sstarA, 
			mainout 		=> CiphertextA);
			
			

	function_B: entity work.AES_functions generic map (affine => 0, KeyExist => KeyMasked, KeyMasked => KeyMasked) port map(
			Address			=> Address,
			Input       	=> PlaintextB,
			Row1en			=> STATEenRow1,
			Row2en			=> STATEenRow2,
			Row3en			=> STATEenRow3,
			Row4en			=> STATEenRow4,
			enSaveMSB		=> STATEenSaveMSB,
			enMC			=> STATEenMC,
			enInput			=> STATEenInput,
			enSR			=> STATEenSR,
			MClastBit		=> STATEMClastBit,
			PolyBit			=> STATEPolyBit,

			K_Input         => KeyB,
			K_en			=> KEYen,
			K_Rcon			=> '0',
			K_enInput		=> KEYenInput,
			K_enAddSbox     => KEYenAddSbox,
			K_enAddRow1to3  => KEYenAddRow1to3,
			K_enAddRow4     => KEYenAddRow4,
			KEYSboxShiftEN	=> KEYSboxShiftEN,
			KEYSboxOutput	=> KEYSboxOutputB,
			KEYSboxOutput2  => '0',

			SboxSel			=> SboxSel,
			Sbox_s0			=> Sbox_s0,
			sel_p2n 		=> Sbox_s1, 
			sel 			=> Sbox_fromBottom, 
			en 				=> Sbox_Shift_en, 
			clk 			=> core_clk, 
			PC_clk 			=> PC_clk, 
			PC_rst 			=> PC_rst, 
			to_sstar 		=> to_sstarB,
			from_sstar		=> from_sstarB, 
			mainout 		=> CiphertextB);

	x0 <= to_sstarA(7) & to_sstarB(7);
	x1 <= to_sstarA(0) & to_sstarB(0);
	x2 <= to_sstarA(1) & to_sstarB(1);
	x3 <= to_sstarA(2) & to_sstarB(2);
	x4 <= to_sstarA(3) & to_sstarB(3);
	x5 <= to_sstarA(4) & to_sstarB(4);
	x6 <= to_sstarA(5) & to_sstarB(5);
	x7 <= to_sstarA(6) & to_sstarB(6);

	Mshare0:  entity work.spl0_shr0 port map (core_clk, x0(0), x1(0), x2(0), x3(0), x4(0), x5(0), x6(0), x7(0), Sbox_s2, '0',            from_sstarA(0));
	Mshare1:  entity work.spl0_shr1 port map (core_clk, x0(0), x1(0), x2(1), x3(0), x4(0), x5(0), x6(1), x7(1), Sbox_s2, FreshRandom(0), from_sstarA(1));
	Mshare2:  entity work.spl0_shr2 port map (core_clk, x0(0), x1(0), x2(1), x3(1), x4(1), x5(0), x6(0), x7(0), Sbox_s2, FreshRandom(1), from_sstarA(2));
	Mshare3:  entity work.spl0_shr3 port map (core_clk, x0(0), x1(0), x2(0), x3(1), x4(1), x5(0), x6(1), x7(1), Sbox_s2, FreshRandom(2), from_sstarA(3));

	Mshare8:  entity work.spl1_shr0 port map (core_clk, x0(0), x1(0), x2(0), x3(0), x4(0), x5(0), x6(0), x7(0), Sbox_s2, '0',            from_sstarA(4));
	Mshare9:  entity work.spl1_shr1 port map (core_clk, x0(0), x1(1), x2(0), x3(1), x4(0), x5(1), x6(0), x7(1), Sbox_s2, FreshRandom(3), from_sstarA(5));
	Mshare10: entity work.spl1_shr2 port map (core_clk, x0(0), x1(1), x2(1), x3(0), x4(1), x5(0), x6(0), x7(0), Sbox_s2, FreshRandom(4), from_sstarA(6));
	Mshare11: entity work.spl1_shr3 port map (core_clk, x0(0), x1(0), x2(1), x3(1), x4(1), x5(1), x6(0), x7(1), Sbox_s2, FreshRandom(5), from_sstarA(7));

	Mshare4:  entity work.spl0_shr4 port map (core_clk, x0(1), x1(1), x2(1), x3(0), x4(0), x5(1), x6(0), x7(0), Sbox_s2, FreshRandom(2), from_sstarB(0));
	Mshare5:  entity work.spl0_shr5 port map (core_clk, x0(1), x1(1), x2(0), x3(0), x4(0), x5(1), x6(1), x7(1), Sbox_s2, FreshRandom(1), from_sstarB(1));
	Mshare6:  entity work.spl0_shr6 port map (core_clk, x0(1), x1(1), x2(0), x3(1), x4(1), x5(1), x6(0), x7(0), Sbox_s2, FreshRandom(0), from_sstarB(2));
	Mshare7:  entity work.spl0_shr7 port map (core_clk, x0(1), x1(1), x2(1), x3(1), x4(1), x5(1), x6(1), x7(1), Sbox_s2, '0',  		     from_sstarB(3));

	Mshare12: entity work.spl1_shr4 port map (core_clk, x0(1), x1(1), x2(0), x3(0), x4(0), x5(0), x6(1), x7(0), Sbox_s2, FreshRandom(5), from_sstarB(4));
	Mshare13: entity work.spl1_shr5 port map (core_clk, x0(1), x1(0), x2(0), x3(1), x4(0), x5(1), x6(1), x7(1), Sbox_s2, FreshRandom(4), from_sstarB(5));
	Mshare14: entity work.spl1_shr6 port map (core_clk, x0(1), x1(0), x2(1), x3(0), x4(1), x5(0), x6(1), x7(0), Sbox_s2, FreshRandom(3), from_sstarB(6));
	Mshare15: entity work.spl1_shr7 port map (core_clk, x0(1), x1(1), x2(1), x3(1), x4(1), x5(1), x6(1), x7(1), Sbox_s2, '0',            from_sstarB(7));

end Behavioral;

