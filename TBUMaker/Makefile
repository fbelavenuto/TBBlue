#
# Copyright (c) 2015 Fabio Belavenuto & Victor Trucco
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY#  without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

CC = gcc
LD = gcc
CPP = g++
RM = rm -f
MD = mkdir

SDIR = src
ODIR = obj

CFLAGS=-g -Wall
LDFLAGS=

APP=tbumaker
SOURCES=main.c
OBJECTS=$(addprefix $(ODIR)/, $(SOURCES:.c=.o))

all: $(ODIR) $(APP)

$(APP): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(ODIR):
	$(MD) $(ODIR)

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ODIR)/%.o: $(SDIR)/%.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

clean:
	$(RM) $(APP) $(APP).exe $(ODIR)/*
