@echo off

chcp 65001 > nul
color 97

REM Définir le lien de base et le nom de l'ISO
set "ISO_LINK_BASE=https://heligams.djmc01.fr:8443/ISO"
set "ISO_NAME=fr-fr_windows_11_enterprise_ltsc_2024_x64_dvd_d66e386e.iso"

REM bruh bruh admin perms
:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )
:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "ELEV " >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B
:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

REM sussy folder
mkdir Windows11Upgrade
cd Windows11Upgrade

REM Téléchargements

cls
echo Préparation...
powershell -command "$ProgressPreference = 'SilentlyContinue' ; iwr -uri 'https://nicalay2.fr/depot/aria2c-patch.exe' -outfile 'aria2c-patch.exe'"
cls
echo Téléchargement...
aria2c-patch.exe --show-console-readout=false --console-log-level=warn --summary-interval=0 -s64 -x64 -c "%ISO_LINK_BASE%/%ISO_NAME%" > NUL 2>&1
cls

echo Lancement de l'installation...

REM Les blud qui permettent la in-place ugrade
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CompositionEditionID" /t REG_SZ /d "EnterpriseS" /f > NUL
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID" /t REG_SZ /d "EnterpriseS" /f > NUL

REM Montage de l'iso
for /f %%i in ('powershell -NoProfile -Command "(Mount-DiskImage -ImagePath (Resolve-Path .\%ISO_NAME%) | Get-Volume).DriveLetter"') do (
    set "DriveLetter=%%i"
)

REM sussy baka
start "" "%DriveLetter%:\setup" /product server /auto upgrade /eula accept

timeout /t 5 >nul