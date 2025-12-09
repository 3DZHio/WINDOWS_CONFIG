:: SETTINGS :: 
@echo off
setlocal


:: VARIABLES ::
set "CURRENT_PATH=%~f0"
set "CURRENT_DIR=%~dp0"
set "SCRIPT_PATH=%CURRENT_DIR%SYSTEM\SCRIPT.ps1"


:: ADMIN CHECK ::
net session >nul 2>&1 || (
    PowerShell -Command "Start-Process \"%CURRENT_PATH%\" -Verb RunAs"
    exit /B 0
)


:: MAIN ::
PowerShell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"%SCRIPT_PATH%\"'"