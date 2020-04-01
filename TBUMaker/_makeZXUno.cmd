@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting ZXUno (Xilinx)

..\Utils\bit2bin ..\synth\zxuno\zxuno_top.bit zxuno.bin

echo making TBBLUE.TBU for ZXUno
tbumaker 9 %version%

rem copy /y TBBLUE.TBU f:\

pause
