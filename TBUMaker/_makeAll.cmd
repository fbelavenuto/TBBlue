@echo off

set /p version="Enter version (ex: 108 for 1.08): "

echo Converting DE1
call :convert de1 tbblue_fpga de1

echo Converting DE2
call :convert de2 tbblue_de2 de2

echo Converting FBLabs
call :convert fblabs fblabs fblabs

echo Converting VTrucco
call :convert vtrucco vtrucco vtrucco

echo Converting ZXUno
call :convert_xilinx zxuno zxuno_top zxuno

echo Converting Multicore
call :convert Multicore multicore multicore

echo Making TBBLUE.TBU for DE1
call :maketbu 1 de1

echo Making TBBLUE.TBU for DE2
call :maketbu 2 de2

echo Making TBBLUE.TBU for FBLabs
call :maketbu 5 fblabs

echo Making TBBLUE.TBU for VTrucco
call :maketbu 6 vtrucco

echo Making TBBLUE.TBU for ZXUno
call :maketbu 9 zxuno

echo Making TBBLUE.TBU for Multicore
call :maketbu 11 multicore

echo Finished!
goto :end

:convert
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c ..\synth\%1\output_files\%2.pof %3.rpd
IF ERRORLEVEL 1 GOTO error
mkdir ..\BINs\%3\%version%
copy /y ..\synth\%1\output_files\%2.sof ..\BINs\%3\%version%\%3.sof
copy /y ..\synth\%1\output_files\%2.pof ..\BINs\%3\%version%\%3.pof
IF ERRORLEVEL 1 GOTO error
exit /b

:convert_xilinx
..\Utils\bit2bin ..\synth\%1\%2.bit %3.bin
IF ERRORLEVEL 1 GOTO error
mkdir ..\BINs\%3\%version%
copy /y ..\synth\%1\%2.bit ..\BINs\%3\%version%\%3.bit
IF ERRORLEVEL 1 GOTO error
exit /b

:maketbu
tbumaker %1 %version%
IF ERRORLEVEL 1 GOTO error
copy /y TBBLUE.TBU ..\BINs\%2\%version%\
IF ERRORLEVEL 1 GOTO error
exit /b

:error
echo Sorry, error!
pause
exit 1

:end
pause
