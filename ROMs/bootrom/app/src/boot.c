/*
TBBlue / ZX Spectrum Next project

Copyright (c) 2015 Fabio Belavenuto & Victor Trucco

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "hardware.h"
#include "vdp.h"
#include "ff.h"

/* Defines */

//                    12345678901234567890123456789012
const char TITLE[] = "         TBBLUE BOOT ROM        ";
//const char TITLE[] = "    ZX Spectrum Next Dev Kit    ";


/* Variables */
FATFS		FatFs;		/* FatFs work area needed for each volume */
FIL			Fil, Fil2;	/* File object needed for each open file */
FRESULT		res;

unsigned char scandoubler = 1;
unsigned char freq5060 = 0;
unsigned char enh_ula = 1;
unsigned char timex   = 0;
unsigned char psgmode = 0;
unsigned char divmmc = 1;
unsigned char mf = 1;
unsigned char joystick1 = 0;
unsigned char joystick2 = 0;
unsigned char ps2 = 0;
unsigned char lightpen = 0;
unsigned char scanlines = 0;
unsigned char menu_default = 0;
unsigned char menu_cont = 0;
unsigned char config_changed = 0;
unsigned char dac = 0;
unsigned char ena_turbo = 1;
unsigned char ntsc = 0;
unsigned char turbosound = 0;

char			line[256], temp[256], *filename;
char			romesxmmc[14] = ESXMMC_FILE, romm1[14] = MF1_FILE, romm128[14] = MF128_FILE, romm3[14] = MF3_FILE;
char			*comma1, *comma2;
char			titletemp[32];
char			romfile[14];
unsigned char	l, found = 0;
unsigned char	opc = 0;
unsigned int	bl = 0;
unsigned char	mode = 0;

/* Private functions */

/*******************************************************************************/
void display_error(const unsigned char *msg)
{
	l = 16 - strlen(msg)/2;

	vdp_setcolor(COLOR_RED, COLOR_BLACK, COLOR_WHITE);
	vdp_cls();
	vdp_setcolor(COLOR_RED, COLOR_BLUE, COLOR_WHITE);
	vdp_setflash(0);
	vdp_prints(TITLE);
	vdp_setcolor(COLOR_RED, COLOR_BLACK, COLOR_WHITE);
	vdp_setflash(1);
	vdp_gotoxy(l, 12);
	vdp_prints(msg);
	ULAPORT = COLOR_RED;
	for(;;);
}

/*******************************************************************************/
void error_loading(char e)
{
	vdp_prints("ERROR!!");
	vdp_putchar(e);
	ULAPORT = COLOR_RED;
	for(;;);
}

/*******************************************************************************/
void prints_help()
{
//                       11111111112222222222333
//              12345678901234567890123456789012
	vdp_prints("  F1      - Hard Reset\n");
	vdp_prints("  F2      - Toggle scandoubler\n");
	vdp_prints("  F3      - Toggle 50/60 Hz\n");
	vdp_prints("  F4      - Soft Reset\n");
	vdp_prints("  F7      - Toggle scanlines\n");
	vdp_prints("  F8      - Toggle turbo\n");
	vdp_prints("  F9      - Multiface button\n");
	vdp_prints("  F10     - DivMMC button\n");
	vdp_prints("  SHIFT   - Caps Shift\n");
	vdp_prints("  CONTROL - Symbol Shift\n");
	vdp_prints("\n");
	vdp_prints("  Hold SPACE while power-up or\n");
	vdp_prints("  on Hard Reset to start\n");
	vdp_prints("  the configurator.\n");
	vdp_prints("\n");
}

/*******************************************************************************/
void load_and_start()
{
	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_WHITE);
	REG_NUM = REG_RAMPAGE;
	if (divmmc == 1) {
		vdp_prints("Loading ESXMMC:\n");
		vdp_prints(romesxmmc);
		vdp_prints(" ... ");
		strcpy(temp, NEXT_DIRECTORY);
		strcat(temp, romesxmmc);
		res = f_open(&Fil, temp, FA_READ);
		if (res != FR_OK) {
			error_loading('O');
		}
		REG_VAL = RAMPAGE_ROMDIVMMC;
		res = f_read(&Fil, (unsigned char *)0, 8192, &bl);
		if (res != FR_OK || bl != 8192) {
			error_loading('R');
		}
		f_close(&Fil);
		vdp_prints("OK!\n");
		REG_VAL = RAMPAGE_RAMDIVMMC;
		__asm__("ld a, #0\n");			// Zeroing RAM DivMMC
		__asm__("ld hl, #0\n");
		__asm__("ld de, #1\n");
		__asm__("ld bc, #16383\n");
		__asm__("ldir\n");
	}

	if (mf == 1) {
		switch ( mode ) {
			case 0:
				filename = romm1;
			break;
			
			case 1:
				filename = romm128;
			break;
			
			case 2:
				filename = romm3;
			break;
		}
	
		vdp_prints("Loading Multiface ROM:\n");
		vdp_prints(filename);
		vdp_prints(" ... ");
		strcpy(temp, NEXT_DIRECTORY);
		strcat(temp, filename);
		res = f_open(&Fil, temp, FA_READ);
		if (res != FR_OK) {
			error_loading('O');
		}
		REG_VAL = RAMPAGE_ROMMF;
		res = f_read(&Fil, (unsigned char *)0, 8192, &bl);
		if (res != FR_OK || bl != 8192) {
			error_loading('R');
		}
		f_close(&Fil);
		vdp_prints("OK!\n");
	}
	
	vdp_prints("Loading ROM:\n");
	vdp_prints(romfile);
	vdp_prints(" ... ");

	// Load 16K
	strcpy(temp, NEXT_DIRECTORY);
	strcat(temp, romfile);
	res = f_open(&Fil, temp, FA_READ);
	if (res != FR_OK) {
		error_loading('O');
	}
	REG_VAL = RAMPAGE_ROMSPECCY;
	res = f_read(&Fil, (unsigned char *)0, 16384, &bl);
	if (res != FR_OK || bl != 16384) {
		error_loading('R');
	}
	// If Speccy > 48K, load more 16K
	if (mode > 0) {
		REG_VAL = RAMPAGE_ROMSPECCY+1;
		res = f_read(&Fil, (unsigned char *)0, 16384, &bl);
		if (res != FR_OK || bl != 16384) {
			error_loading('R');
		}
	}
	// If +2/+3e, load more 32K
	if (mode > 1) {
		REG_VAL = RAMPAGE_ROMSPECCY+2;
		res = f_read(&Fil, (unsigned char *)0, 16384, &bl);
		if (res != FR_OK || bl != 16384) {
			error_loading('R');
		}
		REG_VAL = RAMPAGE_ROMSPECCY+3;
		res = f_read(&Fil, (unsigned char *)0, 16384, &bl);
		if (res != FR_OK || bl != 16384) {
			error_loading('R');
		}
	}
	f_close(&Fil);
	vdp_prints("OK!\n");
	REG_NUM = REG_MACHTYPE;
	REG_VAL = (mode+1) << 3 | (mode+1);	// Set machine (and timing)
	REG_NUM = REG_RESET;
	REG_VAL = RESET_SOFT;				// Soft-reset
	for(;;);
}

/*******************************************************************************/
/*
static void make_config_file()
{
	res = f_open(&Fil2, CONFIG_FILE, FA_WRITE | FA_CREATE_ALWAYS);
	if (res != FR_OK) {
		//             12345678901234567890123456789012
		display_error("Error making 'config.ini'!");
	}
	f_puts(";Menu format\n", &Fil2);
	f_puts(";menu=<title>,<mode>,<ROM file>\n", &Fil2);
	f_puts(";\n", &Fil2);
	f_puts("; ZX type:\n", &Fil2);
	f_puts("; 0 = Spectrum 48K (ROM must be 16K)\n", &Fil2);
	f_puts("; 1 = Spectrum 128K (ROM must be 32K)\n", &Fil2);
	f_puts("; 2 = Spectrum 3e (ROM must be 64K)\n\n", &Fil2);
	f_puts("; Joystick:\n", &Fil2);
	f_puts("; 0 = Sinclair, 1 = Kempston, 2 = Cursor\n\n", &Fil2);
	f_puts("; Initial configuration\n", &Fil2);
	f_puts("scandoubler=1\n", &Fil2);
	f_puts("50_60hz=0\n", &Fil2);
	f_puts("ntsc=0\n", &Fil2);
	f_puts("enh_ula=1\n", &Fil2);
	f_puts("timex=0\n", &Fil2);
	f_puts("psgmode=0\n", &Fil2);
	f_puts("turbosound=0\n", &Fil2);
	f_puts("divmmc=1\n", &Fil2);
	f_puts("mf=1\n", &Fil2);
	f_puts("joystick1=0\n", &Fil2);
	f_puts("joystick2=0\n", &Fil2);
	f_puts("ps2=0\n", &Fil2);
	f_puts("lightpen=0\n", &Fil2);
	f_puts("scanlines=0\n", &Fil2);
	f_puts("dac=0\n", &Fil2);
	f_puts("turbo=1\n", &Fil2);
	f_puts("; Menu\n", &Fil2);
	f_puts("default=2\n", &Fil2);
	f_puts("menu=TK90X,0,tk90x.rom\n", &Fil2);
	f_puts("menu=TK95,0,tk95.rom\n", &Fil2);
	f_puts("menu=Spectrum 48K,0,48.rom\n", &Fil2);
	f_puts("menu=Spectrum 128K,1,128.rom\n", &Fil2);
	f_puts("menu=Spectrum +3e,2,3e.rom\n", &Fil2);
	f_puts("menu=ZX80,1,zx80.rom\n", &Fil2);
	f_puts("menu=ZX81,1,zx81.rom\n", &Fil2);
	f_puts("menu=Jupiter Ace,1,ace.rom\n", &Fil2);
	f_puts("\n", &Fil2);
	f_close(&Fil2);
}
*/

/* Public functions */

/*******************************************************************************/
unsigned long get_fattime()
{
	return 0x44210000UL;
}

/*******************************************************************************/
void main()
{
	long i=0;
	unsigned int error_count = 11;
	
	vdp_init();
	vdp_setcolor(COLOR_BLACK, COLOR_BLUE, COLOR_WHITE);
	vdp_prints(TITLE);
//	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_LGREEN);
	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_WHITE);

	REG_NUM = REG_MACHTYPE;
	REG_VAL = 0;						// disable bootrom

	vdp_gotoxy(0,2);
	prints_help();

START:
	--error_count;
	f_mount(&FatFs, "", 0);		/* Give a work area to the default drive */
/*
	res = f_open(&Fil, CONFIG_FILE, FA_READ);
	if (res != FR_OK) {
		make_config_file();
	}
*/
	res = f_open(&Fil, CONFIG_FILE, FA_READ);
	if (res != FR_OK) {
		if (error_count > 0) {
			goto START;
		}
		//             12345678901234567890123456789012
		display_error("Error opening 'config.ini'!");
	}

	// Read configuration
	while(f_eof(&Fil) == 0) {
		if (!f_gets(line, 255, &Fil)) {
			if (error_count > 0) {
				goto START;
			}
			//             12345678901234567890123456789012
			display_error("Error reading configuration!");
		}
		if (line[0] == ';')
			continue;
		line[strlen(line)-1] = '\0';
		if (strncmp(line, "scandoubler=", 12) == 0) {
			scandoubler = atoi(line+12);
		} else if (strncmp(line, "50_60hz=", 8) == 0) {
			freq5060 = atoi(line+8);
		} else if (strncmp(line, "ntsc=", 5) == 0) {
			ntsc = atoi(line+5);
		} else if (strncmp(line, "enh_ula=", 8) == 0) {
			enh_ula = atoi(line+8);
		} else if (strncmp(line, "timex=", 6) == 0) {
			timex = atoi(line+6);
		} else if (strncmp(line, "psgmode=", 8) == 0) {
			psgmode = atoi(line+8);
		} else if (strncmp(line, "turbosound=", 11) == 0) {
			turbosound = atoi(line+11);
		} else if (strncmp(line, "divmmc=", 7) == 0) {
			divmmc = atoi(line+7);
		} else if (strncmp(line, "mf=", 3) == 0) {
			mf = atoi(line+3);
		} else if (strncmp(line, "joystick1=", 10) == 0) {
			joystick1 = atoi(line+10);
		} else if (strncmp(line, "joystick2=", 10) == 0) {
			joystick2 = atoi(line+10);
		} else if (strncmp(line, "ps2=", 4) == 0) {
			ps2 = atoi(line+4);
		} else if (strncmp(line, "dac=", 4) == 0) {
			dac = atoi(line+4);
		} else if (strncmp(line, "lightpen=", 9) == 0) {
			lightpen = atoi(line+9);
		} else if (strncmp(line, "scanlines=", 10) == 0) {
			scanlines = atoi(line+10);
		} else if (strncmp(line, "turbo=", 6) == 0) {
			ena_turbo = atoi(line+6);
		} else if (strncmp(line, "default=", 8) == 0) {
			menu_default = atoi(line+8);
		} else if (strncmp(line, "menu=", 5) == 0) {
			comma1 = strchr(line, ',');
			if (comma1 == 0)
				continue;
			memset(temp, 0, 255);
			memcpy(temp, line+5, (comma1-line-5));
			strcpy(titletemp, temp);
			++comma1;
			comma2 = strchr(comma1, ',');
			if (comma2 == 0) {
				continue;
			}
			memset(temp, 0, 255);
			memcpy(temp, comma1, (comma2-comma1));
			mode = atoi(temp);
			++comma2;
			strcpy(romfile, comma2);
			if (menu_cont == menu_default) {
				++menu_cont;
				found = 1;
				break;
			}
			++menu_cont;
		}
	}
	f_close(&Fil);
	if (menu_cont == 0) {
		if (error_count > 0) {
			goto START;
		}
		//             12345678901234567890123456789012
		display_error("No configuration read!");
	}
	if (!found) {
		if (error_count > 0) {
			goto START;
		}
		//             12345678901234567890123456789012
		display_error("Error in configuration!");
	}
	// Check joysticks combination
	if ((joystick1 == 1 && joystick2 == 1) ||
		(joystick1 == 2 && joystick2 == 2) ||
		(joystick1 == 0 && joystick2 == 2)) {
		joystick2 = 0;
	}

	// Set peripheral config.
	REG_NUM = REG_PERIPH1;
	opc = joystick1 << 6 | joystick2 << 4;	// bits 7-6 and 5-4
	if (enh_ula)     opc |= 0x08;		// bit 3
	if (freq5060)    opc |= 0x04;		// bit 2
	if (scanlines)   opc |= 0x02;		// bit 1
	if (scandoubler) opc |= 0x01;		// bit 0
	REG_VAL = opc;

	REG_NUM = REG_PERIPH2;
	opc = psgmode; 						// bits 1-0
	if (ena_turbo)   opc |= 0x80;		// bit 7
	if (dac)         opc |= 0x40;		// bit 6
	if (lightpen)    opc |= 0x20;		// bit 5
	if (divmmc)      opc |= 0x10;		// bit 4
	if (mf)          opc |= 0x08;		// bit 3
	if (ps2)         opc |= 0x04;		// bit 2
	REG_VAL = opc;

	REG_NUM = REG_PERIPH3;
	opc = 0;
	if (timex)       opc |= 0x04;		// bit 2
	if (turbosound)  opc |= 0x02;		// bit 1
	if (ntsc)        opc |= 0x01;		// bit 0
	REG_VAL = opc;

	// Set timing
	REG_NUM = REG_MACHTYPE;
	REG_VAL = (mode+1) << 3;

	for(i=0;i<10000;i++);
	load_and_start();
}
