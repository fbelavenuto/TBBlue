@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting ZXUno (Xilinx)

..\Utils\bit2bin ..\synth\zxuno\zxuno_top.bit COREX.ZX1

pause
