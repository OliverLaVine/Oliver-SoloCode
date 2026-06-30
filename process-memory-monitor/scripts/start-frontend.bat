@echo off
title Process Memory Monitor - Frontend

set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fi"
set "LOG_DIR=%PROJECT_ROOT%\logs"

echo.
echo ============================================================
echo   Process Memory Monitor - Frontend Startup
echo ============================================================
echo.

cd /d "%PROJECT_ROOT%\frontend"

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js.
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo [1/2] Installing dependencies...
    echo.
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Dependencies install failed
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
) else (
    echo [1/2] Dependencies already exist, skipping install
)

echo.
echo [2/2] Starting service...
echo.
echo Frontend URL: http://localhost:8081
echo Press Ctrl+C to stop
echo.

npm run serve

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Frontend exited abnormally!
    echo.
    pause
)
