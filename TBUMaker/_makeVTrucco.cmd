@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting VTrucco
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\vtrucco\output_files\vtrucco.pof vtrucco.rpd

echo making TBBLUE.TBU for VTrucco
tbumaker 6 %version%

pause
