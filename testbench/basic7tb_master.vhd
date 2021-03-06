--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:15:46 12/02/2017
-- Design Name:   
-- Module Name:   /home/jackey/My_project/VHDL/cpu/basic7tb_master.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY basic7tb_master IS
END basic7tb_master;
 
ARCHITECTURE behavior OF basic7tb_master IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         click : IN  std_logic;
         clk_50M : IN  std_logic;
         rst : IN  std_logic;
         data_ram1 : INOUT  std_logic_vector(15 downto 0);
         addr_ram1 : OUT  std_logic_vector(17 downto 0);
         OE_ram1 : OUT  std_logic;
         WE_ram1 : OUT  std_logic;
         EN_ram1 : OUT  std_logic;
         data_ram2 : INOUT  std_logic_vector(15 downto 0);
         addr_ram2 : OUT  std_logic_vector(17 downto 0);
         OE_ram2 : OUT  std_logic;
         WE_ram2 : OUT  std_logic;
         EN_ram2 : OUT  std_logic;
         seri_rdn : OUT  std_logic;
         seri_wrn : OUT  std_logic;
         seri_data_ready : IN  std_logic;
         seri_tbre : IN  std_logic;
         seri_tsre : IN  std_logic;
         dyp0 : OUT  std_logic_vector(6 downto 0);
         dyp1 : OUT  std_logic_vector(6 downto 0);
         led : OUT  std_logic_vector(15 downto 0);
         instruct : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal click : std_logic := '0';
   signal clk_50M : std_logic := '0';
   signal rst : std_logic := '0';
   signal seri_data_ready : std_logic := '0';
   signal seri_tbre : std_logic := '0';
   signal seri_tsre : std_logic := '0';
   signal instruct : std_logic_vector(15 downto 0) := (others => '0');

	--BiDirs
   signal data_ram1 : std_logic_vector(15 downto 0);
   signal data_ram2 : std_logic_vector(15 downto 0);

 	--Outputs
   signal addr_ram1 : std_logic_vector(17 downto 0);
   signal OE_ram1 : std_logic;
   signal WE_ram1 : std_logic;
   signal EN_ram1 : std_logic;
   signal addr_ram2 : std_logic_vector(17 downto 0);
   signal OE_ram2 : std_logic;
   signal WE_ram2 : std_logic;
   signal EN_ram2 : std_logic;
   signal seri_rdn : std_logic;
   signal seri_wrn : std_logic;
   signal dyp0 : std_logic_vector(6 downto 0);
   signal dyp1 : std_logic_vector(6 downto 0);
   signal led : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_50M_period : time := 20 ns;
	constant clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
          click => click,
          clk_50M => clk_50M,
          rst => rst,
          data_ram1 => data_ram1,
          addr_ram1 => addr_ram1,
          OE_ram1 => OE_ram1,
          WE_ram1 => WE_ram1,
          EN_ram1 => EN_ram1,
          data_ram2 => data_ram2,
          addr_ram2 => addr_ram2,
          OE_ram2 => OE_ram2,
          WE_ram2 => WE_ram2,
          EN_ram2 => EN_ram2,
          seri_rdn => seri_rdn,
          seri_wrn => seri_wrn,
          seri_data_ready => seri_data_ready,
          seri_tbre => seri_tbre,
          seri_tsre => seri_tsre,
          dyp0 => dyp0,
          dyp1 => dyp1,
          led => led,
          instruct => instruct
        );

   -- Clock process definitions
   clk_50M_process :process
   begin
		clk_50M <= '0';
		wait for clk_50M_period/2;
		clk_50M <= '1';
		wait for clk_50M_period/2;
   end process;
 
    click_process :process
   begin
		click <= '0';
		wait for clk_period/2;
		click <= '1';
		wait for clk_period/2;
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 70 ns;   

      wait for clk_period*10;

        rst <= '0';
        rst <= '0';
        wait for clk_period;
        rst <= '1';
        wait for clk_period;

        instruct <= "0110100000001000"; -- [0000] LI R0 0x08
        wait for clk_period; --IF
        instruct <= "0110100100001100"; -- [0001] LI R1 0x0C
        wait for clk_period;
        instruct <= "0100111101010000"; -- [0006] ADDIU R7 0x50     before R7=0x20; after R7=0x70
        wait for clk_period;
        instruct <= "1110000001101011"; -- [0007] SUBU R0 R3 R2
        wait for clk_period;
        instruct <= "0011001001010000"; -- [0008] SLL R2 R2 4
        wait for clk_period;
        instruct <= "1001111010000000"; -- [0009] LW R6 R4 0x00
        wait for clk_period;
        instruct <= "1110001110010001"; -- [000A] ADDU R3 R4 R4
		  wait for clk_period;
        instruct <= "1101100000100001"; -- [000B] SW R0 R1 0x01
        wait for clk_period;
		  instruct <= "1101100000100010"; -- [000C] SW R0 R1 0x02
        wait for clk_period;
		  instruct <= "1101100000100011"; -- [000D] SW R0 R1 0x03
        wait for clk_period;
		  instruct <= "1101100000100100"; -- [000E] SW R0 R1 0x04
        wait for clk_period;
		  instruct <= "1101100000100101"; -- [000F] SW R0 R1 0x05
        wait for clk_period;
        instruct <= "0010100000001000"; -- [0010] BNEZ R0 0x80
        wait for clk_period;
        instruct <= "0000100000000000"; -- NOP
        wait for clk_period;
    -- [0009]
        instruct <= "0110100010111111"; -- LI R0 0xBF
        wait for clk_period;
    -- [000A]
        instruct <= "0011000000010000"; -- SLL R0 R0 0x00
        wait for clk_period;
		  instruct <= "0110100110111111"; -- LI R1 oxBF
        wait for clk_period;
		  instruct <= "0011000100100000"; -- SLL R1 R1 0x00
		  wait for clk_period;
		  instruct <= "0100100100000001"; -- ADDIU R1 0x01       R6=0xBF01
		  wait for clk_period;
		  instruct <= "1001100100000000"; -- LW R1 R0 0x00
		  wait for clk_period;
        instruct <= "0000100000000000"; -- NOP
        wait for clk_period;	  
    -- [000B]
        instruct <= "1101100000100001"; -- SW R0 R1 0x01
        wait for clk_period;

      -- insert stimulus here 

      wait;
   end process;

END;
