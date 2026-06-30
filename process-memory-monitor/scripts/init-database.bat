@echo off
setlocal enabledelayedexpansion
title Process Memory Monitor - Init Database

set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fi"

echo.
echo ============================================================
echo   Process Memory Monitor - Database Init
echo ============================================================
echo.

set "SQL_FILE=%PROJECT_ROOT%\sql\init.sql"

if not exist "%SQL_FILE%" (
    echo [ERROR] SQL file not found: %SQL_FILE%
    pause
    exit /b 1
)

set MYSQL_USER=root
set MYSQL_PASS=123456
set MYSQL_HOST=localhost
set MYSQL_PORT=3306

set /p MYSQL_USER_INPUT=Username (default root, press Enter):
if not "!MYSQL_USER_INPUT!"=="" set "MYSQL_USER=!MYSQL_USER_INPUT!"

set /p MYSQL_PASS_INPUT=Password (default 123456, press Enter):
if not "!MYSQL_PASS_INPUT!"=="" set "MYSQL_PASS=!MYSQL_PASS_INPUT!"

set /p MYSQL_HOST_INPUT=Host (default localhost, press Enter):
if not "!MYSQL_HOST_INPUT!"=="" set "MYSQL_HOST=!MYSQL_HOST_INPUT!"

set /p MYSQL_PORT_INPUT=Port (default 3306, press Enter):
if not "!MYSQL_PORT_INPUT!"=="" set "MYSQL_PORT=!MYSQL_PORT_INPUT!"

echo.
echo Executing database init...
echo.

mysql -h !MYSQL_HOST! -P !MYSQL_PORT! -u!MYSQL_USER! -p!MYSQL_PASS! < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo   [OK] Database initialized successfully!
    echo ============================================================
) else (
    echo.
    echo ============================================================
    echo   [ERROR] Database init failed!
    echo ============================================================
    echo.
    echo Check:
    echo   1. MySQL service is running
    echo   2. Username and password are correct
    echo   3. User has permission to CREATE DATABASE
    echo.
)

echo.
pause
endlocal
