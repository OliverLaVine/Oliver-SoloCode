@echo off
chcp 65001 >nul
title 进程内存监控系统 - 一键启动

echo ============================================================
echo          进程内存监控系统 - 一键启动脚本
echo ============================================================
echo.

cd /d "%~dp0"

echo [1/4] 检查环境依赖...
echo.

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Java 环境，请先安装 JDK 1.8 或更高版本
    pause
    exit /b 1
)
echo [OK] Java 环境检测通过
java -version 2>&1 | findstr "version"

where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [警告] 未检测到 Maven，将使用内置 Maven Wrapper（如无则需要手动安装）
) else (
    echo [OK] Maven 环境检测通过
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js 环境，请先安装 Node.js
    pause
    exit /b 1
)
echo [OK] Node.js 环境检测通过
node -v

where mysql >nul 2>nul
if %errorlevel% neq 0 (
    echo [警告] 未检测到 MySQL 命令行，请确保 MySQL 服务已启动并配置好数据库
) else (
    echo [OK] MySQL 命令行检测通过
)

echo.
echo [2/4] 初始化数据库...
echo.

set SQL_FILE=..\sql\init.sql
if exist "%SQL_FILE%" (
    echo 请确认 MySQL 数据库信息：
    set /p MYSQL_USER=请输入 MySQL 用户名 (默认 root): 
    if "%MYSQL_USER%"=="" set MYSQL_USER=root
    set /p MYSQL_PASS=请输入 MySQL 密码 (默认 root): 
    if "%MYSQL_PASS%"=="" set MYSQL_PASS=root
    set /p MYSQL_HOST=请输入 MySQL 主机 (默认 localhost): 
    if "%MYSQL_HOST%"=="" set MYSQL_HOST=localhost
    set /p MYSQL_PORT=请输入 MySQL 端口 (默认 3306): 
    if "%MYSQL_PORT%"=="" set MYSQL_PORT=3306

    echo.
    echo 正在初始化数据库...
    mysql -h %MYSQL_HOST% -P %MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASS% < "%SQL_FILE%" 2>nul
    if %errorlevel% equ 0 (
        echo [OK] 数据库初始化成功
    ) else (
        echo [警告] 数据库初始化失败，请手动执行 %SQL_FILE%
    )
) else (
    echo [警告] 未找到数据库初始化脚本: %SQL_FILE%
)

echo.
echo [3/4] 启动后端服务...
echo.

cd ..\backend

echo 正在编译后端项目...
call mvn clean package -DskipTests -q
if %errorlevel% neq 0 (
    echo [错误] 后端项目编译失败
    pause
    exit /b 1
)
echo [OK] 后端项目编译成功

echo.
echo 正在启动后端服务 (端口 8080)...
start "后端服务 - 进程内存监控" cmd /k "java -jar target\process-memory-monitor-1.0.0.jar"

echo 等待后端服务启动...
timeout /t 15 /nobreak >nul

echo.
echo [4/4] 启动前端服务...
echo.

cd ..\frontend

if not exist "node_modules" (
    echo 正在安装前端依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 前端依赖安装失败
        pause
        exit /b 1
    )
    echo [OK] 前端依赖安装成功
)

echo.
echo 正在启动前端服务 (端口 8081)...
start "前端服务 - 进程内存监控" cmd /k "npm run serve"

echo 等待前端服务启动...
timeout /t 10 /nobreak >nul

echo.
echo ============================================================
echo          启动完成！
echo ============================================================
echo.
echo 后端服务地址: http://localhost:8080
echo 前端页面地址: http://localhost:8081
echo.
echo 请在浏览器中打开前端页面进行使用
echo.
echo 注意：请勿关闭弹出的后端和前端服务窗口
echo ============================================================
echo.

pause
