@echo off
echo Installing AMD Chipset Driver, please wait......

cd %~dp0

START /WAIT "" AMD_Chipset_Software.exe /S /EXPRESSUNINSTALL=1

timeout /t 3
exit