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

library UNISIM;
use UNISIM.VComponents.all;

entity AES_functions is
  Generic ( 
	affine 	 : integer := 1;
	KeyExist  : NATURAL := 1;
	KeyMasked : NATURAL := 1);
  port ( 		
		Address		: in  STD_LOGIC_VECTOR(4 downto 0);
		Input       : in  STD_LOGIC;
		Row1en		: in  STD_LOGIC;
		Row2en		: in  STD_LOGIC;
		Row3en		: in  STD_LOGIC;
		Row4en		: in  STD_LOGIC;
		enSaveMSB	: in  STD_LOGIC;
		enMC			: in  STD_LOGIC;
		enInput		: in  STD_LOGIC;	
		enSR			: in  STD_LOGIC;
		MClastBit	: in  STD_LOGIC;
		PolyBit		: in  STD_LOGIC;

		K_Input        : in  STD_LOGIC;
		K_en				 : in  STD_LOGIC;
		K_Rcon			 : in  STD_LOGIC;
		K_enInput		 : in  STD_LOGIC;
		K_enAddSbox    : in  STD_LOGIC;
		K_enAddRow1to3 : in  STD_LOGIC;
		K_enAddRow4    : in  STD_LOGIC;
		KEYSboxShiftEN : in  STD_LOGIC;
		KEYSboxOutput  : out STD_LOGIC;
		KEYSboxOutput2 : in STD_LOGIC;
		
		SboxSel			: in  STD_LOGIC;
		Sbox_s0			: in  STD_LOGIC;
		sel : in std_logic;
		sel_p2n : in std_logic;
		clk : in  STD_LOGIC;
		en  : in STD_LOGIC := '1';
		rst : in STD_LOGIC := '0';
		PC_clk : in  STD_LOGIC;
		PC_rst : in  STD_LOGIC;
		to_sstar       : out std_logic_vector(7 downto 0);
		from_sstar		: in  std_logic_vector(7 downto 0);
		mainout : out std_logic
		);
end entity ;
 
architecture Behavioral of AES_functions is
 
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
	
	signal SboxOutput									: STD_LOGIC;
	signal STATEoutput  								: STD_LOGIC;
	
------
	 
	signal K_Row1i,  K_Row2i,  K_Row3i,  K_Row4i   : std_logic;
	signal K_Row1o,  K_Row2o,  K_Row3o,  K_Row4o   : std_logic;
	signal K_Row1mo, K_Row2mo, K_Row3mo, K_Row4mo  : std_logic;

	signal K_SelectedAdd, K_SerialSboxOut			: std_logic;
	
	signal K_SerialSboxOutXORRcon, K_OtherInput, K_Input2	: std_logic;

	signal RoundKey 	 	 : STD_LOGIC;
	signal KEYSboxInput   : STD_LOGIC;
	signal K_SboxOutput  : STD_LOGIC;
	

------	
	 	 
	signal y, z, memory, par_in , bottom_memory, par_bottom_mux, from_Reg_bottom  : std_logic_vector( 7 downto 0);

	signal y0_dummy, y2_dummy : std_logic;

	signal to_p2n : std_logic_vector( 7 downto 0);
	
	
	signal y6_dummy, y7_dummy : std_logic;
	
	signal sstar_out : std_logic;
	
   signal pow26_v, xorpow_v : std_logic_vector(0 to 1);
	
	signal xin	: std_logic;
	
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
		
	MSBREGinst_0 : FDRE generic map (INIT => '0') port map (Q => MSBReg(0),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(0));
	MSBREGinst_1 : FDRE generic map (INIT => '0') port map (Q => MSBReg(1),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(1));
	MSBREGinst_2 : FDRE generic map (INIT => '0') port map (Q => MSBReg(2),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(2));
	MSBREGinst_3 : FDRE generic map (INIT => '0') port map (Q => MSBReg(3),C => clk, CE => enSaveMSB, R=> '0', D => MSBtoSave(3));
	
	--------------------------------------------
			
	-- Row1i 		<= MC1 when enMC = '1' else Row2o(1);
	-- Row4i			<= MC4 when enMC = '1' else Row4i0;
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
	
	--MC1 <= Row2x1 XOR  Row4x1 XOR Row3x1 XOR mid1_1 xor mid1_2 xOR mid2;
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
	--MC3 <= Row2x1 XOR mid3 xor mid4;  --O6
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


	STATEoutput <= Row1o(0);

--------------------------------------------
--==========================================

	GenKeyExist: IF KeyExist = 1 GENERATE

		KeyRegRow1 : SRLC32E
		generic map (INIT => X"00000000")
		port map (
			Q 		=> K_Row1mo,
			Q31 	=> K_Row1o,
			A 		=> Address,
			CE 	=> K_en,
			CLK 	=> clk,
			D 		=> K_Row1i);

		KeyRegRow2 : SRLC32E
		generic map (INIT => X"00000000")
		port map (
			Q 		=> K_Row2mo,
			Q31 	=> K_Row2o,
			A 		=> "00111",
			CE 	=> K_en,
			CLK 	=> clk,
			D 		=> K_Row2i);
			
		KeyRegRow3 : SRLC32E
		generic map (INIT => X"00000000")
		port map (
			Q 		=> K_Row3mo,
			Q31 	=> K_Row3o,
			A 		=> "00111",
			CE 	=> K_en,
			CLK 	=> clk,
			D 		=> K_Row3i);

		KeyRegRow4 : SRLC32E
		generic map (INIT => X"00000000")
		port map (
			Q 		=> K_Row4mo,
			Q31 	=> K_Row4o,
			A 		=> "00111",
			CE 	=> K_en,
			CLK 	=> clk,
			D 		=> K_Row4i);

		--------------------------------------------
		
		 LUT6_2_r12 : LUT6_2
		 generic map (
		 INIT => X"3c3ccccc5aaa5aaa") 
		 port map (
			  O6 => K_Row2i,
			  O5 => K_Row1i,
			  I0 => K_Row2o,
			  I1 => K_Row3o,
			  I2 => K_enAddRow1to3,
			  I3 => K_Row1mo,
			  I4 => K_Row2mo,
			  I5 => '1'
		 );

			LUT6_otherinput : LUT6
			  generic map (
			  INIT => X"909fffff6f600000")
			  port map (
			  O =>  K_OtherInput,
			  I0 => K_SboxOutput,
			  I1 => K_Rcon,
			  I2 => K_enAddSbox,
			  I3 => K_Row4mo,
			  I4 => K_enAddRow4,
			  I5 => K_Row1o
		 );
		 
	 LUT6_2_r3input : LUT6_2
		 generic map (
		 INIT => X"ff00ff006a6a6a6a") 
		 port map (
			  O6 => K_Input2,
			  O5 => K_Row3i,
			  I0 => K_Row4o,
			  I1 => K_enAddRow1to3,
			  I2 => K_Row3mo,
			  I3 => K_Input,
			  I4 => '1',
			  I5 => '1'
		 );

		GenKeyMasked: IF KeyMasked = 1 GENERATE
			MUXF7_row4 : MUXF7
			port map (
				O => K_Row4i, 
				I0 => K_OtherInput,
				I1 => K_Input2, 
				S => K_enInput);
		END GENERATE;
		
		GenKeyNotMasked: IF KeyMasked = 0 GENERATE	
			LUT_row4 : LUT5  
			  generic map (
			  INIT => X"FF6A006A")
			  port map (
			  O => K_Row4i,
			  I0 => K_OtherInput,
			  I1 => KEYSboxOutput2,
			  I2 => K_enAddSbox,
			  I3 => K_enInput,
			  I4 => K_Input2);
		END GENERATE;
		

		KEYSboxInput 		<= K_Row2i;
		RoundKey 			<= K_Row1mo;

	END GENERATE;	

	GenKeyNOTExist: IF KeyExist = 0 GENERATE
		KEYSboxInput 	<= '0';
		RoundKey	 		<= '0';
	END GENERATE;

---------------------------------------------
--==========================================

	
	ShiftReg_inst : SRL16E
	generic map (INIT => X"0000")
	port map (
		CE 	=> KEYSboxShiftEN,
		CLK 	=> clk,
		D 		=> SboxOutput,
		Q 		=> K_SboxOutput,
		A0 	=> '1',
		A1 	=> '1',
		A2 	=> '1',
		A3 	=> '0');


	KEYSboxOutput <= K_SboxOutput;

--=============================================


	LUT6_inst: LUT6
	  generic map (
	  INIT => X"f606fffff6060000")
	  port map (
	  O => xin,
	  I0 => STATEoutput,
	  I1 => RoundKey,
	  I2 => SboxSel,
	  I3 => KEYSboxInput,
	  I4 => Sbox_s0,
	  I5 => memory(7));
	  
	  mainout <= xin;
	  
----	  


to_p2n <= memory(6 downto 0) & xin;

LT1: LUT6 GENERIC MAP (INIT => X"69966996AAAAAAAA") PORT MAP(y0_dummy, to_p2n(0), to_p2n(3), to_p2n(4), to_p2n(7), '0', sel_p2n);
y(0) <= y0_dummy;

LT2: LUT6 GENERIC MAP (INIT => X"96696996CCCCCCCC") PORT MAP(y(1), to_p2n(0), to_p2n(1), to_p2n(3), to_p2n(6), to_p2n(7), sel_p2n);
LT3: LUT6 GENERIC MAP (INIT => X"96696996CCCCCCCC") PORT MAP(y2_dummy, to_p2n(0), to_p2n(2), to_p2n(3), to_p2n(5), to_p2n(6), sel_p2n);
y(2) <= y2_dummy;

LT4: LUT6 GENERIC MAP (INIT => X"69966996FFFF0000") PORT MAP(y(5), to_p2n(0), to_p2n(1), to_p2n(3), to_p2n(4), to_p2n(5), sel_p2n);
LT5: LUT6 GENERIC MAP(INIT => X"69966996FFFF0000") PORT MAP(y(3), y0_dummy, to_p2n(1), to_p2n(5), to_p2n(6), to_p2n(3), sel_p2n);
LT6: LUT6_2 GENERIC MAP(INIT => X"6996F0F09696FF00") PORT MAP(y(4), y(7), y2_dummy, to_p2n(3), to_p2n(7), to_p2n(4), sel_p2n, '1');
LT7: LUT6 GENERIC MAP (INIT => X"66666666F0F0F0F0") PORT MAP(y(6), y2_dummy, to_p2n(1), to_p2n(6), '0', '0', sel_p2n);

--------------------------------------------

LTT1 : LUT6_2 GENERIC MAP (INIT => X"F0F0FF00AAAACCCC") PORT MAP(z(0), z(1), from_Reg_bottom(0), y(0), from_Reg_bottom(1), y(1), sel, '1');
LTT2 : LUT6_2 GENERIC MAP (INIT => X"F0F0FF00AAAACCCC") PORT MAP(z(2), z(3), from_Reg_bottom(2), y(2), from_Reg_bottom(3), y(3), sel, '1');
LTT3 : LUT6_2 GENERIC MAP (INIT => X"F0F0FF00AAAACCCC") PORT MAP(z(4), z(5), from_Reg_bottom(4), y(4), from_Reg_bottom(5), y(5), sel, '1');
LTT4 : LUT6_2 GENERIC MAP (INIT => X"F0F0FF00AAAACCCC") PORT MAP(z(6), z(7), from_Reg_bottom(6), y(6), from_Reg_bottom(7), y(7), sel, '1');

par_in <= z;

FDRE_i1 : FDRE generic map (INIT => '0') port map (Q => memory(0),C => clk, CE => en, R=> rst, D => par_in(0));
FDRE_i2 : FDRE generic map (INIT => '0') port map (Q => memory(1),C => clk, CE => en, R=> rst, D => par_in(1));
FDRE_i3 : FDRE generic map (INIT => '0') port map (Q => memory(2),C => clk, CE => en, R=> rst, D => par_in(2));
FDRE_i4 : FDRE generic map (INIT => '0') port map (Q => memory(3),C => clk, CE => en, R=> rst, D => par_in(3));
FDRE_i5 : FDRE generic map (INIT => '0') port map (Q => memory(4),C => clk, CE => en, R=> rst, D => par_in(4));
FDRE_i6 : FDRE generic map (INIT => '0') port map (Q => memory(5),C => clk, CE => en, R=> rst, D => par_in(5));
FDRE_i7 : FDRE generic map (INIT => '0') port map (Q => memory(6),C => clk, CE => en, R=> rst, D => par_in(6));
FDRE_i8 : FDRE generic map (INIT => '0') port map (Q => memory(7),C => clk, CE => en, R=> rst, D => par_in(7));


genff : for I in 0 to 7 generate 
	ff_i : FDRE PORT MAP(C => PC_clk, R => PC_rst, CE => '1', D => memory(I), Q => to_sstar(I));
end generate;


--------------------


SboxOutput <= bottom_memory(7);

FDRE_b_i1 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(0),C => clk, CE => '1', R=> '0', D => par_bottom_mux(0));
FDRE_b_i2 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(1),C => clk, CE => '1', R=> '0', D => par_bottom_mux(1));
FDRE_b_i3 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(2),C => clk, CE => '1', R=> '0', D => par_bottom_mux(2));
FDRE_b_i4 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(3),C => clk, CE => '1', R=> '0', D => par_bottom_mux(3));
FDRE_b_i5 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(4),C => clk, CE => '1', R=> '0', D => par_bottom_mux(4));
FDRE_b_i6 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(5),C => clk, CE => '1', R=> '0', D => par_bottom_mux(5));
FDRE_b_i7 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(6),C => clk, CE => '1', R=> '0', D => par_bottom_mux(6));
FDRE_b_i8 : FDRE generic map (INIT => '0') port map (Q => bottom_memory(7),C => clk, CE => '1', R=> '0', D => par_bottom_mux(7));


from_Reg_bottom <= bottom_memory(6 downto 0) & sstar_out;


LT_b1 : LUT6 GENERIC MAP (INIT => X"96696996CCCCCCCC") PORT MAP(par_bottom_mux(2), from_Reg_bottom(1), from_Reg_bottom(2), from_Reg_bottom(3), from_Reg_bottom(6), from_Reg_bottom(7), sel_p2n);
LT_b2: LUT6 GENERIC MAP (INIT => X"96969696AAAAAAAA") PORT MAP(par_bottom_mux(3), from_Reg_bottom(3), from_Reg_bottom(5), from_Reg_bottom(6), '0', '0', sel_p2n);
LT_b3: LUT6 GENERIC MAP (INIT => X"96696996FF00FF00") PORT MAP(par_bottom_mux(4), from_Reg_bottom(0), from_Reg_bottom(2), from_Reg_bottom(3), from_Reg_bottom(4), from_Reg_bottom(7), sel_p2n);
LT_b4 : LUT6 GENERIC MAP (INIT => X"69966996FF00FF00") PORT MAP(y7_dummy, from_Reg_bottom(0), from_Reg_bottom(3), from_Reg_bottom(6), from_Reg_bottom(7), '0', sel_p2n);
par_bottom_mux(7) <= y7_dummy;



g0: if affine = 1 generate
	LT5 : LUT6 GENERIC MAP (INIT => X"69969669AAAAAAAA") PORT MAP(par_bottom_mux(0), from_Reg_bottom(0), from_Reg_bottom(2), from_Reg_bottom(3), from_Reg_bottom(4), from_Reg_bottom(5), sel_p2n);
	LT6 : LUT6_2 GENERIC MAP (INIT => X"F00FAAAA9999F0F0") PORT MAP(par_bottom_mux(1), par_bottom_mux(5), from_Reg_bottom(5), y7_dummy, from_Reg_bottom(1), from_Reg_bottom(7), sel_p2n, '1');
	LT7 : LUT6 GENERIC MAP (INIT => X"99999999F0F0F0F0") PORT MAP(par_bottom_mux(6), from_Reg_bottom(0), from_Reg_bottom(4), from_Reg_bottom(6), '0', '0', sel_p2n);
end generate;

g1: if affine = 0 generate
	LT5 : LUT6 GENERIC MAP (INIT => X"96696996AAAAAAAA") PORT MAP(par_bottom_mux(0), from_Reg_bottom(0), from_Reg_bottom(2), from_Reg_bottom(3), from_Reg_bottom(4), from_Reg_bottom(5), sel_p2n);
	LT6 : LUT6_2 GENERIC MAP (INIT => X"0FF0AAAA6666F0F0") PORT MAP(par_bottom_mux(1), par_bottom_mux(5), from_Reg_bottom(5), y7_dummy, from_Reg_bottom(1), from_Reg_bottom(7), sel_p2n, '1');
	LT7 : LUT6 GENERIC MAP (INIT => X"66666666F0F0F0F0") PORT MAP(par_bottom_mux(6), from_Reg_bottom(0), from_Reg_bottom(4), from_Reg_bottom(6), '0', '0', sel_p2n);
end generate;

	sstar_out <= from_sstar(0) XOR from_sstar(1) XOR from_sstar(2) XOR from_sstar(3) XOR 
	             from_sstar(4) XOR from_sstar(5) XOR from_sstar(6) XOR from_sstar(7);

end Behavioral ;


