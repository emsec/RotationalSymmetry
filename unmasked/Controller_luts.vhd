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
		clk 				 : in  STD_LOGIC;
		reset				 : in  STD_LOGIC;
		
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
		
		Done				 : out STD_LOGIC);
end Controller;

architecture Behavioral of Controller is
	
 
  	signal STATE  					: STD_LOGIC_VECTOR(2 downto 0);
  	signal NEXT_STATE 				: STD_LOGIC_VECTOR(2 downto 0);

  	signal SR_TRIG					: STD_LOGIC;

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
	attribute loc : string;

	attribute loc of LT10  : label is "SLICE_X52Y55";
	
	attribute loc of LT11  : label is "SLICE_X52Y60";
	attribute loc of LT12  : label is "SLICE_X52Y60";
	
	attribute loc of LT13  : label is "SLICE_X52Y61";
	attribute loc of LT14  : label is "SLICE_X52Y61";
	
	attribute loc of LT15  : label is "SLICE_X52Y56"; 
	attribute loc of LT16  : label is "SLICE_X52Y57"; 
	attribute loc of LT17  : label is "SLICE_X52Y57";
	
	attribute loc of LT4 : label is "SLICE_X50Y54";
	attribute loc of LT5 : label is "SLICE_X50Y54";
	attribute loc of Counter128Inst: label is "SLICE_X50Y54";
	
	attribute loc of LT6 : label is "SLICE_X50Y55";
	attribute loc of LT7 : label is "SLICE_X50Y55";
	attribute loc of Counter8Inst : label is "SLICE_X50Y55";
	
	attribute loc of LT8 : label is "SLICE_X52Y56"; 
	attribute loc of LT9 : label is "SLICE_X50Y57"; 

	
	attribute loc of LT0 : label is "SLICE_X50Y57";
	attribute loc of LT1 : label is "SLICE_X50Y57";
	attribute loc of LT2 : label is "SLICE_X52Y55"; 
	attribute loc of FF0 : label is "SLICE_X50Y57";
	attribute loc of FF1 : label is "SLICE_X50Y57";
	attribute loc of FF2 : label is "SLICE_X50Y57";
	attribute loc of LT3 : label is "SLICE_X50Y57";
	
begin

	Counter128Inst: entity work.Counter4
	Port Map(
		CLK		=> clk,
		RST		=> Counter128Reset,
		EN		=> Counter128Enable,
		Q		=> Counter128(6 downto 3));

	Counter8Inst: entity work.Counter3
	Port Map(
		CLK			=> clk,
		RST			=> Counter8Reset,
		EN			=> Counter8Enable,
		Q			=> Counter128(2 downto 0),
		Counter1B 	=> Counter1B);
		
	RconCounterInst: entity work.Rcon_counter
	Port Map (
		clk		=> clk,
		rst 		=> RconCounterReset,
		en			=> RconCounterEnable,
		state2     	=> STATE(2),
		q			=> RconCounter,
		Rcon		=> KEYRcon);

	----------------------------------------------

	-- FSM: 8 states
	
	-- 000 = SB0
	-- 001 = MC
	-- 010 = SB1
	-- 011 = SB2
	-- 100 = SR
	-- 101 = saveMSB
	-- 110 = SB3
	-- 111 = RST

	RconCounterReset 	<= reset;
	STATEenInput		<= Counter8Reset;
	KEYenInput			<= Counter8Reset;

	-- next state 
	LT0 : LUT6   GENERIC MAP (INIT => X"0000FFA00FF03F00") PORT MAP(NEXT_STATE(0), SR_TRIG, CheckBits43One, CheckBits20One, STATE(0), STATE(1), STATE(2));
	LT1 : LUT6_2 GENERIC MAP (INIT => X"FF05FFFF0700FF0C") PORT MAP(NEXT_STATE(1), Counter8Enable, CheckBits43One, CheckBits20One, STATE(0), STATE(1), STATE(2), '1');
	LT2 : LUT6   GENERIC MAP (INIT => X"008F00FFF0003000") PORT MAP(NEXT_STATE(2), CheckBits63One, CheckBits43One, CheckBits20One, STATE(0), STATE(1), STATE(2));

	FF0 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(0), Q => STATE(0));
	FF1 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(1), Q => STATE(1));
	FF2 : FDSE GENERIC MAP (INIT=>'1') PORT MAP(C => clk, S => reset, CE => '1', D => NEXT_STATE(2), Q => STATE(2));

	-- Control Signals
	LT3 : LUT6_2 GENERIC MAP (INIT => X"FF00000080808080") PORT MAP(CheckBits20One, CheckBits43One, Counter128(0), Counter128(1), Counter128(2), Counter128(3), Counter128(4), '1');
	LT4 : LUT6_2 GENERIC MAP (INIT => X"77770000000000FF") PORT MAP(CheckBits43Zero, SR_TRIG, RconCounter(1),RconCounter(2),'0',Counter128(3), Counter128(4), '1');
	LT5 : LUT6_2 GENERIC MAP (INIT => X"000000CCAA000000") PORT MAP(CheckBits63One, CheckBits63Zero, CheckBits43One, CheckBits43Zero, '0', Counter128(5), Counter128(6), '1');
	KEYenAddRow1to3		<= CheckBits63One;
	
	LT6: LUT6_2 GENERIC MAP (INIT => X"BBBBBBBB0000FFFF") PORT MAP(STATEMClastBit, KEYenAddRow4, CheckBits63One, CheckBits43One, '0', '0', CheckBits20One, '1');

	LT7 : LUT6_2 GENERIC MAP (INIT => X"FF0A00F0FF0C00F0") PORT MAP(STATEenRow1, STATEenRow2, Counter128(3),CheckBits43One,STATE(0), STATE(1), STATE(2),'1');
	LT8 : LUT6_2 GENERIC MAP (INIT => X"FF0A0000FF0300F0") PORT MAP(STATEenRow3, KEYen, CheckBits43One, CheckBits43Zero, STATE(0), STATE(1), STATE(2), '1');
	LT9 : LUT6_2 GENERIC MAP (INIT => X"000A0000FF0F00F0") PORT MAP(STATEenRow4, Done, CheckBits43One, '0', STATE(0), STATE(1), STATE(2), '1');
	LT10: LUT6_2 GENERIC MAP (INIT => X"FF0F0F003A33AA3A") PORT MAP(Sbox_s1, Sbox_s0, CheckBits20One, reset, STATE(0),STATE(1),STATE(2),'1');
	LT11: LUT6_2 GENERIC MAP (INIT => X"0C00000000050000") PORT MAP(STATEenSR, KEYenAddSbox, CheckBits43One, CheckBits43Zero, STATE(0),STATE(1),STATE(2),'1');
	LT12: LUT6_2 GENERIC MAP (INIT => X"0A0A00A0F0000000") PORT MAP(Counter8Reset, Counter128Enable, CheckBits20One, '0', STATE(0), STATE(1), STATE(2), '1');
	LT13: LUT6_2 GENERIC MAP (INIT => X"00F00000000000F0") PORT MAP(STATEenMC, STATEenSaveMSB, '0','0',STATE(0), STATE(1), STATE(2), '1');
	LT14: LUT6_2 GENERIC MAP (INIT => X"FF00FF0FFFF0F0FF") PORT MAP(SboxSel, Sbox_Shift_en, '0', '0', STATE(0), STATE(1), STATE(2), '1');
	LT15: LUT6_2 GENERIC MAP (INIT => X"F00C00300A000030") PORT MAP(RconCounterEnable, Counter128Reset, CheckBits63Zero, NEXT_STATE(0), STATE(0), STATE(1), STATE(2), '1');
	STATEPolyBit	<= Counter1B;

	-- Address
	LT16: LUT6_2 GENERIC MAP (INIT => X"3F3F33F35F5F5505") PORT MAP(Address(0), Address(1), Counter128(0), Counter128(1), STATE(0), STATE(1), STATE(2),'1');
	LT17: LUT6_2 GENERIC MAP (INIT => X"F0FFFFFF5F5F55F5") PORT MAP(Address(2), address_dummy, Counter128(2), '0', STATE(0), STATE(1), STATE(2), '1');
	Address(4) <= address_dummy;
	Address(3) <= address_dummy;

	


end Behavioral;

