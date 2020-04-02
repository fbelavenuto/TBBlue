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
#include "ffro.h"			// read-only
#include "spi.h"

/* Defines */

//                    12345678901234567890123456789012
const char TITLE[] = "         TBBLUE BOOT ROM        ";
const char ce[5]   = "\\|/-";

// EPCS4 cmds
const unsigned char cmd_write_enable	= 0x06;
const unsigned char cmd_write_disable	= 0x04;
const unsigned char cmd_read_status		= 0x05;
const unsigned char cmd_read_bytes		= 0x03;
const unsigned char cmd_read_id			= 0xAB;
const unsigned char cmd_fast_read		= 0x0B;
const unsigned char cmd_write_status	= 0x01;
const unsigned char cmd_write_bytes		= 0x02;
const unsigned char cmd_erase_bulk		= 0xC7;
const unsigned char cmd_erase_block64	= 0xD8;		// Block Erase 64K

/* Variables */

FATFS		FatFs;		/* FatFs work area needed for each volume */
FIL			Fil;		/* File object needed for each open file */
FRESULT		res;

unsigned char	t[256], buffer[512];
unsigned char	mach_id, mach_version;
unsigned char	l, file_mach_id, file_mach_version, vma, vmi, cs, csc;
unsigned int	bl, i, j;
unsigned long	fsize, dsize;

/* Private functions */

/*******************************************************************************/
static void display_error(const unsigned char *msg) {

	l = 16 - strlen(msg)/2;
	vdp_setcolor(COLOR_RED, COLOR_BLACK, COLOR_WHITE);
	vdp_setflash(1);
	vdp_gotoxy(l, 12);
	vdp_prints(msg);
	ULAPORT = COLOR_RED;
	for(;;);
}

/*******************************************************************************/
static unsigned char wait_resp() {
	unsigned char r = 0;

	while (1) {
		// key Y
		if ((HROW5 & (1 << 4)) == 0) {
			r = 2;
			while(!(HROW1 & 0x02));
			break;
		}
		// key N
		if ((HROW7 & (1 << 3)) == 0) {
			r = 3;
			while(!(HROW7 & 0x08));
			break;
		}
	}
	return r;
}

/* Public functions */

/*******************************************************************************/
unsigned long get_fattime()
{
	return 0x44210000UL;
}

/*******************************************************************************/
void main() {

	REG_NUM = REG_MACHID;
	mach_id = REG_VAL;
	REG_NUM = REG_VERSION;
	mach_version = REG_VAL;

	vdp_init();
	vdp_setcolor(COLOR_BLACK, COLOR_BLUE, COLOR_WHITE);
	vdp_prints(TITLE);
	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_LGREEN);
	vdp_gotoxy(13, 2);
	vdp_prints("Updater\n\n");
	vdp_setcolor(COLOR_BLACK, COLOR_BLACK, COLOR_WHITE);

	//          12345678901234567890123456789012
	vdp_prints("Update file 'TBBLUE.TBU' found!\n\n");

	memset(buffer, 0, 512);

	f_mount(&FatFs, "", 0);				/* Give a work area to the default drive */

	res = f_open(&Fil, NEXT_UPDATE_FILE2, FA_READ);
	if (res != FR_OK) {
		display_error("Error opening " NEXT_UPDATE_FILE2 " file!");
	}
	fsize = f_size(&Fil);
	res = f_read(&Fil, buffer, 512, &bl);	
	if (res != FR_OK || bl != 512) {
		display_error("Error reading " NEXT_UPDATE_FILE2 " file!");
	}
	if (0 != strncmp(buffer, "TBUFILE", 7)) {
		display_error("Wrong Magic!");
	}
	memcpy(&dsize, buffer+7, 4);
	if (fsize != dsize + 512) {
		sprintf(t, "Wrong size, %ld != %ld", fsize, dsize);
		display_error(t);
	}
	file_mach_id = buffer[11];
	file_mach_version = buffer[12];
	vma = file_mach_version >> 4;
	vmi = file_mach_version & 0x0F;
	cs = buffer[13];

	vdp_setfg(COLOR_WHITE);
	vdp_gotox(13);
	vdp_prints("Version\n");
	sprintf(t, "%d.%02d  ->  ", mach_version >> 4, mach_version & 0x0F);
	vdp_gotox(9);
	vdp_prints(t);
	vdp_setfg(COLOR_LCYAN);
	sprintf(t, "%d.%02d\n\n", vma, vmi);
	vdp_prints(t);

	vdp_setfg(COLOR_WHITE);
	vdp_gotox(15);
	vdp_prints("ID\n");
	sprintf(t, "%d  ->  ", mach_id);
	vdp_gotox(12);
	vdp_prints(t);
	vdp_setfg(COLOR_LCYAN);
	sprintf(t, "%d\n\n", file_mach_id);
	vdp_prints(t);
	vdp_setfg(COLOR_WHITE);

	vdp_gotox(12);
	vdp_prints("HARDWARE\n");
	vdp_setfg(COLOR_LCYAN);
	for (l = 0; l < 16 - strlen(buffer + 14) / 2; l++) {
		vdp_prints(" ");
	}

	vdp_prints(buffer + 14);
	vdp_setfg(COLOR_WHITE);

	vdp_prints("\n\nDo you want to upgrade? (y/n)");
	if (wait_resp() != 2 ) {
		REG_NUM = REG_RESET;
		REG_VAL = RESET_HARD;			// Hard-reset
	}
	vdp_prints("y\n\n");

	if (file_mach_id != mach_id) {
		display_error("Wrong Hardware!");
	}

	// Read flash ID
	// EPCS4    = 0x12
	// W25Q32BV = 0x15
	buffer[0] = cmd_read_id;
	l = SPI_send4bytes_recv(buffer);
	if (l != 0x12 && l != 0x15) {
		display_error("Flash not detected!");
	}

	vdp_prints("Checksum calculating...");
	csc = 0;
	l = 0;
	while (!f_eof(&Fil)) {
		res = f_read(&Fil, buffer, 512, &bl);	
		if (res != FR_OK || bl != 512) {
			display_error("Error reading block!");
		}
		for (j = 0; j < 512; j++) {
			csc ^= buffer[j];
		}
		vdp_putchar(ce[l]);
		vdp_putchar(8);
		l = (l + 1) & 0x03;
	}
	f_close(&Fil);
	if (cs != csc) {
		sprintf(t, "CS error: %02X %02X", cs, csc);
		display_error(t);
	}
	vdp_prints("OK\n");

	vdp_prints("Upgrading:\n");

	vdp_prints("Erasing Flash: ");
	if (mach_id == HWID_ZXNEXT) {
		buffer[0] = cmd_erase_block64;
		buffer[1] = 0x08;
		buffer[2] = 0x00;
		buffer[3] = 0x00;
		for (i = 0; i < 8; i++) {
			SPI_sendcmd(cmd_write_enable);
			SPI_send4bytes(buffer);
			++buffer[1];
			while ((SPI_sendcmd_recv(cmd_read_status) & 0x01) == 1) ;
		}
	} else {
		SPI_sendcmd(cmd_write_enable);
		SPI_sendcmd(cmd_erase_bulk);
	}
	l = 0;
	while ((SPI_sendcmd_recv(cmd_read_status) & 0x01) == 1) {
		vdp_putchar(ce[l]);
		vdp_putchar(8);
		l = (l + 1) & 0x03;
		for (i = 0; i < 5000; i++) ;
	}
	vdp_prints(" OK\n");
	vdp_prints("Writing Flash: ");

	f_mount(&FatFs, "", 0);				/* Give a work area to the default drive */
	res = f_open(&Fil, NEXT_UPDATE_FILE2, FA_READ);
	if (res != FR_OK) {
		display_error("Error opening '" NEXT_UPDATE_FILE2 "' file!");
	}
	res = f_read(&Fil, buffer, 512, &bl);	
	if (res != FR_OK || bl != 512) {
		display_error("Error reading '" NEXT_UPDATE_FILE2 "' file!");
	}

	if (mach_id == HWID_ZXNEXT) {
		dsize = 0x080000;
	} else {
		dsize = 0;
	}
	l = 0;
	while (!f_eof(&Fil)) {
		buffer[0] = cmd_write_bytes;
		buffer[1] = (dsize >> 16) & 0xFF;
		buffer[2] = (dsize >> 8) & 0xFF;
		buffer[3] = dsize & 0xFF;
		res = f_read(&Fil, buffer+4, 256, &bl);	
		if (res != FR_OK || bl != 256) {
			display_error("Error reading block!");
		}
		SPI_sendcmd(cmd_write_enable);
		SPI_writebytes(buffer);
		vdp_putchar(ce[l]);
		vdp_putchar(8);
		l = (l + 1) & 0x03;
		while ((SPI_sendcmd_recv(cmd_read_status) & 0x01) == 1) ;
		dsize += 256;
	}
	vdp_prints(" OK\n");

	// Protect Flash
/*	if (mach_id == HWID_ZXNEXT) {
		SPI_sendcmd(cmd_write_enable);
		buffer[0] = cmd_write_status;
		buffer[1] = 0x30;
		buffer[2] = 0x02;
		SPI_send3bytes(buffer);
	}
*/
	SPI_sendcmd(cmd_write_disable);

	vdp_cls();
	vdp_gotoxy(0, 5);
	vdp_gotox(13);
	vdp_prints("Updated!\n\n");
	vdp_gotox(4);
	vdp_prints("Turn off and on the power.");
	for(;;);
}
