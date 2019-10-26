@echo off

cd >root.txt
set /p root=<root.txt
del root.txt

path=%path%;%root%\BIN;%root%\XBIN;%root%\BIN\platform-tools

busybox sh go.sh
pause