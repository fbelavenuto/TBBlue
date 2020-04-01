@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting DE1
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\de1\output_files\tbblue_fpga.pof de1.rpd

echo making TBBLUE.TBU for DE1
tbumaker 1 %version%

pause
