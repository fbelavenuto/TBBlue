@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting Multicore
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\Multicore\output_files\multicore.pof multicore.rpd

echo making TBBLUE.TBU for Multicore
tbumaker 11 %version%

pause
