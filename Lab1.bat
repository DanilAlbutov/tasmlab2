@echo off
cls


tasm mlab1
if errorlevel 1 goto tasmerr
tasm mlab1l
if errorlevel 1 goto tasmerr
tlink mlab1 + mlab1l
if errorlevel 1 goto linkerr
mlab1
if errorlevel 1 goto exeerr

:edit1
TD mlab1.exe
:linkerr
echo link error

goto edit1
:tasmerr
echo assembly error
goto edit1
:exeerr
echo run error
goto edit1

:end