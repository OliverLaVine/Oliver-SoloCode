@echo off
setlocal enabledelayedexpansion
title Process Memory Monitor - Stop All

echo.
echo ============================================================
echo   Process Memory Monitor - Stop All Services
echo ============================================================
echo.

echo Stopping backend service window...
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq Backend*" /fo list 2^>nul ^| findstr "PID:"') do (
    echo   Killing PID %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo Stopping frontend service window...
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq Frontend*" /fo list 2^>nul ^| findstr "PID:"') do (
    echo   Killing PID %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo.
echo NOTE: Other Java/Node processes (not from this app) are NOT stopped.
echo       Use Task Manager if you need to stop them manually.

echo.
echo ============================================================
echo   Services stopped.
echo ============================================================
echo.

pause
endlocal
