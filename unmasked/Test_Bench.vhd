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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Test_Bench IS
END Test_Bench;
 
ARCHITECTURE behavior OF Test_Bench IS 
 
    COMPONENT BitSerialAESENC
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         Plaintext : IN  std_logic;
         Key : IN  std_logic;
         Ciphertext : OUT  std_logic;
         Done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal Plaintext : std_logic := '0';
   signal Key : std_logic := '0';

 	--Outputs
   signal Ciphertext : std_logic;
   signal Done : std_logic;

	-- test vector 1
--	signal TV_Key       : std_logic_vector(131 downto 0) := x"02b28ab097eaef7cf15d2154f16a6883c"; 
--	signal TV_Plaintext : std_logic_vector(131 downto 0) := x"0328831e0435a3137f6309807a88da234"; 
--	signal TV_Ciphertext: std_logic_vector(127 downto 0) := x"3902dc1925dc116a8409850b1dfb9732";

	-- test vector 2
	signal TV_Key       : std_logic_vector(131 downto 0) := x"02b28ab097eaef7cf15d2154f16a6883b"; 
	signal TV_Plaintext : std_logic_vector(131 downto 0) := x"0328831e0435a3137f6309807a88da23f"; 
	signal TV_Ciphertext: std_logic_vector(127 downto 0) := x"4b3016c97c52c8ff2b0c705c473ea9ed";

	signal Output : std_logic_vector(127 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
   signal COUNTER  : INTEGER := 131;
   signal COUNTER2 : INTEGER := 127;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BitSerialAESENC PORT MAP (
          clk => clk,
          reset => reset,
          Plaintext => Plaintext,
          Key => Key,
          Ciphertext => Ciphertext,
          Done => Done
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		IF(COUNTER >= 0) THEN
        Plaintext <= TV_Plaintext(COUNTER);
		  Key			<= TV_Key(COUNTER);
		  
		  IF (COUNTER > 0) THEN
				reset		<= '1';
		  ELSE
				reset		<= '0';
		  END IF;
		  
		  COUNTER 	<= COUNTER - 1;
      ELSE
        Plaintext <= '0';
        Key 		<= '0';
		  
		  reset		<= '0';

		  IF(Done = '1') THEN
				if (COUNTER2 >= 0) THEN
					Output 	<= Output(126 downto 0) & Ciphertext;
					COUNTER2 <= COUNTER2 - 1;
				else
					assert (Output  = TV_Ciphertext) report "not Correct!" severity warning;
					assert (Output /= TV_Ciphertext) report "Correct" severity warning;
					wait;
				end if;
		  END IF;
      END IF;

      wait for clk_period;
   end process;

END;
