@echo off
setlocal enabledelayedexpansion
title Process Memory Monitor - All in One

set "SCRIPT_DIR=%~dp0"
for %%i in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fi"
set "LOG_DIR=%PROJECT_ROOT%\logs"
set "STARTUP_LOG=%LOG_DIR%\startup.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo. > "%STARTUP_LOG%"
echo ============================================================ >> "%STARTUP_LOG%"
echo   Process Memory Monitor - Startup Script >> "%STARTUP_LOG%"
echo   Start Time: %date% %time% >> "%STARTUP_LOG%"
echo ============================================================ >> "%STARTUP_LOG%"
echo. >> "%STARTUP_LOG%"

echo.
echo ============================================================
echo   Process Memory Monitor - Startup Script
echo ============================================================
echo.

echo [1/5] Checking environment dependencies...
echo.

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Java not found. Please install JDK 17 or higher.
    echo [ERROR] Java not found. >> "%STARTUP_LOG%"
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo [OK] Java version: %%~v
    echo [OK] Java version: %%~v >> "%STARTUP_LOG%"
)

where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Maven not found. Please install Maven and add to PATH.
    echo [ERROR] Maven not found. >> "%STARTUP_LOG%"
    pause
    exit /b 1
) else (
    echo [OK] Maven detected
    echo [OK] Maven detected >> "%STARTUP_LOG%"
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js.
    echo [ERROR] Node.js not found. >> "%STARTUP_LOG%"
    pause
    exit /b 1
)
echo [OK] Node.js detected
for /f %%v in ('node -v') do (
    echo [OK] Node.js version: %%v
    echo [OK] Node.js version: %%v >> "%STARTUP_LOG%"
)

echo.
echo [2/5] Configuring database connection...
echo.

set MYSQL_USER=root
set MYSQL_PASS=123456

set /p MYSQL_USER_INPUT=MySQL username (default root, press Enter to skip):
if not "!MYSQL_USER_INPUT!"=="" set "MYSQL_USER=!MYSQL_USER_INPUT!"

set /p MYSQL_PASS_INPUT=MySQL password (default 123456, press Enter to skip):
if not "!MYSQL_PASS_INPUT!"=="" set "MYSQL_PASS=!MYSQL_PASS_INPUT!"

echo MySQL user: !MYSQL_USER! >> "%STARTUP_LOG%"
echo [OK] Database configured. Username: !MYSQL_USER!

echo.
echo [3/5] Initializing database...
echo.

set "SQL_FILE=%PROJECT_ROOT%\sql\init.sql"
if exist "%SQL_FILE%" (
    echo Initializing database...
    mysql -u!MYSQL_USER! -p!MYSQL_PASS! < "%SQL_FILE%" 2>>"%STARTUP_LOG%"
    if !errorlevel! equ 0 (
        echo [OK] Database initialized successfully
        echo [OK] Database initialized successfully >> "%STARTUP_LOG%"
    ) else (
        echo [WARN] Database init failed (maybe already exists). See log: %STARTUP_LOG%
        echo [WARN] Database init failed >> "%STARTUP_LOG%"
    )
) else (
    echo [WARN] SQL file not found: %SQL_FILE%
    echo [WARN] SQL file not found >> "%STARTUP_LOG%"
)

echo.
echo [4/5] Building and starting backend...
echo.

cd /d "%PROJECT_ROOT%\backend"

echo Building backend (first build may take a while)...
echo [%date% %time%] Start building backend... >> "%STARTUP_LOG%"
call mvn clean package -DskipTests >> "%STARTUP_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Backend build FAILED! Check log: %STARTUP_LOG%
    echo [ERROR] Backend build FAILED >> "%STARTUP_LOG%"
    echo.
    echo === Last 30 lines of build log ===
    powershell -Command "Get-Content '%STARTUP_LOG%' -Tail 30"
    echo.
    pause
    exit /b 1
)
echo [OK] Backend build succeeded
echo [OK] Backend build succeeded >> "%STARTUP_LOG%"

echo.
echo Starting backend (port 8080)...
set "BACKEND_CMD=set LOG_HOME=%LOG_DIR%^& set MYSQL_USER=!MYSQL_USER!^& set MYSQL_PASS=!MYSQL_PASS!^& java -jar target\process-memory-monitor-1.0.0.jar"
start "Backend - Process Monitor" cmd /k "!BACKEND_CMD!"

echo Waiting for backend to start (~15 seconds)...
timeout /t 15 /nobreak >nul

echo.
echo [5/5] Starting frontend...
echo.

cd /d "%PROJECT_ROOT%\frontend"

if not exist "node_modules" (
    echo Installing frontend dependencies (first time may take a while)...
    call npm install >> "%STARTUP_LOG%" 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Frontend dependencies install FAILED! Check log: %STARTUP_LOG%
        pause
        exit /b 1
    )
    echo [OK] Frontend dependencies installed
) else (
    echo [OK] Frontend dependencies already exist
)

echo.
echo Starting frontend (port 8081)...
start "Frontend - Process Monitor" cmd /k "npm run serve"

echo Waiting for frontend to start (~10 seconds)...
timeout /t 10 /nobreak >nul

echo.
echo ============================================================
echo   Startup Complete!
echo ============================================================
echo.
echo Backend URL:  http://localhost:8080
echo Frontend URL: http://localhost:8081
echo.
echo Startup log:  %STARTUP_LOG%
echo App logs:     %LOG_DIR%
echo.
echo Open the frontend URL in your browser to use the app.
echo Do NOT close the backend/frontend console windows!
echo ============================================================
echo.

echo [%date% %time%] Startup complete >> "%STARTUP_LOG%"

pause
endlocal
