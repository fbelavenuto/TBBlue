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
#include "ff.h"				// read/write

/* Defines */

typedef struct {
	unsigned char type;
	unsigned char *title;
	unsigned char *var;
} configitem;

typedef struct {
	char			title[32];
	unsigned char	mode;
	char			romfile[14];
} mnuitem;

//                        12345678901234567890123456789012
const char TITLE[]     = "         TBBLUE BOOT ROM        ";

const char YESNO[2][4] = {"NO ","YES"};						// type 0
const char AYYM[3][4]  = {"AY ","YM ","OFF"};				// type 1
const char JOYS[3][7]  = {"Sincla","Kempst","Cursor"};		// type 2
const char PS_2[2][6]  = {"Keyb.","Mouse"};					// type 3
const char JOY2[2][5]  = {"JOY","M.LP"};					// type 4
const char  DAC[2][4]  = {"I2S","JAP"};					    // type 5
const char STEREO[2][4] = {"ABC","ACB"};					// type 6

FATFS		FatFs;		/* FatFs work area needed for each volume */
FIL			Fil;		/* File object needed for each open file */
FRESULT		res;

unsigned char divmmc[2]      = {1, 1};
unsigned char mf[2]          = {1, 1};
unsigned char psgmode[2]     = {0, 0};
unsigned char enh_ula[2]     = {1, 1};
unsigned char timex[2]       = {0, 0};
unsigned char freq5060[2]    = {1, 1};
unsigned char scandoubler[2] = {1, 1};
unsigned char joystick1[2]   = {0, 0};
unsigned char joystick2[2]   = {0, 0};
unsigned char ps2[2]         = {0, 0};
unsigned char lightpen[2]    = {0, 0};
unsigned char scanlines[2]   = {0, 0};
unsigned char dac[2]         = {0, 0};
unsigned char ena_turbo[2]   = {0, 0};
unsigned char ntsc[2]        = {0, 0};
unsigned char turbosound[2]  = {0, 0};
unsigned char stereomode[2]  = {0, 0};

unsigned char menu_default = 0;
unsigned char menu_cont = 0;
unsigned char button_up = 0;
unsigned char button_down = 0;
unsigned char button_left = 0;
unsigned char button_right = 0;
unsigned char button_enter = 0;
unsigned char button_e = 0;
unsigned char button_space = 0;
unsigned char config_changed = 0;

char			line[256], temp[256];
char			*comma1, *comma2;
unsigned char	mach_id, mach_version;
unsigned char	i, it, nl, l, c, t, r, y, lin, col, *value, type;
unsigned char	top, bottom, opc, posc;
unsigned int	bl = 0;
unsigned char	mode = 0;

// Order: line 0 col 0, line 0 col 1, line 1 col 0....
// Others
const configitem peripherals1[] = {
	//   123456789
	{0, "DivMMC",    divmmc },
	{0, "Multiface", mf },
	{1, "Sound",     psgmode },
	{0, "TurboSnd",  turbosound },
	{0, "Scandoubl", scandoubler },
	{0, "Scanline",  scanlines },
	{0, "60 Hz",     freq5060 },
	{0, "Ena Turbo", ena_turbo },
	{0, "Enh. ULA",  enh_ula },
	{0, "Timex",     timex },
	{2, "Joy 1",     joystick1 },
	{2, "Joy 2",     joystick2 },
//	{0, "Lightpen",  lightpen },
};
const unsigned char itemcount1 = sizeof(peripherals1) / sizeof(configitem);

// VTrucco
const configitem peripherals2[] = {
	//   123456789
	{0, "DivMMC",    divmmc },
	{0, "Multiface", mf },
	{0, "Enh. ULA",  enh_ula },
	{0, "Timex",     timex },
	{0, "60 Hz",     freq5060 },
	{5, "DAC",       dac },
	{1, "Sound",     psgmode },
	{6, "Stereo M.", stereomode },
	{0, "Scandoubl", scandoubler },
	{0, "Scanline",  scanlines },
	{0, "Lightpen",  lightpen },
	{3, "PS/2",      ps2 },
	{0, "Ena Turbo", ena_turbo },
};
const unsigned char itemcount2 = sizeof(peripherals2) / sizeof(configitem);

// FBLabs
const configitem peripherals3[] = {
	//   123456789
	{0, "DivMMC",    divmmc },
	{0, "Multiface", mf },
	{0, "Scandoubl", scandoubler },
	{0, "Scanline",  scanlines },
	{0, "Enh. ULA",  enh_ula },
	{0, "Timex",     timex },
	{0, "60 Hz",     freq5060 },
	{0, "Ena Turbo", ena_turbo },
	{1, "Sound",     psgmode },
	{6, "Stereo M.", stereomode },
	{2, "Joy 1",     joystick1 },
	{2, "Joy 2",     joystick2 },
	{4, "P.Joy2",    lightpen },
};
const unsigned char itemcount3 = sizeof(peripherals3) / sizeof(configitem);

// ZX-Uno
const configitem peripherals5[] = {
	//   123456789
	{0, "DivMMC",    divmmc },
	{0, "Multiface", mf },
	{1, "Sound",     psgmode },
	{0, "TurboSnd",  turbosound },
	{6, "Stereo M.", stereomode },
	{0, "Scanline",  scanlines },
	{0, "SCART",     scandoubler },
	{0, "NTSC",      ntsc },
	{0, "60 Hz",     freq5060 },
	{0, "Ena Turbo", ena_turbo },
	{0, "Enh. ULA",  enh_ula },
	{0, "Timex",     timex },
	{2, "Joy 1",     joystick1 },
	{2, "Joy 2",     joystick2 },
};
const unsigned char itemcount5 = sizeof(peripherals5) / sizeof(configitem);


configitem *peripherals = peripherals1;
unsigned char itemsCount = 0;

mnuitem menus[10];

/* Public functions */


/*******************************************************************************/
static void display_error(const unsigned char *msg) {

	l = 16 - strlen(msg)/2;

	vdp_setcolor(COLOR_BLACK, COLOR_BLUE, COLOR_WHITE);
	vdp_cls();
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
static void printVal() {

	switch (type) {
		case 0:
			vdp_prints(YESNO[*value]);
		break;
		
		case 1:
			vdp_prints(AYYM[*value]);
		break;
	
		case 2:
			vdp_prints(JOYS[*value]);
		break;

		case 3:
			vdp_prints(PS_2[*value]);
		break;

		case 4:
			vdp_prints(JOY2[*value]);
		break;
		
		case 5:
			vdp_prints(DAC[*value]);
		break;

		case 6:
			vdp_prints(STEREO[*value]);
		break;

	}
}

/*******************************************************************************/
static void show_peripherals() {

	// Check joysticks
	if ((joystick1[0] == 1 && joystick2[0] == 1) ||
		(joystick1[0] == 2 && joystick2[0] == 2) ||
		(joystick1[0] == 0 && joystick2[0] == 2)) {
		joystick2[0] = 0;
		config_changed = 1;
	}

	vdp_setfg(COLOR_LCYAN);
	vdp_gotoxy(0, 14);
	vdp_prints("Peripherals:\n");
	vdp_setfg(COLOR_GRAY);
	vdp_prints("(press 'E' to edit/cancel)\n");

	for (i = 0; i < itemsCount; i++) {
		lin = (i >> 1) + 17;
		col = ((i & 1) == 0) ? 0 : 16;
		vdp_gotoxy(col, lin);
		vdp_setfg(COLOR_WHITE);
		vdp_prints(peripherals[i].title);
		vdp_setfg(COLOR_LRED);
		vdp_gotox(col+9);
		value = peripherals[i].var;
		type = peripherals[i].type;
		printVal();
	}

	REG_NUM = REG_PERIPH1;				// send only 50/60, scandoubler and scanlines options
	opc = 0;
	if (freq5060[0])    opc |= 0x04;
	if (scanlines[0])   opc |= 0x02;
	if (scandoubler[0]) opc |= 0x01;
	REG_VAL = opc;
}

/*******************************************************************************/
static void readkeyb()
{
	button_up = 0;
	button_down = 0;
	button_left = 0;
	button_right = 0;
	button_enter = 0;
	button_e = 0;
	button_space = 0;

	while(1) {
		if ((HROW2 & 0x04) == 0) {
			button_e = 1;
			while(!(HROW2 & 0x04));
			return;
		}
		if ((HROW7 & 0x01) == 0) {
			button_space = 1;
			while(!(HROW7 & 0x01));
			return;
		}
		if ((HROW3 & 0x10) == 0) {
			button_left = 1;
			while(!(HROW3 & 0x10));
			return;
		}
		t = HROW4;
		if ((t & 0x10) == 0) {
			button_down = 1;
			while(!(HROW4 & 0x10));
			return;
		}
		if ((t & 0x08) == 0) {
			button_up = 1;
			while(!(HROW4 & 0x08));
			return;
		}
		if ((t & 0x04) == 0) {
			button_right = 1;
			while(!(HROW4 & 0x04));
			return;
		}
		if ((HROW6 & 0x01) == 0) {
			button_enter = 1;
			while(!(HROW6 & 0x01));
			return;
		}
		// Verify that the user has changed 50/60Hz or scandoubler by keyboard
		i = 0;
		REG_NUM = REG_PERIPH1;
		t = (REG_VAL & 0x07);
		if (freq5060[0] != ((t & 0x04) >> 2)) {
			freq5060[0] = (t & 0x04) >> 2;
			i = 1;
			config_changed = 1;
		}
		if (scanlines[0] != ((t & 0x02) >> 1)) {
			scanlines[0] = (t & 0x02) >> 1;
			i = 1;
			config_changed = 1;
		}
		if (scandoubler[0] != (t & 0x01)) {
			scandoubler[0] = (t & 0x01);
			i = 1;
			config_changed = 1;
		}
		if (i == 1) {
			show_peripherals();
		}
	}
}

/*******************************************************************************/
static unsigned char edit() {

	r = 0;
	lin = l + 17;
	col = (c == 0) ? 9 : 25;	
	while(1) {
		vdp_gotoxy(col, lin);
		vdp_setflash(1);
		vdp_setfg(COLOR_RED);
		printVal();
		vdp_setflash(0);
		vdp_prints(" ");
		readkeyb();
		if (button_space) {
			if (type == 1 || type == 2) {
				if (*value < 2) {
					*value = *value + 1;
				} else {
					*value = 0;
				}
			} else {
				*value = 1 - *value;
			}
		} else if (button_up == 1) {
			r = 0;
			break;
		} else if (button_down == 1) {
			r = 1;
			break;
		} else if (button_left == 1) {
			r = 2;
			break;
		} else if (button_right == 1) {
			r = 3;
			break;
		} else if (button_e == 1) {
			r = 4;
			break;
		} else if (button_enter == 1) {
			r = 5;
			break;
		}
	}
	vdp_gotoxy(col, lin);
	vdp_setflash(0);
	vdp_setfg(COLOR_LRED);
	printVal();
	vdp_prints(" ");
	return r;
}

/*******************************************************************************/
static void mode_edit() {

	r = 0;
	it = 0;
	nl = (itemsCount - 1) >> 1;

	divmmc[1]      = divmmc[0];
	mf[1]          = mf[0];
	psgmode[1]     = psgmode[0];
	enh_ula[1]     = enh_ula[0];
	timex[1]       = timex[0];
	freq5060[1]    = freq5060[0];
	scandoubler[1] = scandoubler[0];
	joystick1[1]   = joystick1[0];
	joystick2[1]   = joystick2[0];
	ps2[1]         = ps2[0];
	lightpen[1]    = lightpen[0];
	scanlines[1]   = scanlines[0];
	dac[1]   	   = dac[0];
	ena_turbo[1]   = ena_turbo[0];
	ntsc[1]        = ntsc[0];
	turbosound[1]  = turbosound[0];
	stereomode[1]  = stereomode[0];

	while (1) {
		l = it >> 1;
		c = it & 1;
		value = peripherals[it].var + 1;
		type = peripherals[it].type;
		r = edit();
		if (r == 4) {	// cancelar
			return;
		} else if (r == 0 && l > 0) {		// UP
			it -= 2;
		} else if (r == 1 && l < nl) {		// DOWN
			it += 2;
		} else if (r == 2 && c == 1) {		// LEFT
			--it;
		} else if (r == 3 && c == 0) {		// RIGHT
			++it;
		} else if (r == 5) {				// ENTER
			break;
		}
		if (it == itemsCount) {
			--it;
		}
	}

	divmmc[0]      = divmmc[1];
	mf[0]          = mf[1];
	psgmode[0]     = psgmode[1];
	enh_ula[0]     = enh_ula[1];
	timex[0]       = timex[1];
	freq5060[0]    = freq5060[1];
	scandoubler[0] = scandoubler[1];
	joystick1[0]   = joystick1[1];
	joystick2[0]   = joystick2[1];
	ps2[0]         = ps2[1];
	lightpen[0]    = lightpen[1];
	scanlines[0]   = scanlines[1];
	dac[0]   	   = dac[1];
	ena_turbo[0]   = ena_turbo[1];
	ntsc[0]        = ntsc[1];
	turbosound[0]  = turbosound[1];
	stereomode[0]  = stereomode[1];

	config_changed = 1;
}

/*******************************************************************************/
static void show_menu(unsigned char numitens)
{
	top = 0;
	bottom = numitens-1;

	posc = menu_default;
	if (posc > bottom) 
		posc = bottom;
	while(1) {
		vdp_setfg(COLOR_LGREEN);
		y = 3;
		for (i = top; i <= bottom; i++) {
			vdp_gotoxy(2, y++);
			vdp_setflash(i == posc);
			vdp_prints(menus[i].title);
			vdp_setflash(0);
		}
		readkeyb();
		vdp_setfg(COLOR_LGREEN);
		if (button_e) {
			vdp_gotoxy(2, posc+3);
			vdp_setflash(0);
			vdp_prints(menus[posc].title);
			mode_edit();
			show_peripherals();
		} else 	if (button_up) {
			if (posc > top) {
				--posc;
			}
		} else if (button_down) {
			if (posc < bottom) {
				++posc;
			}
		} else if (button_enter) {
			if (posc != menu_default) {
				menu_default = posc;
				config_changed = 1;
			}
			break;
		}
	}
}

/*******************************************************************************/
static void save_config()
{
	unsigned int i;

	res = f_open(&Fil, CONFIG_FILE, FA_WRITE);
	if (res != FR_OK) {
		//             12345678901234567890123456789012
		display_error("Error saving configuration!");
	}
//	f_puts(";Menu format\n", &Fil);
//	f_puts(";menu=<title>,<mode>,<ROM file>\n", &Fil);
//	f_puts(";\n", &Fil);
//	f_puts("; ZX type:\n", &Fil);
//	f_puts("; 0 = Spectrum 48K (ROM must be 16K)\n", &Fil);
//	f_puts("; 1 = Spectrum 128K (ROM must be 32K)\n", &Fil);
//	f_puts("; 2 = Spectrum 3e (ROM must be 64K)\n\n", &Fil);
//	f_puts("; Joystick:\n", &Fil);
//	f_puts("; 0 = Sinclair, 1 = Kempston, 2 = Cursor\n\n", &Fil);
//	f_puts("; Initial configuration\n", &Fil);
	f_printf(&Fil, "scandoubler=%d\n", scandoubler[0]);
	f_printf(&Fil, "50_60hz=%d\n",     freq5060[0]);
	f_printf(&Fil, "ntsc=%d\n",        ntsc[0]);
	f_printf(&Fil, "enh_ula=%d\n",     enh_ula[0]);
	f_printf(&Fil, "timex=%d\n",       timex[0]);
	f_printf(&Fil, "psgmode=%d\n",     psgmode[0]);
	f_printf(&Fil, "stereomode=%d\n",  stereomode[0]);
	f_printf(&Fil, "turbosound=%d\n",  turbosound[0]);
	f_printf(&Fil, "divmmc=%d\n",      divmmc[0]);
	f_printf(&Fil, "mf=%d\n",          mf[0]);
	f_printf(&Fil, "joystick1=%d\n",   joystick1[0]);
	f_printf(&Fil, "joystick2=%d\n",   joystick2[0]);
	f_printf(&Fil, "ps2=%d\n",         ps2[0]);
	f_printf(&Fil, "lightpen=%d\n",    lightpen[0]);
	f_printf(&Fil, "scanlines=%d\n",   scanlines[0]);
	f_printf(&Fil, "dac=%d\n",         dac[0]);
	f_printf(&Fil, "turbo=%d\n",       ena_turbo[0]);
//	f_puts("; Menu\n", &Fil);
	f_printf(&Fil, "default=%d\n", menu_default);
	for (i=0; i < menu_cont; i++) {
		f_printf(&Fil, "menu=%s,%d,%s\n", menus[i].title, menus[i].mode, menus[i].romfile);
	}	
	f_puts("\n", &Fil);
	f_close(&Fil);
	for (i=0; i < 1000; i++) ;
}

/* Public functions */

/*******************************************************************************/
unsigned long get_fattime() {

	return 0x44210000UL;
}

/*******************************************************************************/
void main()
{
	vdp_init();
	vdp_setcolor(COLOR_BLACK, COLOR_BLUE, COLOR_WHITE);

	REG_NUM = REG_MACHID;
	mach_id = REG_VAL;
	REG_NUM = REG_VERSION;
	mach_version = REG_VAL;

	vdp_prints(TITLE);
	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_LGREEN);

	REG_NUM = REG_MACHTYPE;
	REG_VAL = 0;						// disable bootrom

	f_mount(&FatFs, "", 0);		/* Give a work area to the default drive */

	res = f_open(&Fil, CONFIG_FILE, FA_READ);
	if (res != FR_OK) {
		//             12345678901234567890123456789012
		display_error("Error opening 'config.ini' file!");
	}

	while(f_eof(&Fil) == 0) {
		if (!f_gets(line, 255, &Fil)) {
			//             12345678901234567890123456789012
			display_error("Error reading configuration!");
		}
		if (line[0] == ';')
			continue;
		line[strlen(line)-1] = '\0';
		if (strncmp(line, "scandoubler=", 12) == 0) {
			scandoubler[0] = atoi(line+12);
		} else if (strncmp(line, "50_60hz=", 8) == 0) {
			freq5060[0] = atoi(line+8);
		} else if (strncmp(line, "ntsc=", 5) == 0) {
			ntsc[0] = atoi(line+5);
		} else if (strncmp(line, "enh_ula=", 8) == 0) {
			enh_ula[0] = atoi(line+8);
		} else if (strncmp(line, "timex=", 6) == 0) {
			timex[0] = atoi(line+6);
		} else if (strncmp(line, "psgmode=", 8) == 0) {
			psgmode[0] = atoi(line+8);
		} else if (strncmp(line, "stereomode=", 11) == 0) {
			stereomode[0] = atoi(line+11);
		} else if (strncmp(line, "turbosound=", 11) == 0) {
			turbosound[0] = atoi(line+11);
		} else if (strncmp(line, "divmmc=", 7) == 0) {
			divmmc[0] = atoi(line+7);
		} else if (strncmp(line, "mf=", 3) == 0) {
			mf[0] = atoi(line+3);
		} else if (strncmp(line, "joystick1=", 10) == 0) {
			joystick1[0] = atoi(line+10);
		} else if (strncmp(line, "joystick2=", 10) == 0) {
			joystick2[0] = atoi(line+10);
		} else if (strncmp(line, "ps2=", 4) == 0) {
			ps2[0] = atoi(line+4);
		} else if (strncmp(line, "dac=", 4) == 0) {
			dac[0] = atoi(line+4);
		} else if (strncmp(line, "lightpen=", 9) == 0) {
			lightpen[0] = atoi(line+9);
		} else if (strncmp(line, "scanlines=", 10) == 0) {
			scanlines[0] = atoi(line+10);
		} else if (strncmp(line, "turbo=", 6) == 0) {
			ena_turbo[0] = atoi(line+6);
		} else if (strncmp(line, "default=", 8) == 0) {
			menu_default = atoi(line+8);
		} else if (strncmp(line, "menu=", 5) == 0) {
			if (menu_cont < 10) {
				comma1 = strchr(line, ',');
				if (comma1 == 0)
					continue;
				memset(temp, 0, 255);
				memcpy(temp, line+5, (comma1-line-5));
				strcpy(menus[menu_cont].title, temp);
				++comma1;
				comma2 = strchr(comma1, ',');
				if (comma2 == 0) {
					free(menus[menu_cont].title);
					continue;
				}
				memset(temp, 0, 255);
				memcpy(temp, comma1, (comma2-comma1));
				menus[menu_cont].mode = atoi(temp);
				++comma2;
				strcpy(menus[menu_cont].romfile, comma2);
				++menu_cont;
			}
		}
	}
	f_close(&Fil);
	if (menu_cont == 0) {
		//             12345678901234567890123456789012
		display_error("No configuration read!");
	}
	if (mach_id == HWID_VTRUCCO) {
		peripherals = (configitem *)peripherals2;
		itemsCount = itemcount2;
	} else if (mach_id == HWID_FBLABS) {
		peripherals = (configitem *)peripherals3;
		itemsCount = itemcount3;
	} else if (mach_id == HWID_ZXUNO) {
		peripherals = (configitem *)peripherals5;
		itemsCount = itemcount5;
	} else {
		peripherals = (configitem *)peripherals1;
		itemsCount = itemcount1;
	}
	show_peripherals();
	show_menu(menu_cont);
	if (config_changed) {
		save_config();
	}
	REG_NUM = REG_RESET;
	REG_VAL = RESET_HARD;				// Hard-reset
}
