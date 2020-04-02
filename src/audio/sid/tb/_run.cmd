vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\sid_voice.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\sid6581.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\NextSID.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_sid6581.vht
IF ERRORLEVEL 1 GOTO error

vcom tb_NextSID.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu erro
pause

:ok
