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

entity n2p is
    Port ( x : in  STD_LOGIC_VECTOR (7 downto 0);
           y : out  STD_LOGIC_VECTOR (7 downto 0);
		   SEL : in STD_LOGIC
		);
end n2p;

architecture Behavioral of n2p is
	signal    H : std_logic;
	attribute loc: string;
	attribute loc of inst6_0 :  label is "SLICE_X50Y51";
	attribute loc of inst6_3 :  label is "SLICE_X50Y51";
	
	attribute loc of inst6_1 :  label is "SLICE_X50Y53";
	attribute loc of inst6_2 :  label is "SLICE_X50Y53";
	attribute loc of inst6_4 :  label is "SLICE_X50Y53";
	attribute loc of inst6_5 :  label is "SLICE_X50Y53";
begin


 --- N2P

--Y(0) <= X(6) xor '1';
--Y(1) <= X(1) xor '1';
--Y(2) <= X(0) xor X(1) xor X(2) ;
--Y(3) <= X(0) xor X(2) xor X(4) ;
--Y(4) <= X(1) xor X(2) xor X(3) ;
--Y(5) <= X(0) xor X(3) xor X(4) xor X(5) xor '1';
--Y(6) <= X(0) xor X(1) xor X(3) xor X(4) xor X(5) xor X(7) xor '1';
--Y(7) <= X(0) xor X(6) ;

inst6_0 : LUT6 generic map (INIT => x"6996966996696996" ) port map (H , X(0), X(1), X(3), X(4), X(5), X(6));
inst6_3 : LUT6_2 generic map (INIT => x"00ffaaaa9696f0f0" ) port map (Y(2), Y(0), X(0), X(1), X(2), X(6), SEL, '1' );

inst6_1 : LUT6 generic map (INIT => x"9966f0f09966f0f0" ) port map (Y(3), X(0), X(2), X(3), X(4), SEL, '1' );
inst6_2 : LUT6 generic map (INIT => x"9669ff009669ff00" ) port map (Y(5), X(0), X(3), X(4), X(5), SEL, '1' );
inst6_4 : LUT6_2 generic map (INIT => x"5555aaaa9696ff00" ) port map (Y(4), Y(1), X(1), X(2), X(3), X(4), SEL, '1' );
inst6_5 : LUT6_2 generic map (INIT => x"3cc3cccc6666f0f0" ) port map (Y(7), Y(6), X(0), X(6), X(7), H, SEL, '1' );

end Behavioral;

