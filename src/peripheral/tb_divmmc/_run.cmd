@echo off
vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\divmmc.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_divmmc.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do ./ts_all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu erro
pause

:ok
