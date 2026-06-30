@echo off
chcp 65001 >nul
title 进程内存监控系统 - 停止服务

echo ============================================================
echo          进程内存监控系统 - 停止所有服务
echo ============================================================
echo.

echo 正在查找并停止后端服务窗口...
tasklist /fi "windowtitle eq 后端服务*" >nul 2>&1
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq 后端服务*" /fo list 2^>nul ^| findstr "PID:"') do (
    echo 停止后端服务 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo 正在查找并停止前端服务窗口...
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq 前端服务*" /fo list 2^>nul ^| findstr "PID:"') do (
    echo 停止前端服务 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo.
echo 注意: 不会强制终止其他 java.exe / node.exe 进程（避免影响其他程序）
echo 如需手动终止，请通过任务管理器查找对应进程

echo.
echo ============================================================
echo          服务已停止
echo ============================================================
echo.

pause
