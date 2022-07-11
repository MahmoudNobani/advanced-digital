
--------------------------------------
--dff3bit
--------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dff3 IS
PORT ( d : IN STD_LOGIC_vector(2 downto 0); clk: IN STD_LOGIC;Q : OUT STD_LOGIC_vector(2 downto 0)); 
END ENTITY dff3;

ARCHITECTURE arch OF dff3 IS
BEGIN
	PROCESS (clk)
	BEGIN
		IF ( rising_edge(clk) ) THEN
			q <= d;
		END IF;
	END PROCESS;
END ARCHITECTURE arch;

--------------------------------------
--inverter with delay 2ns
--------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_signed.ALL;

ENTITY inv IS 
	PORT ( a: IN STD_LOGIC; b: OUT STD_LOGIC);
END ENTITY inv; 

ARCHITECTURE arch OF inv IS
BEGIN
b <= not a after 2ns;
END ARCHITECTURE arch;

-------------------------------------
--nand with delay 5ns
-------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_signed.ALL;

ENTITY nand2 IS 
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY nand2; 

ARCHITECTURE arch OF nand2 IS
BEGIN
c <= a NAND b after 5ns;
END ARCHITECTURE arch;	 

------------------------------------
--nor with delay 5ns								
------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL; 

ENTITY nor2 is 
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY nor2;
ARCHITECTURE arch OF nor2 IS
BEGIN
c <= a nor b after 5ns;
END ARCHITECTURE arch;

-----------------------------------
--or with delay 7ns
-----------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL; 

ENTITY or2 is 
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY or2;
ARCHITECTURE arch OF or2 IS
BEGIN
c <= a OR b after 7ns;
END ARCHITECTURE arch;

------------------------------------
--and with delay 7 ns
------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL; 

ENTITY and2 is 
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY and2;
ARCHITECTURE arch OF and2 IS
BEGIN
c <= a and b after 7ns;
END ARCHITECTURE arch; 

------------------------------------
--xor with delay 12 ns
------------------------------------ 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY xor2 is
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY xor2;
ARCHITECTURE arch OF xor2 IS
BEGIN
C <= a xor b after 12ns;
END ARCHITECTURE arch;

------------------------------------
--xnor with a delay 9ns
------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY xnor2 is
	PORT ( a, b: IN STD_LOGIC; c: OUT STD_LOGIC);
END ENTITY xnor2;
ARCHITECTURE arch OF xnor2 IS
BEGIN
c <= a xnor b after 9ns;
END ARCHITECTURE arch; 

-------------------------------------
--comparater entity
-------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;	

entity Comp8bit is
	--generic (n: integer :=8);
	port ( a,b: in std_logic_vector(7 downto 0); 
	clk: in std_logic;
	output: out std_logic_vector(2 downto 0) );
end entity Comp8bit;

-------------------------------------
--stage 1
-------------------------------------

--1 Bit FA


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity FA is
	port ( a,b,cin: in std_logic; sum,cout: out std_logic);
end entity FA;

ARCHITECTURE arch OF FA IS
signal tmp1,tmp2,tmp3,tmp4,tmp5: std_logic;
BEGIN 
--sum <= cin XOR a XOR b;
sum1: entity work.xor2(arch)
	port map  (a,b,tmp1);--a xor b
sum2: entity work.xor2(arch)
	port map  (tmp1,cin,sum);--cin xor a xor b
--end of sum
--cout <= ( a AND b ) OR ( cin AND a ) OR ( b AND cin );
and1: entity work.and2(arch)
	port map  (a,b,tmp2);  --a and b
and2: entity work.and2(arch) 
	port map  (cin,a,tmp3); --a and cin
and3: entity work.and2(arch)
	port map  (b,cin,tmp4);--cin and b
or1: entity work.or2(arch)
	port map  (tmp2,tmp3,tmp5);--( a AND b ) OR ( cin AND a ) 
or2: entity work.or2(arch)
	port map  (tmp4,tmp5,cout);--( a AND b ) OR ( cin AND a ) OR ( b AND cin );
END ARCHITECTURE arch; 

--------------------------------------
--stage 1 ripple adder architecter 
--------------------------------------

architecture stage1 of Comp8bit is
signal s: std_logic_vector(8 downto 0);--for carries
signal Bcomp: std_logic_vector(7 downto 0);--for comp of b
signal res: std_logic_vector(7 downto 0); --for the result of subtraction
signal equals: std_logic;--equal signal
signal agt,bgt: std_logic;--a greater, b greater signals
signal overflow: std_logic;--overflow signals
signal tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8,tmp9,tmp10,tmp11: std_logic; --tmps
signal tmp12: std_logic_vector(2 downto 0);
--001 a>b
--010 a<b
--100 a=b

begin 
		
	--make b in 2 comp
	s(0) <= '1'; --for 2 comp 	
	BtoOnesComp: for i in 0 to 7 generate
		comp: entity work.xor2(arch)
	            port map  (b(i),s(0),Bcomp(i));
		--Bcomp(i)<=b(i) xor s(0); --for 1 comp
	end generate BtoOnesComp; 
	
	--subtractor
	Subtractor: for i in 0 to 7 generate --adder thats works as a subtractor (a+(-b))
		g: entity work.FA(arch)
			port map (a(i),Bcomp(i),s(i),res(i),s(i+1));
	end generate Subtractor; 
	
	--equals
	--y<=(res(0) nor res(1)) and (res(2) nor res(3)) and (res(4) nor res(5)) and (res(6) nor res(7));	--to check if the result is zero or not
	--equals<=y and '1';
	nor1: entity work.nor2(arch)
		port map  (res(0),res(1),tmp1);	 --res(0) nor res(1)
	nor2: entity work.nor2(arch)
		port map  (res(2),res(3),tmp2);	 --res(2) nor res(3)
	nor3: entity work.nor2(arch)
		port map  (res(4),res(5),tmp3);	--res(4) nor res(5)
	nor4: entity work.nor2(arch)
		port map  (res(6),res(7),tmp4);	--res(6) nor res(7)
	and1: entity work.and2(arch)
		port map  (tmp1,tmp2,tmp5);	
	and2: entity work.and2(arch)
		port map  (tmp3,tmp4,tmp6);
	and3: entity work.and2(arch)
		port map  (tmp5,tmp6,tmp7);	--y
	and4: entity work.and2(arch)
		port map  (tmp7,'1',equals); --if equals 1, if not 0

	--overflow
	--overflow<=s(7) xor s(8); --if overflow 1, if not 0
	overf: entity work.xor2(arch)
		port map  (s(7),s(8),overflow);
		
	--a greater than b
	--agt<=(not res(7) xor overflow) and (not equals);
	inv1: entity work.inv(arch)
		port map  (equals,tmp8);
	inv2: entity work.inv(arch)
		port map  (res(7),tmp9);
	xor1: entity work.xor2(arch)
		port map  (tmp9,overflow,tmp10);
	and5: entity work.and2(arch)
		port map  (tmp10,tmp8,agt);
	
	--b greater than a
	--bgt<=not agt and not equals;
	inv3: entity work.inv(arch)
		port map  (agt,tmp11);
	and6: entity work.and2(arch)
		port map  (tmp11,tmp8,bgt);
	
	--output
	
	tmp12 <= equals & bgt & agt;
	  --output <= equals & bgt & agt;	
	dff3: entity work.dff3(arch)
		port map (tmp12,clk,output);
	
	
end architecture stage1;

--------------------------------------------
--stage 2 magnitude comparator architicture
--------------------------------------------

--1 bit comparater

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--001 a>b
--010 a<b
--100 a=b
entity comp1bit is
	port ( a,b: in std_logic; eq,bgt,agt: out std_logic);
end entity comp1bit;

architecture arch of comp1bit is
signal tmp1,tmp2,tmp3,tmp4: std_logic;
begin
	--1 bit comparater
	inv1: entity work.inv(arch)
		port map  (a,tmp1);--tmp1=!a
	inv2: entity work.inv(arch)
		port map  (b,tmp2);--tmp2=!b
	agtb: entity work.and2(arch)--a>b
		port map  (a,tmp2,tmp3);
	bgta:  entity work.and2(arch)--b>a
		port map  (b,tmp1,tmp4);
	agt<=tmp3;
	bgt<=tmp4;
	equal: entity work.xnor2(arch)--b>a
		port map  (tmp3,tmp4,eq);
		
end architecture arch;


--stage 2 arch
architecture stage2 of Comp8bit is
signal eq,bgta,agtb: std_logic_vector(7 downto 0);
signal equals,agt,bgt: std_logic;	   
signal tmp1,tmp5: std_logic_vector(3 downto 0);	
signal tmp: std_logic_vector(6 downto 0);
signal tmp4: std_logic_vector(7 downto 0);
signal tmp2,tmp3,tmp6,tmp7,tmp8,tmp9: std_logic; --tmps	
signal tmp10: std_logic_vector(2 downto 0);

--001 a>b
--010 b>a
--100 a=b
begin
	 
	Comp: for i in 0 to 7 generate --compares each bit with the corresponding one
		comp1bit: entity work.comp1bit(arch)
			port map (a(i),b(i),eq(i),bgta(i),agtb(i));
	end generate Comp;	 
	
	
	--equal
	--we have the vaules of eq for each bit, now we just and them together, to get the value of equals
	eq1: for i in 0 to 3 generate 
		--eq(0) and eq1 = tmp1(0), eq2 and eq3 = tmp1(1), eq4 and eq5 = tmp1(2), eq6 and eq7 = tmp1(3)
		and1: entity work.and2(arch)
		    port map  (eq(2*i),eq(2*i+1),tmp1(i));  
	end generate eq1;
	and2: entity work.and2(arch)--tmp1(0) and tmp1(1)
		port map  (tmp1(0),tmp1(1),tmp2);
	and3: entity work.and2(arch)--tmp1(2) and tmp1(3)
		port map  (tmp1(2),tmp1(3),tmp3);
	and4: entity work.and2(arch)--tmp2 and tmp3
		port map  (tmp2,tmp3,equals);
		
	--a>b
	--agtb(7)+e7*agtb(6)+e7*e6*agtb(5)+e7*e6*e5*agtb(4)+e7*e6*e5*e4*agtb(3)+e7*e6*e5*e4*e3*agtb(2)+e7*e6*e5*e4*e3*e2*agtb(1)+e7*e6*e5*e4*e3*e2*e1*agtb(0)
	--which is troublesome, so will and e first then with agtb
	--note that agtb(7) is a sign bit so we use bgta(7), just for this case and this case only
	
	--and of eq
	--e7<=tmp6
	--e7*e6<=tmp5
	--e7*e6*e5<=tmp4
	--e7*e6*e5*e4<=tmp3	
	--e7*e6*e5*e4*e3<=tmp2 
	--e7*e6*e5*e4*e3*e2<=tmp1
	--e7*e6*e5*e4*e3*e2*e1<=tmp0
	tmp(6)<=eq(7);
	andeq: for i in 0 to 5 generate
		and5: entity work.and2(arch)
		  port map  (tmp(6-i),eq(6-i),tmp(5-i));
	end generate andeq;
	
	--now i will start with the and between e and agtb equation
	--e7*agtb(6)+e7*e6*agtb(5)+e7*e6*e5*agtb(4)+e7*e6*e5*e4*agtb(3)+e7*e6*e5*e4*e3*agtb(2)+e7*e6*e5*e4*e3*e2*agtb(1)+e7*e6*e5*e4*e3*e2*e1*agtb(0)
	andgt: for i in 0 to 6 generate
		and6: entity work.and2(arch)
	      port map  (tmp(6-i),agtb(6-i),tmp4(i)); 
	end generate andgt;
	
	--note that agtb(7) is a sign bit so we use bgta(7), just for this case and this case only
	tmp4(7)<=bgta(7);
	
	
	--now i will start with the or
	--agtb(7)+e7*agtb(6)+e7*e6*agtb(5)+e7*e6*e5*agtb(4)+e7*e6*e5*e4*agtb(3)+e7*e6*e5*e4*e3*agtb(2)+e7*e6*e5*e4*e3*e2*agtb(1)+e7*e6*e5*e4*e3*e2*e1*agtb(0)
	orgt: for i in 0 to 3 generate 
		--eq(0) and eq1 = tmp1(0), eq2 and eq3 = tmp1(1), eq4 and eq5 = tmp1(2), eq6 and eq7 = tmp1(3)
		or1: entity work.or2(arch)
		    port map  (tmp4(2*i),tmp4(2*i+1),tmp5(i));  
	end generate orgt;
	
	or2: entity work.or2(arch)--tmp5(0) and tmp5(1)
		port map  (tmp5(0),tmp5(1),tmp6);
	or3: entity work.or2(arch)--tmp5(2) and tmp5(3)
		port map  (tmp5(2),tmp5(3),tmp7);
	or4: entity work.or2(arch)--tmp6 and tmp7
		port map  (tmp6,tmp7,agt);--now we got agt
		
	--lastly bgt
	--bgt is not agt and not equals
	
	inv1: entity work.inv(arch)
		port map (equals,tmp8);
	inv2: entity work.inv(arch)
		port map (agt,tmp9);
	and6: entity work.and2(arch)
		port map  (tmp8,tmp9,bgt); 
		
	tmp10 <= equals & bgt & agt;
	--output <= equals & bgt & agt;	
	dff3: entity work.dff(arch)
		port map (tmp10,clk,output);	
	
end architecture stage2;

------------------------------------
--verification/testbenches
------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_signed.ALL;

--test generator
ENTITY TestGen IS
	PORT ( clk: IN STD_LOGIC;
	test1: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --a
	test2: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --b
	ExpectRes: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY TestGen;	

ARCHITECTURE arch OF TestGen IS	
--001 a>b
--010 b>a
--100 a=b
BEGIN
	PROCESS
	BEGIN
		FOR i IN -128 TO 127 LOOP
			FOR j IN -128 TO 127 LOOP
				-- Set the inputs to the comparater
				test1 <= CONV_STD_LOGIC_VECTOR(i,8);
				test2 <= CONV_STD_LOGIC_VECTOR(j,8);
				-- Calculate what the output of the comparater should be
				WAIT until rising_edge(clk);
				if i > j then  --a>b
					ExpectRes <= "001";	
				elsif j > i then --b>a
					ExpectRes <= "010";
				else  --b=a
					ExpectRes <= "100";
				end if;
			
			END LOOP;
		END LOOP;
		WAIT;
	END PROCESS;
END ARCHITECTURE arch;

--result analyzer
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.std_logic_signed.ALL;

--result_analyzer
ENTITY resultana IS
	PORT ( clk: IN STD_LOGIC;
	ExpectRes: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	CompRes: IN STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY resultana;

ARCHITECTURE arch OF resultana IS
--001 a>b
--010 b>a
--100 a=b
BEGIN
	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN-- Check whether output matches expectation
			ASSERT ExpectRes(2 DOWNTO 0) = CompRes
			REPORT "comparator output is incorrect"
			SEVERITY WARNING;
		END IF;
	END PROCESS;
END ARCHITECTURE arch;


-----------------------------------------------
--testbench for stage1
-----------------------------------------------	

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed;

ENTITY testbenchRA IS
END ENTITY testbenchRA;

ARCHITECTURE arch OF testbenchRA IS
SIGNAL clk: std_logic:='0';
--Declarations of test inputs and outputs
SIGNAL test1: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL test2: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL compres: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL ExpectRes: STD_LOGIC_VECTOR(2 DOWNTO 0);	

--001 a>b
--010 b>a
--100 a=b

BEGIN
	
	clk <= NOT clk AFTER 250 NS;
	-- Place one instance of test generation unit
	testgenerator: ENTITY work.TestGen(arch)
		PORT MAP ( clk, test1, test2, ExpectRes);
	-- Place one instance of the circit Under Test
	comparater: ENTITY work.comp8bit(stage1)
		PORT MAP ( test1, test2, clk, compres);
			-- Place one instance of the result analyzer
	resultanalyzer: ENTITY work.resultana(arch)
		port map (clk, ExpectRes, compres);
END ARCHITECTURE arch;


-----------------------------------------------
--testbench for stage2
-----------------------------------------------	

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_signed;

ENTITY testbenchMA IS
END ENTITY testbenchMA;

ARCHITECTURE arch OF testbenchMA IS
SIGNAL clk: std_logic:='0';
--Declarations of test inputs and outputs
SIGNAL test1: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL test2: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL compres: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL ExpectRes: STD_LOGIC_VECTOR(2 DOWNTO 0);	

--001 a>b
--010 b>a
--100 a=b

BEGIN
	
	clk <= NOT clk AFTER 100 NS;
	-- Place one instance of test generation unit
	testgenerator: ENTITY work.TestGen(arch)
		PORT MAP ( clk, test1, test2, ExpectRes);
	-- Place one instance of the circit Under Test
	comparater: ENTITY work.comp8bit(stage2)
		PORT MAP ( test1, test2, clk, compres);
			-- Place one instance of the result analyzer
	resultanalyzer: ENTITY work.resultana(arch)
		port map (clk, ExpectRes, compres);
		
END ARCHITECTURE arch;





