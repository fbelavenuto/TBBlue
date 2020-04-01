@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting DE2
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\de2\output_files\tbblue_de2.pof de2.rpd

echo making TBBLUE.TBU for DE2
tbumaker 2 %version%

pause
