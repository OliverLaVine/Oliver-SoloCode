@echo off
setlocal enabledelayedexpansion
title Process Memory Monitor - Backend

set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fi"
set "LOG_DIR=%PROJECT_ROOT%\logs"
set "BUILD_LOG=%LOG_DIR%\build-backend.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo.
echo ============================================================
echo   Process Memory Monitor - Backend Startup
echo ============================================================
echo.

cd /d "%PROJECT_ROOT%\backend"

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Java not found. Please install JDK 17 or higher.
    pause
    exit /b 1
)

set MYSQL_USER=root
set MYSQL_PASS=123456

set /p MYSQL_USER_INPUT=MySQL username (default root, press Enter):
if not "!MYSQL_USER_INPUT!"=="" set "MYSQL_USER=!MYSQL_USER_INPUT!"

set /p MYSQL_PASS_INPUT=MySQL password (default 123456, press Enter):
if not "!MYSQL_PASS_INPUT!"=="" set "MYSQL_PASS=!MYSQL_PASS_INPUT!"

echo.
echo [1/2] Building project...
echo.
echo Build log: %BUILD_LOG%
call mvn clean package -DskipTests > "%BUILD_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Build FAILED!
    echo.
    echo === Last 30 lines of build log ===
    powershell -Command "Get-Content '%BUILD_LOG%' -Tail 30"
    echo.
    echo Full log: %BUILD_LOG%
    pause
    exit /b 1
)
echo [OK] Build succeeded

echo.
echo [2/2] Starting service...
echo.
echo Backend URL: http://localhost:8080
echo App logs:    %LOG_DIR%
echo Press Ctrl+C to stop
echo.

set LOG_HOME=%LOG_DIR%
set MYSQL_USER=!MYSQL_USER!
set MYSQL_PASS=!MYSQL_PASS!
java -jar target\process-memory-monitor-1.0.0.jar

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Backend exited abnormally! Check logs: %LOG_DIR%
    pause
)

endlocal
