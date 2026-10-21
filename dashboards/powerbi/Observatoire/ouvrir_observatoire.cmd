@echo off
set "PBI_DESKTOP=%ProgramFiles%\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
if not exist "%PBI_DESKTOP%" (
  echo Power BI Desktop est introuvable. Installer Desktop puis ouvrir Observatoire.pbip.
  pause
  exit /b 1
)
start "Observatoire" "%PBI_DESKTOP%" "%~dp0Observatoire.pbip"
