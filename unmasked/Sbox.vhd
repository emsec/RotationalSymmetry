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

entity sbox is
    Port ( x 			: in  STD_LOGIC;
           y 			: out  STD_LOGIC;
           en 			: in  STD_LOGIC;
		   rotReg7 		: out STD_LOGIC;
           s  			: in  STD_LOGIC;
           clk : in  STD_LOGIC);
end sbox;

architecture Behavioral of sbox is
	signal temp_par 		: 		std_logic_vector(7 downto 0);
	
	signal from_sstar		:		std_logic;
	
	signal from_p2n		:		std_logic_vector(7 downto 0);
	signal to_p2n			:		std_logic_vector(7 downto 0);
	signal from_n2p		:		std_logic_vector(7 downto 0);
	signal to_n2p			:		std_logic_vector(7 downto 0);
	signal to_Sstar		:		std_logic_vector(7 downto 0);
	signal pX8, nX8 : std_logic;
	
	attribute loc: string;
	
	
	--- 8 to 1  -- 1 SLICE
	attribute loc of sstar0 :  label is "SLICE_X50Y50";
	
	--  P2N with Regs 1.5 slices
	attribute loc of FDRE_i1 : label is "SLICE_X50Y51";
	attribute loc of FDRE_i8 : label is "SLICE_X50Y51";
	
	attribute loc of FDRE_i4 : label is "SLICE_X50Y52";
	attribute loc of FDRE_i7 : label is "SLICE_X50Y52";
	attribute loc of FDRE_i2 : label is "SLICE_X50Y52";
	attribute loc of FDRE_i6 : label is "SLICE_X50Y52";
	attribute loc of FDRE_i3 : label is "SLICE_X50Y52";
	attribute loc of FDRE_i5 : label is "SLICE_X50Y52";
	
	--- N2P with Regs 1.5 slices
	attribute loc of FDRE_n1 : label is "SLICE_X50Y51";
	attribute loc of FDRE_n3 : label is "SLICE_X50Y51";
	
	attribute loc of FDRE_n4 : label is "SLICE_X50Y53";
	attribute loc of FDRE_n7 : label is "SLICE_X50Y53";
	attribute loc of FDRE_n2 : label is "SLICE_X50Y53";
	attribute loc of FDRE_n6 : label is "SLICE_X50Y53";
	attribute loc of FDRE_n8 : label is "SLICE_X50Y53";
	attribute loc of FDRE_n5 : label is "SLICE_X50Y53";

begin

----- TOTAL
-- 6 + 6 + 4 LUTS
-- 16 Registers
-----> 4 Slices


-------------------- P2N ------------------- 6 LUTS
  
  p2n0: entity work.p2n
  port map(
		x => to_p2n,
		y => from_p2n,
		SEL => s);

------------------  REG for P2N --------------------

to_p2n(0) <= x;

FDRE_i1 : FDRE generic map (INIT => '0') port map (Q => to_p2n(1),C => clk, CE => en, R=> '0', D => from_p2n(0));
FDRE_i2 : FDRE generic map (INIT => '0') port map (Q => to_p2n(2),C => clk, CE => en, R=> '0', D => from_p2n(1));
FDRE_i3 : FDRE generic map (INIT => '0') port map (Q => to_p2n(3),C => clk, CE => en, R=> '0', D => from_p2n(2));
FDRE_i4 : FDRE generic map (INIT => '0') port map (Q => to_p2n(4),C => clk, CE => en, R=> '0', D => from_p2n(3));
FDRE_i5 : FDRE generic map (INIT => '0') port map (Q => to_p2n(5),C => clk, CE => en, R=> '0', D => from_p2n(4));
FDRE_i6 : FDRE generic map (INIT => '0') port map (Q => to_p2n(6),C => clk, CE => en, R=> '0', D => from_p2n(5));
FDRE_i7 : FDRE generic map (INIT => '0') port map (Q => to_p2n(7),C => clk, CE => en, R=> '0', D => from_p2n(6));
FDRE_i8 : FDRE generic map (INIT => '0') port map (Q => pX8,		C => clk, CE => en, R=> '0', D => from_p2n(7));

rotReg7 <= pX8;

 ------------------ Sstar -------------------- 4 LUTS, MUXes
  
   to_Sstar <= pX8 & to_p2n(7 downto 1);
	
  sstar0: entity work.sstar
  port map(
		x => to_Sstar,
		y => from_Sstar);


-------------------- REG for N2P --------------------

	
	
FDRE_n1 : FDRE generic map (INIT => '0') port map (Q => to_n2p(1),C => clk, CE => en, R=> '0', D => from_n2p(0));
FDRE_n2 : FDRE generic map (INIT => '0') port map (Q => to_n2p(2),C => clk, CE => en, R=> '0', D => from_n2p(1));
FDRE_n3 : FDRE generic map (INIT => '0') port map (Q => to_n2p(3),C => clk, CE => en, R=> '0', D => from_n2p(2));
FDRE_n4 : FDRE generic map (INIT => '0') port map (Q => to_n2p(4),C => clk, CE => en, R=> '0', D => from_n2p(3));
FDRE_n5 : FDRE generic map (INIT => '0') port map (Q => to_n2p(5),C => clk, CE => en, R=> '0', D => from_n2p(4));
FDRE_n6 : FDRE generic map (INIT => '0') port map (Q => to_n2p(6),C => clk, CE => en, R=> '0', D => from_n2p(5));
FDRE_n7 : FDRE generic map (INIT => '0') port map (Q => to_n2p(7),C => clk, CE => en, R=> '0', D => from_n2p(6));
FDRE_n8 : FDRE generic map (INIT => '0') port map (Q => nX8,		C => clk, CE => en, R=> '0', D => from_n2p(7));
	
y <= nX8;

to_n2p(0) <= from_Sstar;

-------------------- N2P ------------------- 6 LUTS

	
	n2p0: entity work.n2p
	port map(
		x => to_n2p,
		y => from_n2p,
		SEL => s);
		
	

end Behavioral;

