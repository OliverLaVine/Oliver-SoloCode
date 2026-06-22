@echo off
chcp 65001 >nul
title 进程内存监控系统 - 后端启动

echo ============================================================
echo          进程内存监控系统 - 后端服务启动
echo ============================================================
echo.

cd /d "%~dp0..\backend"

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Java 环境，请先安装 JDK 1.8 或更高版本
    pause
    exit /b 1
)

echo [1/2] 编译项目...
echo.
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 项目编译失败
    pause
    exit /b 1
)
echo [OK] 项目编译成功

echo.
echo [2/2] 启动服务...
echo.
echo 后端服务地址: http://localhost:8080
echo 按 Ctrl+C 停止服务
echo.

java -jar target\process-memory-monitor-1.0.0.jar

pause
