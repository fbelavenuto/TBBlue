vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\..\ram\spram.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\..\ram\dpram.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\sprites.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_sprites.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu erro
pause

:ok
