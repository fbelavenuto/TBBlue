/*
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

#ifndef _FONT_H
#define _FONT_H

const unsigned char font[768] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,		// 20  space
	0x00, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x00,		// 21  !
	0x00, 0x24, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00,		// 22  " doublequotes
	0x00, 0x24, 0x7e, 0x24, 0x24, 0x7e, 0x24, 0x00,		// 23  #
	0x00, 0x08, 0x3e, 0x28, 0x3e, 0x0a, 0x3e, 0x08,		// 24  $
	0x00, 0x62, 0x64, 0x08, 0x10, 0x26, 0x46, 0x00,		// 25  %
	0x00, 0x10, 0x28, 0x10, 0x2a, 0x44, 0x3a, 0x00,		// 26  &
	0x00, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,		// 27  '
	0x00, 0x04, 0x08, 0x08, 0x08, 0x08, 0x04, 0x00,		// 28  (
	0x00, 0x20, 0x10, 0x10, 0x10, 0x10, 0x20, 0x00,		// 29  )
	0x00, 0x00, 0x14, 0x08, 0x3e, 0x08, 0x14, 0x00,		// 2a  *
	0x00, 0x00, 0x08, 0x08, 0x3e, 0x08, 0x08, 0x00,		// 2b  +
	0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x10,		// 2c  ,
	0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00,		// 2d  -
	0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x00,		// 2e  .
	0x00, 0x00, 0x02, 0x04, 0x08, 0x10, 0x20, 0x00,		// 2f  /
	0x00, 0x3c, 0x46, 0x4a, 0x52, 0x62, 0x3c, 0x00,		// 30  0
	0x00, 0x18, 0x28, 0x08, 0x08, 0x08, 0x3e, 0x00,		// 31  1
	0x00, 0x3c, 0x42, 0x02, 0x3c, 0x40, 0x7e, 0x00,		// 32  2
	0x00, 0x3c, 0x42, 0x0c, 0x02, 0x42, 0x3c, 0x00,		// 33  3
	0x00, 0x08, 0x18, 0x28, 0x48, 0x7e, 0x08, 0x00,		// 34  4
	0x00, 0x7e, 0x40, 0x7c, 0x02, 0x42, 0x3c, 0x00,		// 35  5
	0x00, 0x3c, 0x40, 0x7c, 0x42, 0x42, 0x3c, 0x00,		// 36  6
	0x00, 0x7e, 0x02, 0x04, 0x08, 0x10, 0x10, 0x00,		// 37  7
	0x00, 0x3c, 0x42, 0x3c, 0x42, 0x42, 0x3c, 0x00,		// 38  8
	0x00, 0x3c, 0x42, 0x42, 0x3e, 0x02, 0x3c, 0x00,		// 39  9
	0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x10, 0x00,		// 3a  : colon
	0x00, 0x00, 0x10, 0x00, 0x00, 0x10, 0x10, 0x20,		// 3b  ; semicolon
	0x00, 0x00, 0x04, 0x08, 0x10, 0x08, 0x04, 0x00,		// 3c  <
	0x00, 0x00, 0x00, 0x3e, 0x00, 0x3e, 0x00, 0x00,		// 3d  =
	0x00, 0x00, 0x20, 0x10, 0x08, 0x10, 0x20, 0x00,		// 3e  >
	0x00, 0x3c, 0x42, 0x04, 0x08, 0x00, 0x08, 0x00,		// 3f  ?
	0x00, 0x3c, 0x4a, 0x56, 0x5e, 0x40, 0x3c, 0x00,		// 40  @
	0x00, 0x3c, 0x42, 0x42, 0x7e, 0x42, 0x42, 0x00,		// 41  A
	0x00, 0x7c, 0x42, 0x7c, 0x42, 0x42, 0x7c, 0x00,		// 42  B
	0x00, 0x3c, 0x42, 0x40, 0x40, 0x42, 0x3c, 0x00,		// 43  C
	0x00, 0x78, 0x44, 0x42, 0x42, 0x44, 0x78, 0x00,		// 44  D
	0x00, 0x7e, 0x40, 0x7c, 0x40, 0x40, 0x7e, 0x00,		// 45  E
	0x00, 0x7e, 0x40, 0x7c, 0x40, 0x40, 0x40, 0x00,		// 46  F
	0x00, 0x3c, 0x42, 0x40, 0x4e, 0x42, 0x3c, 0x00,		// 47  G
	0x00, 0x42, 0x42, 0x7e, 0x42, 0x42, 0x42, 0x00,		// 48  H
	0x00, 0x3e, 0x08, 0x08, 0x08, 0x08, 0x3e, 0x00,		// 49  I
	0x00, 0x02, 0x02, 0x02, 0x42, 0x42, 0x3c, 0x00,		// 4a  J
	0x00, 0x44, 0x48, 0x70, 0x48, 0x44, 0x42, 0x00,		// 4b  K
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7e, 0x00,		// 4c  L
	0x00, 0x42, 0x66, 0x5a, 0x42, 0x42, 0x42, 0x00,		// 4d  M
	0x00, 0x42, 0x62, 0x52, 0x4a, 0x46, 0x42, 0x00,		// 4e  N
	0x00, 0x3c, 0x42, 0x42, 0x42, 0x42, 0x3c, 0x00,		// 4f  O
	0x00, 0x7c, 0x42, 0x42, 0x7c, 0x40, 0x40, 0x00,		// 50  P
	0x00, 0x3c, 0x42, 0x42, 0x52, 0x4a, 0x3c, 0x00,		// 51  Q
	0x00, 0x7c, 0x42, 0x42, 0x7c, 0x44, 0x42, 0x00,		// 52  R
	0x00, 0x3c, 0x40, 0x3c, 0x02, 0x42, 0x3c, 0x00,		// 53  S
	0x00, 0xfe, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00,		// 54  T
	0x00, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3c, 0x00,		// 55  U
	0x00, 0x42, 0x42, 0x42, 0x42, 0x24, 0x18, 0x00,		// 56  V
	0x00, 0x42, 0x42, 0x42, 0x42, 0x5a, 0x24, 0x00,		// 57  W
	0x00, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x00,		// 58  X
	0x00, 0x82, 0x44, 0x28, 0x10, 0x10, 0x10, 0x00,		// 59  Y
	0x00, 0x7e, 0x04, 0x08, 0x10, 0x20, 0x7e, 0x00,		// 5a  Z
	0x00, 0x0e, 0x08, 0x08, 0x08, 0x08, 0x0e, 0x00,		// 5b  [
	0x00, 0x00, 0x40, 0x20, 0x10, 0x08, 0x04, 0x00,		// 5c  \ backslash
	0x00, 0x70, 0x10, 0x10, 0x10, 0x10, 0x70, 0x00,		// 5d  ]
	0x00, 0x10, 0x38, 0x54, 0x10, 0x10, 0x10, 0x00,		// 5e  ^
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff,		// 5f  _ underscore
	0x00, 0x1c, 0x22, 0x78, 0x20, 0x20, 0x7e, 0x00,		// 60  `
	0x00, 0x00, 0x38, 0x04, 0x3c, 0x44, 0x3c, 0x00,		// 61  a
	0x00, 0x20, 0x20, 0x3c, 0x22, 0x22, 0x3c, 0x00,		// 62  b
	0x00, 0x00, 0x1c, 0x20, 0x20, 0x20, 0x1c, 0x00,		// 63  c
	0x00, 0x04, 0x04, 0x3c, 0x44, 0x44, 0x3c, 0x00,		// 64  d
	0x00, 0x00, 0x38, 0x44, 0x78, 0x40, 0x3c, 0x00,		// 65  e
	0x00, 0x0c, 0x10, 0x18, 0x10, 0x10, 0x10, 0x00,		// 66  f
	0x00, 0x00, 0x3c, 0x44, 0x44, 0x3c, 0x04, 0x38,		// 67  g
	0x00, 0x40, 0x40, 0x78, 0x44, 0x44, 0x44, 0x00,		// 68  h
	0x00, 0x10, 0x00, 0x30, 0x10, 0x10, 0x38, 0x00,		// 69  i
	0x00, 0x04, 0x00, 0x04, 0x04, 0x04, 0x24, 0x18,		// 6a  j
	0x00, 0x20, 0x28, 0x30, 0x30, 0x28, 0x24, 0x00,		// 6b  k
	0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x0c, 0x00,		// 6c  l
	0x00, 0x00, 0x68, 0x54, 0x54, 0x54, 0x54, 0x00,		// 6d  m
	0x00, 0x00, 0x78, 0x44, 0x44, 0x44, 0x44, 0x00,		// 6e  n
	0x00, 0x00, 0x38, 0x44, 0x44, 0x44, 0x38, 0x00,		// 6f  o
	0x00, 0x00, 0x78, 0x44, 0x44, 0x78, 0x40, 0x40,		// 70  p
	0x00, 0x00, 0x3c, 0x44, 0x44, 0x3c, 0x04, 0x06,		// 71  q
	0x00, 0x00, 0x1c, 0x20, 0x20, 0x20, 0x20, 0x00,		// 72  r
	0x00, 0x00, 0x38, 0x40, 0x38, 0x04, 0x78, 0x00,		// 73  s
	0x00, 0x10, 0x38, 0x10, 0x10, 0x10, 0x0c, 0x00,		// 74  t
	0x00, 0x00, 0x44, 0x44, 0x44, 0x44, 0x38, 0x00,		// 75  u
	0x00, 0x00, 0x44, 0x44, 0x28, 0x28, 0x10, 0x00,		// 76  v
	0x00, 0x00, 0x44, 0x54, 0x54, 0x54, 0x28, 0x00,		// 77  w
	0x00, 0x00, 0x44, 0x28, 0x10, 0x28, 0x44, 0x00,		// 78  x
	0x00, 0x00, 0x44, 0x44, 0x44, 0x3c, 0x04, 0x38,		// 79  y
	0x00, 0x00, 0x7c, 0x08, 0x10, 0x20, 0x7c, 0x00,		// 7a  z
	0x00, 0x0e, 0x08, 0x30, 0x08, 0x08, 0x0e, 0x00,		// 7b  {
	0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00,		// 7c  |
	0x00, 0x70, 0x10, 0x0c, 0x10, 0x10, 0x70, 0x00,		// 7d  }
	0x00, 0x14, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00,		// 7e  ~
	0x3c, 0x42, 0x99, 0xa1, 0xa1, 0x99, 0x42, 0x3c		// 7f
};

#endif /* _FONT_H */