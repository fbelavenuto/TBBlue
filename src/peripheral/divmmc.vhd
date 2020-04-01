--
-- TBBlue / ZX Spectrum Next project
-- Copyrights:
-- (C) 2011 Mike Stirling
-- (C) 2015 Fabio Belavenuto
-- (C) 2015 Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- Emulation of DivMMC interface
--

---
--- DivMMC I/O ports:
--- E3 - Register
--- E7 - card /CS
--- EB - SPI interface
---

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divmmc is
	port (
		clk_master_i	: in    std_logic;
		-- CPU
		clock				: in    std_logic;
		reset_i			: in    std_logic;
		cpu_a				: in    std_logic_vector(15 downto 0);
		cpu_wr_n			: in    std_logic;
		cpu_rd_n			: in    std_logic;
		cpu_mreq_n		: in    std_logic;
		cpu_ioreq_n		: in    std_logic;
		cpu_m1_n			: in    std_logic;
		di					: in    std_logic_vector(7 downto 0);
		do					: out   std_logic_vector(7 downto 0);
		-- SD card interface
		spi_cs			: out   std_logic;
		sd_cs0			: out   std_logic;
		sd_sclk			: out   std_logic;
		sd_mosi			: out   std_logic;
		sd_miso			: in    std_logic;
		-- NMI
		nmi_button_n	: in    std_logic;
		nmi_to_cpu_n	: out   std_logic;
		-- Paging control for external RAM/ROM banks
		no_automap		: in    std_logic;
		ram_bank			: out   std_logic_vector(5 downto 0);
		
		--sinais pra rom e ram
		ram_en_o			: out   std_logic;
		rom_en_o			: out   std_logic;
		dout				: out   std_logic;
		-- Debug
		D_mapterm_o		: out   std_logic;
		D_automap_o		: out   std_logic
	);
end entity;

architecture rtl of divmmc is

	signal sck_delayed	: std_logic;
	signal counter			: unsigned(3 downto 0);
	-- Shift register has an extra bit because we write on the
	-- falling edge and read on the rising edge
	signal shift_reg		: std_logic_vector(8 downto 0);
	signal portE3_reg		: std_logic_vector(7 downto 0);
	signal portEB_reg		: std_logic_vector(7 downto 0);

	signal mreq_dly_s		: std_logic;
	signal mapterm			: std_logic;
	signal mapcond			: std_logic;
	signal automap			: std_logic;
	
	signal conmem			: std_logic;
	signal mapram			: std_logic;
	
	signal divmmc_map_00_rom	: std_logic	;
	signal divmmc_map_00_ram3	: std_logic	;
	signal divmmc_map_01_ram	: std_logic	;
	signal enable					: std_logic;
	signal disable_nmi			: std_logic;

begin

	nmi_to_cpu_n <=  '0' when nmi_button_n = '0' and  disable_nmi = '0' else '1';

-- DivMMC enables
	divmmc_map_00_rom  <= '1' when cpu_a(15 downto 13) = "000" and conmem = '1' and cpu_rd_n = '0'	else '0';	-- Indica se devemos mapear a ROM da DivMMC na pagina 0.0
	divmmc_map_00_ram3 <= '1' when cpu_a(15 downto 13) = "000" and mapram = '1' and conmem = '0'		else '0';	-- Indica se devemos mapear banco 3 da RAM somente leitura na pagina 0.0 (simula ROM)
	divmmc_map_01_ram  <= '1' when cpu_a(15 downto 13) = "001" and (mapram = '1' or conmem = '1')	else '0';	-- Indica se devemos mapear a RAM da DivMMC na pagina 0.1


	rom_en_o	<= divmmc_map_00_rom;
	ram_en_o	<= '1' when cpu_mreq_n = '0' and	(																								-- Habilita RAM para DivMMC:
									 (divmmc_map_00_ram3 = '1' and cpu_rd_n = '0') or 														-- Se MAPRAM estiver ativo, habilita RAM de 0000 a 1FFF somente para leitura
									 (divmmc_map_01_ram = '1' and mapram = '0') or															-- Se MAPRAM estiver desabilita, RAM entre 2000 e 3FFF pode ler e escrever em qualquer banco
									 (divmmc_map_01_ram = '1' and mapram = '1' and portE3_reg(5 downto 0) = "000011" and cpu_rd_n = '0')	-- Se banco 3 for mapeado entre 2000 e 3FFF quando MAPRAM estiver ativo, somente leitura
								 )                                                                      else '0';

	enable      <= '1' when cpu_ioreq_n = '0' and cpu_m1_n = '1' and
	                       cpu_a(7 downto 4) = X"E" 	else '0';								-- Decodifica portas DivMMC
					 
					 

	-- Leitura das portas
	DO <= portEB_reg			when enable = '1' and cpu_a(3 downto 0) = X"B" and cpu_rd_n = '0'  else			-- Leitura porta EB
			(others => '1');
		
	dout <= '1' when enable = '1' and cpu_a(3 downto 0) = X"B" and cpu_rd_n = '0'  else	'0';

	-- M1 = 0 quando a CPU está lendo um byte da memória e será uma instrução que será decodificada.
	-- M1 = 1 quando a CPU está lendo um byte da memória e não será uma instrução, é um parâmetro.

	-- MAPTERM
	-- Detectar quando a CPU está lendo uma instrução (FETCH) (M1 = 0) em alguns endereços:
	mapterm <= '1' when cpu_m1_n = '0' and no_automap = '0' and
			(cpu_a = X"0000" or cpu_a = X"0008" or cpu_a = X"0038" or 
			 cpu_a = X"0066" or cpu_a = X"04C6" or cpu_a = X"0562")									else '0';

	process (clk_master_i)
	begin
		if rising_edge(clk_master_i) then
			mreq_dly_s <= cpu_mreq_n;
		end if;
	end process;

	-- MAPCOND
	-- Recebe 1 quando a CPU está fazendo o fetch da instrução nos endereços de auto-mapeamento ou
	-- imediatamente quando há um FETCH entre 3D00 e 3DFF (vai a 1 para segurar o auto-mapeamento)
	-- Só vai a 0 (deixa de ser 1) se a CPU terminar um FETCH nos endereços de 1FF8 a 1FFF (M1 = 0)
	process (reset_i, mreq_dly_s)
	begin
		if reset_i = '1' then
			mapcond <= '0';
		elsif (falling_edge(mreq_dly_s)) then
			if mapterm = '1' or 
						(cpu_a(15 downto 8) = X"3D" and cpu_m1_n = '0') or
						(mapcond = '1' and (cpu_a(15 downto 3) /= "0001111111111" or cpu_m1_n = '1')) then
				mapcond <= '1';
			else
				mapcond <= '0';
			end if;
		end if;
	end process;

	-- Atrasa 1 ciclo de /MREQ para chavear a região de 0000 a 3FFF do spectrum para a ROM/RAM da DivMMC
	-- /MREQ baixa novamente após o FETCH quando está começando uma nova leitura ou é um ciclo de REFRESH
	-- O auto-mapeamento é feito imediatamente caso o FETCH aconteça entre 3D00 e 3DFF
	process (reset_i, cpu_mreq_n)
	begin
		if reset_i = '1' then
			automap <= '0';
		elsif (falling_edge(cpu_mreq_n)) then
			if no_automap = '0' and (mapcond = '1' or (cpu_a(15 downto 8) = X"3D" and cpu_m1_n = '0')) then
				automap <= '1';
			else
				automap <= '0';
			end if;
		end if;
	end process;

	-- Paging control outputs from register
	disable_nmi <= mapcond;										-- Indica para o módulo TOP bloquear a interrupção NMI
	conmem      <= portE3_reg(7) or automap;				-- Indica para o módulo TOP chavear a ROM da DivMMC
	mapram      <= portE3_reg(6);								-- Indica para o módulo TOP chavear o banco 3 da RAM como se fosse uma ROM entre 0000 e 1FFF
	ram_bank    <= portE3_reg(5 downto 0);					-- Indica para o módulo TOP qual banco da RAM chavear entre 2000 e 3FFF (até 512K)

	-- Paging register writes (porta E3 controla CONMEM, MAPRAM e banco da RAM)
	process(clock, reset_i)
	begin
		if reset_i = '1' then
			portE3_reg <= (others => '0');
		elsif rising_edge(clock) then
			if enable = '1' and cpu_a(3 downto 0) = X"3" and cpu_wr_n = '0' then		-- Escrita porta E3
				portE3_reg <= di;
			end if;
		end if;
	end process;

	--------------------------------------------------
	-- Essa parte lida com a porta SPI por hardware --
	--      Implementa um SPI Master Mode 0         --
	--------------------------------------------------

	-- Chip selects (somente 1 /CS, pois a DE1 tem somente 1 soquete para cartão SD)
	process(clock, reset_i)
	begin
		if reset_i = '1' then
			spi_cs <= '1';
			sd_cs0 <= '1';
		elsif rising_edge(clock) then
			if enable = '1' and cpu_wr_n = '0' and cpu_a(3 downto 0) = X"7"  then		-- Escrita porta E7 
				-- The two chip select outputs are controlled directly
				-- by writes to the lowest two bits of the control register
				spi_cs		<= di(7);
				sd_cs0      <= di(0);
			end if;
		end if;
	end process;

	-- SD card outputs from clock divider and shift register
	sd_sclk  <= sck_delayed;
	sd_mosi  <= shift_reg(8);

	-- Atrasa SCK para dar tempo do bit mais significativo mudar de estado e acertar MOSI antes do SCK
	process (clock, reset_i)
	begin
		if reset_i = '1' then
			sck_delayed <= '0';
		elsif rising_edge(clock) then
			sck_delayed <= not counter(0);
		end if;
	end process;

	-- SPI write
	process(clock, reset_i)
	begin		
		if reset_i = '1' then
			shift_reg  <= (others => '1');
			portEB_reg <= (others => '1');
			counter    <= "1111"; -- Idle
		elsif rising_edge(clock) then
			if counter = "1111" then
				-- Store previous shift register value in input register
				portEB_reg <= shift_reg(7 downto 0);
				shift_reg(8) <= '1';			-- MOSI repousa em '1'

				-- Idle - check for a bus access
				if enable = '1' and cpu_a(3 downto 0) = X"B"  then		-- Escrita ou leitura na porta EB 
					-- Write loads shift register with data
					-- Read loads it with all 1s
					if cpu_rd_n = '0' then
						shift_reg <= (others => '1');								-- Uma leitura seta 0xFF para enviar e dispara a transmissão
					else
						shift_reg <= di & '1';										-- Uma escrita seta o valor a enviar e dispara a transmissão
					end if;
					counter <= "0000"; -- Initiates transfer
				end if;
			else
				counter <= counter + 1;												-- Transfer in progress

				if sck_delayed = '0' then
					shift_reg(0) <= sd_miso;										-- Input next bit on rising edge
				else
					shift_reg <= shift_reg(7 downto 0) & '1';					-- Output next bit on falling edge
				end if;
			end if;
		end if;
	end process;

	-- Debug
	D_mapterm_o	<= mapcond;
	D_automap_o	<= automap;

end architecture;
