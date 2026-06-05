@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
escript "%SCRIPT_DIR%..\calculator_app" %*
