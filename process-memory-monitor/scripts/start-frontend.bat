@echo off
chcp 65001 >nul
title 进程内存监控系统 - 前端启动

echo ============================================================
echo          进程内存监控系统 - 前端服务启动
echo ============================================================
echo.

cd /d "%~dp0..\frontend"

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js 环境，请先安装 Node.js
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo [1/2] 安装依赖...
    echo.
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
    echo [OK] 依赖安装成功
) else (
    echo [1/2] 依赖已存在，跳过安装
)

echo.
echo [2/2] 启动服务...
echo.
echo 前端服务地址: http://localhost:8081
echo 按 Ctrl+C 停止服务
echo.

npm run serve

pause
