@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting FBLabs
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\fblabs\output_files\fblabs.pof fblabs.rpd

echo Making TBBLUE.TBU for FBLabs
tbumaker 5 %version%
mkdir ..\BINs\fblabs\%version%
copy /y ..\synth\fblabs\output_files\fblabs.pof ..\BINs\fblabs\%version%\fblabs.pof
copy /y TBBLUE.TBU ..\BINs\fblabs\%version%\

pause
