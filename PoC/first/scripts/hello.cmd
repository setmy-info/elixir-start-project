@echo off
setlocal

set SCRIPT_DIR=%~dp0
elixir %SCRIPT_DIR%hello.exs %*
exit /b %ERRORLEVEL%

