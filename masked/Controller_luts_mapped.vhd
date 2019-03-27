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

entity Controller is
	Port ( 
		clk 			 : in  STD_LOGIC;
		reset			 : in  STD_LOGIC;
		
		Address			 : out STD_LOGIC_VECTOR(4 downto 0);

		STATEenRow1		 : out STD_LOGIC;
		STATEenRow2		 : out STD_LOGIC;
		STATEenRow3		 : out STD_LOGIC;
		STATEenRow4		 : out STD_LOGIC;
		
		STATEenMC		 : out STD_LOGIC;
		STATEenInput	 : out STD_LOGIC;	
		STATEenSR		 : out STD_LOGIC;
		STATEenSaveMSB   : out STD_LOGIC;
		STATEMClastBit	 : out STD_LOGIC;
		STATEPolyBit	 : out STD_LOGIC;
		
		KEYen			 : out STD_LOGIC;
		KEYRcon			 : out STD_LOGIC;
		KEYenInput		 : out STD_LOGIC;
		KEYenAddSbox     : out STD_LOGIC;
		KEYenAddRow1to3  : out STD_LOGIC;
		KEYenAddRow4     : out STD_LOGIC;

		Sbox_Shift_en	 : out STD_LOGIC;
		SboxSel			 : out STD_LOGIC;
		Sbox_s0			 : out STD_LOGIC;
		Sbox_s1			 : out STD_LOGIC;
		Sbox_s2			 : out STD_LOGIC;
		Sbox_fromBottom  : out STD_LOGIC;
		KEYSboxShiftEN   : out STD_LOGIC;
		
		Done			 : out STD_LOGIC);
end Controller;

architecture Behavioral of Controller is
	
 
  	signal STATE  					: STD_LOGIC_VECTOR(2 downto 0);
  	signal NEXT_STATE 				: STD_LOGIC_VECTOR(2 downto 0);

  	signal SR_TRIG					: STD_LOGIC;
  	signal SB0_TRIG 				: STD_LOGIC;
  	signal SB3_TRIG					: STD_LOGIC;

  	signal address_dummy 			: STD_LOGIC;

	signal Counter128				: STD_LOGIC_VECTOR(6 downto 0);
	signal Counter8Reset 			: STD_LOGIC;
	signal Counter8Enable			: STD_LOGIC;
	signal Counter128Reset 			: STD_LOGIC;
	signal Counter128Enable			: STD_LOGIC;

	signal Counter1B        		: STD_LOGIC;

	signal CheckBits20One			: STD_LOGIC;
	signal CheckBits43Zero 			: STD_LOGIC;
	signal CheckBits43One 			: STD_LOGIC;
	signal CheckBits63Zero 			: STD_LOGIC;
	signal CheckBits63One 			: STD_LOGIC;

	signal RconCounter				: STD_LOGIC_VECTOR(7 downto 0);
	signal RconCounterReset 		: STD_LOGIC;
	signal RconCounterEnable		: STD_LOGIC;
	
	signal enInput					: STD_LOGIC;

	signal Counter4         		: STD_LOGIC_VECTOR(1 downto 0);
	signal NewCounter4      		: STD_LOGIC_VECTOR(1 downto 0);

	signal InSB0or2					: STD_LOGIC;
	signal InSB1or3					: STD_LOGIC;

	signal Counter128_CNT 			: STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal Counter128_NEWCNT 		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal Counter8_CNT 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal Counter8_NEWCNT 			: STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal RconCounter_CNT 			: STD_LOGIC_VECTOR(7 DOWNTO 0);	
	signal RconCounter_NEWCNT 		: STD_LOGIC_VECTOR(7 DOWNTO 0);	


	attribute loc : string;

	attribute loc of LT11  : label is "SLICE_X52Y55";
	
	attribute loc of LT15  : label is "SLICE_X52Y60";
	attribute loc of LT16  : label is "SLICE_X52Y60";
	
	attribute loc of LT17  : label is "SLICE_X52Y61";
	attribute loc of LT18  : label is "SLICE_X52Y61";
	
	attribute loc of LT19  : label is "SLICE_X52Y56"; 
	attribute loc of LT20  : label is "SLICE_X52Y57"; 
	attribute loc of LT21  : label is "SLICE_X52Y57"; 
	
	attribute loc of LT5 : label is "SLICE_X50Y54";
	attribute loc of LT6 : label is "SLICE_X50Y54";
	
	attribute loc of LT7 : label is "SLICE_X50Y55";
	attribute loc of LT8 : label is "SLICE_X50Y55";
	
	attribute loc of LT9 : label is "SLICE_X52Y56"; 
	attribute loc of LT10: label is "SLICE_X50Y57"; 

	attribute loc of FF0 : label is "SLICE_X50Y57";
	attribute loc of FF1 : label is "SLICE_X50Y57";
	attribute loc of FF2 : label is "SLICE_X50Y57";
	attribute loc of LT4 : label is "SLICE_X50Y57";
	
	


begin


	-- COUNTER128 LUTS ---------------------------------------------------------------
	Counter128InstLT0 : LUT6_2 GENERIC MAP (INIT => X"6666666655555555") PORT MAP (Counter128_NEWCNT(0), Counter128_NEWCNT(1), Counter128_CNT(0), Counter128_CNT(1), Counter128_CNT(2), Counter128_CNT(3), '0', '1');
	Counter128InstLT1 : LUT6_2 GENERIC MAP (INIT => X"7F807F8078787878") PORT MAP (Counter128_NEWCNT(2), Counter128_NEWCNT(3), Counter128_CNT(0), Counter128_CNT(1), Counter128_CNT(2), Counter128_CNT(3), '0', '1');
	----------------------------------------------------------------------------------

	-- COUNTER128 FFs ----------------------------------------------------------------
	Counter128InstFF0 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter128Enable, R => Counter128Reset, D => Counter128_NEWCNT(0), Q => Counter128_CNT(0));
	Counter128InstFF1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter128Enable, R => Counter128Reset, D => Counter128_NEWCNT(1), Q => Counter128_CNT(1));
	Counter128InstFF2 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter128Enable, R => Counter128Reset, D => Counter128_NEWCNT(2), Q => Counter128_CNT(2));
	Counter128InstFF3 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter128Enable, R => Counter128Reset, D => Counter128_NEWCNT(3), Q => Counter128_CNT(3));
	----------------------------------------------------------------------------------
	
	-- COUNTER128 OUTPUT -------------------------------------------------------------
	Counter128(6 downto 3) <= Counter128_CNT;
	----------------------------------------------------------------------------------
		

	-- COUNTER3 LUTS --------------------------------------------------------------
	Counter8InstLT0 : LUT6_2 GENERIC MAP (INIT => X"6666666655555555") PORT MAP (Counter8_NEWCNT(0), Counter8_NEWCNT(1), Counter8_CNT(0), Counter8_CNT(1), Counter8_CNT(2), '0', '0', '1');
	Counter8InstLT1 : LUT6_2 GENERIC MAP (INIT => X"D8D8D8D878787878") PORT MAP (Counter8_NEWCNT(2), Counter1B, Counter8_CNT(0), Counter8_CNT(1), Counter8_CNT(2), '0', '0', '1');
	-------------------------------------------------------------------------------

	-- COUNTER3 FFs ---------------------------------------------------------------
	Counter8InstFF0 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter8Enable, R => Counter8Reset, D => Counter8_NEWCNT(0), Q => Counter8_CNT(0));
	Counter8InstFF1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter8Enable, R => Counter8Reset, D => Counter8_NEWCNT(1), Q => Counter8_CNT(1));
	Counter8InstFF2 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => Counter8Enable, R => Counter8Reset, D => Counter8_NEWCNT(2), Q => Counter8_CNT(2));
	-------------------------------------------------------------------------------
	
	-- COUNTER3 OUTPUT ------------------------------------------------------------
	Counter128(2 downto 0) <= Counter8_CNT;		
		
	-- RCON COUNTER ---------------------------------------------------------------

	RconCounterInstFF0 : FDSE GENERIC MAP (INIT => '1') PORT MAP (C => CLK, CE => RconCounterEnable, S => RconCounterReset, D => RconCounter_NEWCNT(0), Q => RconCounter_CNT(0));
	RconCounterInstFF1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(1), Q => RconCounter_CNT(1));
	RconCounterInstFF2 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(2), Q => RconCounter_CNT(2));	
	RconCounterInstFF3 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(3), Q => RconCounter_CNT(3));
	RconCounterInstFF4 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(4), Q => RconCounter_CNT(4));
	RconCounterInstFF5 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(5), Q => RconCounter_CNT(5));
	RconCounterInstFF6 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(6), Q => RconCounter_CNT(6));
	RconCounterInstFF7 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => CLK, CE => RconCounterEnable, R => RconCounterReset, D => RconCounter_NEWCNT(7), Q => RconCounter_CNT(7));
	
	RconCounter_NEWCNT(0) <= RconCounter_CNT(7);
	RconCounter_NEWCNT(2) <= RconCounter_CNT(1);
	RconCounter_NEWCNT(5) <= RconCounter_CNT(4);
	RconCounter_NEWCNT(6) <= RconCounter_CNT(5);
	RconCounter_NEWCNT(7) <= RconCounter_CNT(6);
	
	RconCounter_LUT0 : LUT6_2 GENERIC MAP (INIT => X"CC3C3C3CAA5A5A5A") PORT MAP(RconCounter_NEWCNT(1),RconCounter_NEWCNT(3), RconCounter_CNT(0), RconCounter_CNT(2), RconCounter_CNT(7), RconCounterEnable, STATE(2), '1');
	RconCounter_LUT1 : LUT6_2 GENERIC MAP (INIT => X"F0000000AA5A5A5A") PORT MAP(RconCounter_NEWCNT(4), KEYRcon, RconCounter_CNT(3), '0', RconCounter_CNT(7), RconCounterEnable, STATE(2), '1');
	---------
	
	RconCounter <= RconCounter_CNT;


---=========================

	-- FSM: 8 states

	-- encoding:
	-- 000 = SB0
	-- 001 = saveMSB
	-- 010 = SB1
	-- 011 = MC
	-- 100 = SB2 
	-- 101 = SR
	-- 110 = SB3
	-- 111 = RST

	RconCounterReset 	<= reset;

	STATEenInput		<= enInput;
	KEYenInput			<= enInput;

	FFCounter4_0 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => clk, CE => '1', R => reset, D => NewCounter4(0), Q => Counter4(0));
	FFCounter4_1 : FDRE GENERIC MAP (INIT => '0') PORT MAP (C => clk, CE => '1', R => reset, D => NewCounter4(1), Q => Counter4(1));

	----------------------------------------------

	-- next state 
	LT0 : LUT6   GENERIC MAP (INIT => X"00A0FF003F00FF00") PORT MAP(NEXT_STATE(0), CheckBits63One, CheckBits43One, CheckBits20One, STATE(0), STATE(1), STATE(2));
	LT1 : LUT6   GENERIC MAP (INIT => X"00AA00CC0F0FFFCC") PORT MAP(NEXT_STATE(1), SB3_TRIG, SB0_TRIG, CheckBits20One, STATE(0), STATE(1), STATE(2));
	LT2 : LUT6   GENERIC MAP (INIT => X"00AF3FFF00F00000") PORT MAP(NEXT_STATE(2), CheckBits63One, SR_TRIG, CheckBits20One, STATE(0), STATE(1), STATE(2));

	LT3 : LUT6_2 GENERIC MAP (INIT => X"FF0000001F1F1F1F") PORT MAP(SB3_TRIG, SB0_TRIG, CheckBits63One, CheckBits43One, CheckBits20One, Counter4(0), Counter4(1), '1');

	FF0 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(0), Q => STATE(0));
	FF1 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(1), Q => STATE(1));
	FF2 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(2), Q => STATE(2));

	-- Control Signals
	LT4 : LUT6_2 GENERIC MAP (INIT => X"FF00000080808080") PORT MAP(CheckBits20One, CheckBits43One, Counter128(0), Counter128(1), Counter128(2), Counter128(3), Counter128(4), '1');
	LT5 : LUT6_2 GENERIC MAP (INIT => X"77770000000000FF") PORT MAP(CheckBits43Zero, SR_TRIG, RconCounter(1),RconCounter(2),'0',Counter128(3), Counter128(4), '1');
	LT6 : LUT6_2 GENERIC MAP (INIT => X"000000CCAA000000") PORT MAP(CheckBits63One, CheckBits63Zero, CheckBits43One, CheckBits43Zero, '0', Counter128(5), Counter128(6), '1');
	KEYenAddRow1to3		<= CheckBits63One;
	
	LT7: LUT6_2 GENERIC MAP (INIT => X"BBBBBBBB0000FFFF") PORT MAP(STATEMClastBit, KEYenAddRow4, CheckBits63One, CheckBits43One, '0', '0', CheckBits20One, '1');

	LT8 : LUT6_2 GENERIC MAP (INIT => X"FFA0F000FFC0F000") PORT MAP(STATEenRow1, STATEenRow2, Counter128(3),CheckBits43One,STATE(0), STATE(1), STATE(2),'1');
	LT9 : LUT6_2 GENERIC MAP (INIT => X"FFA00000FF30F000") PORT MAP(STATEenRow3, KEYen, CheckBits43One, CheckBits43Zero, STATE(0), STATE(1), STATE(2), '1');
	LT10: LUT6_2 GENERIC MAP (INIT => X"00A00000FFF0F000") PORT MAP(STATEenRow4, Done, CheckBits43One, '0', STATE(0), STATE(1), STATE(2), '1');


	LT11: LUT6_2 GENERIC MAP (INIT => X"FFF00F00FF5FFF0F") PORT MAP(Counter8Enable, Sbox_s0, CheckBits43One, '0', STATE(0),STATE(1),STATE(2),'1');
	LT12: LUT6_2 GENERIC MAP (INIT => X"0F000F00000F000F") PORT MAP(InSB0or2, InSB1or3, '0', '0', STATE(0), STATE(1), STATE(2), '1');
	LT13: LUT6_2 GENERIC MAP (INIT => X"202020200000EACF") PORT MAP(Sbox_s1, NewCounter4(0), CheckBits20One, Counter4(0), InSB0or2, InSB1or3, reset,'1');
	LT14: LUT6_2 GENERIC MAP (INIT => X"FC54FC54FFFFCC00") PORT MAP(Counter8Reset, NewCounter4(1), CheckBits20One, Counter4(0), Counter4(1), InSB0or2, enInput, '1');
	Sbox_s2			   <= Counter4(1);
	Sbox_fromBottom    <= Counter4(0);
	KEYSboxShiftEN  	<= InSB1or3;

	LT15: LUT6_2 GENERIC MAP (INIT => X"0C00000000500000") PORT MAP(STATEenSR, KEYenAddSbox, CheckBits43One, CheckBits43Zero, STATE(0),STATE(1),STATE(2),'1');
	LT16: LUT6_2 GENERIC MAP (INIT => X"0AA0A000F0000000") PORT MAP(enInput, Counter128Enable, CheckBits20One, '0', STATE(0), STATE(1), STATE(2), '1');
	LT17: LUT6_2 GENERIC MAP (INIT => X"000000F00000F000") PORT MAP(STATEenMC, STATEenSaveMSB, '0','0',STATE(0), STATE(1), STATE(2), '1');
	LT18: LUT6_2 GENERIC MAP (INIT => X"FF0F0F0F0A003000") PORT MAP(RconCounterEnable, Sbox_Shift_en, CheckBits63Zero, NEXT_STATE(0), STATE(0), STATE(1), STATE(2), '1');
	LT19: LUT6_2 GENERIC MAP (INIT => X"F0503000FF0FF0FF") PORT MAP(SboxSel, Counter128Reset, NEXT_STATE(2), NEXT_STATE(0), STATE(0), STATE(1), STATE(2), '1');

	STATEPolyBit	<= Counter1B;

	-- Address
	LT20: LUT6_2 GENERIC MAP (INIT => X"3FF3F3335FF50555") PORT MAP(Address(0), Address(1), Counter128(0), Counter128(1), STATE(0), STATE(1), STATE(2),'1');
	LT21: LUT6_2 GENERIC MAP (INIT => X"F0FFFFFF5FF5F555") PORT MAP(Address(2), address_dummy, Counter128(2), '0', STATE(0), STATE(1), STATE(2), '1');

	Address(4) <= address_dummy;
	Address(3) <= address_dummy;

	


end Behavioral;

