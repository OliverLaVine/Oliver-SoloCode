@echo off
chcp 65001 >nul
title 进程内存监控系统 - 一键启动

set "PROJECT_ROOT=%~dp0.."
set "LOG_DIR=%PROJECT_ROOT%\logs"
set "STARTUP_LOG=%LOG_DIR%\startup.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ============================================================ > "%STARTUP_LOG%" 2>&1
echo          进程内存监控系统 - 一键启动脚本 >> "%STARTUP_LOG%" 2>&1
echo          启动时间: %date% %time% >> "%STARTUP_LOG%" 2>&1
echo ============================================================ >> "%STARTUP_LOG%" 2>&1
echo. >> "%STARTUP_LOG%" 2>&1

echo ============================================================
echo          进程内存监控系统 - 一键启动脚本
echo ============================================================
echo.

echo [1/5] 检查环境依赖...
echo.

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Java 环境，请先安装 JDK 17 或更高版本
    echo [错误] 未检测到 Java 环境 >> "%STARTUP_LOG%" 2>&1
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo [OK] Java 版本: %%~v
    echo [OK] Java 版本: %%~v >> "%STARTUP_LOG%" 2>&1
)

where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [警告] 未检测到 Maven，请安装 Maven 并加入 PATH
    echo [警告] 未检测到 Maven >> "%STARTUP_LOG%" 2>&1
    pause
    exit /b 1
) else (
    echo [OK] Maven 环境检测通过
    echo [OK] Maven 环境检测通过 >> "%STARTUP_LOG%" 2>&1
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js 环境，请先安装 Node.js
    echo [错误] 未检测到 Node.js >> "%STARTUP_LOG%" 2>&1
    pause
    exit /b 1
)
echo [OK] Node.js 环境检测通过
for /f %%v in ('node -v') do (
    echo [OK] Node.js 版本: %%v
    echo [OK] Node.js 版本: %%v >> "%STARTUP_LOG%" 2>&1
)

echo.
echo [2/5] 配置数据库连接...
echo.

set /p MYSQL_USER=请输入 MySQL 用户名 (默认 root): 
if "%MYSQL_USER%"=="" set MYSQL_USER=root
set /p MYSQL_PASS=请输入 MySQL 密码 (默认 123456): 
if "%MYSQL_PASS%"=="" set MYSQL_PASS=123456

echo MySQL 用户: %MYSQL_USER% >> "%STARTUP_LOG%" 2>&1
echo [OK] 数据库连接信息已配置

echo.
echo [3/5] 初始化数据库...
echo.

set "SQL_FILE=%PROJECT_ROOT%\sql\init.sql"
if exist "%SQL_FILE%" (
    echo 正在初始化数据库...
    mysql -u%MYSQL_USER% -p%MYSQL_PASS% < "%SQL_FILE%" 2>>"%STARTUP_LOG%"
    if %errorlevel% equ 0 (
        echo [OK] 数据库初始化成功
        echo [OK] 数据库初始化成功 >> "%STARTUP_LOG%" 2>&1
    ) else (
        echo [警告] 数据库初始化失败，可能是数据库已存在。详细日志: %STARTUP_LOG%
        echo [警告] 数据库初始化失败 >> "%STARTUP_LOG%" 2>&1
    )
) else (
    echo [警告] 未找到数据库初始化脚本: %SQL_FILE%
    echo [警告] 未找到数据库初始化脚本 >> "%STARTUP_LOG%" 2>&1
)

echo.
echo [4/5] 启动后端服务...
echo.

cd /d "%PROJECT_ROOT%\backend"

echo 正在编译后端项目（首次编译较慢，请耐心等待）...
echo [%date% %time%] 开始编译后端项目 >> "%STARTUP_LOG%" 2>&1
call mvn clean package -DskipTests >> "%STARTUP_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo [错误] 后端项目编译失败！详细日志: %STARTUP_LOG%
    echo [错误] 后端项目编译失败 >> "%STARTUP_LOG%" 2>&1
    echo.
    echo 请查看日志文件: %STARTUP_LOG%
    pause
    exit /b 1
)
echo [OK] 后端项目编译成功
echo [OK] 后端项目编译成功 >> "%STARTUP_LOG%" 2>&1

echo.
echo 正在启动后端服务 (端口 8080)...
start "后端服务 - 进程内存监控" cmd /k "set MYSQL_USER=%MYSQL_USER%& set MYSQL_PASS=%MYSQL_PASS%& java -jar target\process-memory-monitor-1.0.0.jar"

echo 等待后端服务启动（约15秒）...
timeout /t 15 /nobreak >nul

echo.
echo [5/5] 启动前端服务...
echo.

cd /d "%PROJECT_ROOT%\frontend"

if not exist "node_modules" (
    echo 正在安装前端依赖（首次安装较慢）...
    call npm install >> "%STARTUP_LOG%" 2>&1
    if %errorlevel% neq 0 (
        echo [错误] 前端依赖安装失败！详细日志: %STARTUP_LOG%
        pause
        exit /b 1
    )
    echo [OK] 前端依赖安装成功
) else (
    echo [OK] 前端依赖已存在
)

echo.
echo 正在启动前端服务 (端口 8081)...
start "前端服务 - 进程内存监控" cmd /k "npm run serve"

echo 等待前端服务启动（约10秒）...
timeout /t 10 /nobreak >nul

echo.
echo ============================================================
echo          启动完成！
echo ============================================================
echo.
echo 后端服务地址: http://localhost:8080
echo 前端页面地址: http://localhost:8081
echo 启动日志文件: %STARTUP_LOG%
echo 应用日志目录: %LOG_DIR%
echo.
echo 请在浏览器中打开前端页面进行使用
echo 注意：请勿关闭弹出的后端和前端服务窗口
echo ============================================================
echo.

echo [%date% %time%] 启动完成 >> "%STARTUP_LOG%" 2>&1

pause
