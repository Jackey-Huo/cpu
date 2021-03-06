----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:30:49 11/23/2017 
-- Design Name: 
-- Module Name:    vga_ctrl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE, BASIC;
use IEEE.STD_LOGIC_1164.ALL;
use BASIC.HELPER.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_ctrl is
	Port(
		clk			: in std_logic; -- clock forced to be 50M
		rst			: in std_logic;

		disp_mode	: in std_logic_vector (2 downto 0);

		Hs			: out std_logic; -- line sync
		Vs			: out std_logic; -- field sync
		cache_wea	: out std_logic;
		ram2_read_enable		: out std_logic;
		
		-- character cache
		cache_WE			: in std_logic;
		cache_write_addr	: in std_logic_vector (12 downto 0);
		cache_write_data	: in std_logic_vector (7 downto 0);

		-- mem_addr is (17 downto 0) , mem_addr <= "00" & "111" & disp_addr
		disp_addr	: out std_logic_vector (17 downto 0);
		disp_data	: inout std_logic_vector (15 downto 0);

		r0, r1, r2, r3, r4, r5, r6, r7 : in std_logic_vector(15 downto 0);

		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end vga_ctrl;

architecture Behavioral of vga_ctrl is

component fontROM is
	port (
	clka: in std_logic;
	addra: in std_logic_vector(10 downto 0);
	douta: out std_logic_vector(7 downto 0));
end component;

component VGARAM is
	PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
end component;

component vga_ctrl_480 is 
	Port(
		clk					: in std_logic; -- clock forced to be 50M
		rst					: in std_logic;
		disp_mode			: in std_logic_vector (2 downto 0); -- select between different display app
		
		Hs 					: out std_logic; -- line sync
		Vs 					: out std_logic; -- field sync
		
		-- cache request
		cache_wea			: out std_logic;
		cache_read_addr		: out std_logic_vector (12 downto 0);
		cache_read_data		: in std_logic_vector (7 downto 0);

		fontROMAddr 		: out std_logic_vector (10 downto 0);
		fontROMData 		: in std_logic_vector (7 downto 0);

		-- ram2 request
		ram2_read_enable	: out std_logic;
		read_addr			: out std_logic_vector (17 downto 0);
		read_out			: inout std_logic_vector (15 downto 0);

		r0, r1, r2, r3, r4,r5,r6,r7 : in std_logic_vector(15 downto 0);
		PC : in std_logic_vector(15 downto 0);
		CM : in std_logic_vector(15 downto 0);
		Tdata : in std_logic_vector(15 downto 0);
		SPdata : in std_logic_vector(15 downto 0);
		IHdata : in std_logic_vector(15 downto 0);
		instruction : in std_logic_vector(15 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end component;

component vga_ctrl_768 is
	Port(
		clk : in std_logic; -- clock forced to be 50M
		rst : in std_logic;

		Hs : out std_logic; -- line sync
		Vs : out std_logic; -- field sync

		-- Concatenated color definition for input
		color : in std_logic_vector (8 downto 0);

		-- Separate color definition for output
		R : out std_logic_vector(2 downto 0);
		G : out std_logic_vector(2 downto 0);
		B : out std_logic_vector(2 downto 0)
	);
end component;

signal fontROMAddr : std_logic_vector (10 downto 0) := "00000000000";
signal fontROMData : std_logic_vector (7 downto 0) := x"00";
signal dr0, dr1, dr2, dr3, dr4, dr5, dr6, dr7 : std_logic_vector(15 downto 0) := x"0000";
signal dSP, dIH, dT, d_CM, dPC : std_logic_vector(15 downto 0) := x"0000";
signal x, y : integer := 0;

signal cache_read_addr : std_logic_vector (12 downto 0) := "0000000000000";
signal cache_read_data : std_logic_vector (7 downto 0) := x"00";

begin

	dr0<=r0;
	dr1<=r1;
	dr2<=r2;
	dr3<=r3;
	dr4<=r4;
	dr5<=r5;
	dr6<=r6;
	dr7<=r7;

	get_font : fontROM port map(
		clka => clk,
		addra => fontROMAddr,
		douta => fontROMData
	);

	vga_cache : VGARAM port map(
		clka 	=> clk,
		wea(0) 	=> cache_WE,
		addra 	=> cache_write_addr,
		dina 	=> cache_write_data,
		clkb 	=> clk,
		addrb 	=> cache_read_addr,
		doutb 	=> cache_read_data
	);

	vga480_disp : vga_ctrl_480 port map(
		clk => clk,
		rst => rst,
		disp_mode => disp_mode,
		Hs => Hs,
		Vs => Vs,
		cache_read_addr => cache_read_addr,
		cache_read_data => cache_read_data,
		fontROMAddr => fontROMAddr,
		fontROMData => fontROMData,
		read_addr => disp_addr,
		read_out => disp_data,
		cache_wea => cache_wea,
		ram2_read_enable => ram2_read_enable,
		r0=>dr0,
		r1=>dr1,
		r2=>dr2,
		r3=>dr3,
		r4=>dr4,
		r5=>dr5,
		r6=>dr6,
		r7=>dr7,
		PC => PC, -- : in std_logic_vector(15 downto 0);
		CM => CM, -- in std_logic_vector(15 downto 0);
		Tdata => TData, -- : in std_logic_vector(15 downto 0);
		SPdata => SPdata, -- : in std_logic_vector(15 downto 0);
		IHdata => IHdata, --: in std_logic_vector(15 downto 0);
		instruction => instruction,
		R => R,
		G => G,
		B => B
	);
end Behavioral;

