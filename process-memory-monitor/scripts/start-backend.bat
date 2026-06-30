@echo off
chcp 65001 >nul
title 进程内存监控系统 - 后端启动

set "PROJECT_ROOT=%~dp0.."
set "LOG_DIR=%PROJECT_ROOT%\logs"
set "BACKEND_LOG=%LOG_DIR%\startup-backend.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ============================================================
echo          进程内存监控系统 - 后端服务启动
echo ============================================================
echo.

cd /d "%PROJECT_ROOT%\backend"

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Java 环境，请先安装 JDK 17 或更高版本
    pause
    exit /b 1
)

echo 请输入数据库连接信息（直接回车使用默认值）:
set /p MYSQL_USER=MySQL 用户名 (默认 root): 
if "%MYSQL_USER%"=="" set MYSQL_USER=root
set /p MYSQL_PASS=MySQL 密码 (默认 123456): 
if "%MYSQL_PASS%"=="" set MYSQL_PASS=123456
echo.

echo [1/2] 编译项目...
echo.
echo 编译日志输出到: %BACKEND_LOG%
call mvn clean package -DskipTests > "%BACKEND_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo [错误] 项目编译失败！
    echo.
    echo === 编译日志（最后20行）===
    powershell -Command "Get-Content '%BACKEND_LOG%' -Tail 20"
    echo.
    echo 完整日志: %BACKEND_LOG%
    pause
    exit /b 1
)
echo [OK] 项目编译成功

echo.
echo [2/2] 启动服务...
echo.
echo 后端服务地址: http://localhost:8080
echo 应用日志目录: %LOG_DIR%
echo 按 Ctrl+C 停止服务
echo.

java -jar target\process-memory-monitor-1.0.0.jar

if %errorlevel% neq 0 (
    echo.
    echo [错误] 后端服务异常退出！请检查日志: %LOG_DIR%
    pause
)
