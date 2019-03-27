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
 use IEEE.NUMERIC_STD.ALL;

  Library UNISIM;
use UNISIM.vcomponents.all;

entity spl1_shr5 is	
  port ( clk : in std_logic;
         x0 : in std_logic;
         x1 : in std_logic;
         x2 : in std_logic;
         x3 : in std_logic;
         x4 : in std_logic;
         x5 : in std_logic;
         x6 : in std_logic;
         x7 : in std_logic;
         s : in std_logic;
         r : in std_logic;
         y : out std_logic
  ) ;
end entity ;
 
architecture Behavioral of spl1_shr5 is	

    signal h, f1, g1, g2 : std_logic;
	signal f_next, f_reg : std_logic;

begin
	
    -- joint monomials of F/G
    LUT00 : LUT6 GENERIC MAP (INIT => X"9e70a2806e80a280") PORT MAP(h, x0, x1, x2, x5, x6, x7);

    -- monomials unique to F
    LUT01 : LUT6 GENERIC MAP (INIT => X"d070208020802080") PORT MAP(f1, x1, x3, x4, x5, x6, x7);

    -- monomials unique to G
    LUT02 : LUT6 GENERIC MAP (INIT => X"48c06ae288000088") PORT MAP(g1, x0, x1, x2, x3, x4, x5);
    LUT03 : LUT4 GENERIC MAP (INIT => X"c808") PORT MAP(g2, x3, x4,  x6, x7);

    -- select F or G
    f_next <= (h xor f1 xor r) when s='0' else (h xor g1 xor g2 xor r);

	y <= f_reg; 

	seq : process( clk )
	begin
		if(rising_edge(clk)) then 
			f_reg <= f_next;
		end if;
	end process ;


end Behavioral ;
