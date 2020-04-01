vlib work
IF ERRORLEVEL 1 GOTO error
vcom dpram2.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\zxula_timing.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\zxula.vhd
IF ERRORLEVEL 1 GOTO error

vcom vram_data.vhd
IF ERRORLEVEL 1 GOTO error
vcom tb_zxula.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all_normal.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu erro
pause

:ok
