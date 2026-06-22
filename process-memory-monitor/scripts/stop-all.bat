@echo off
chcp 65001 >nul
title 进程内存监控系统 - 停止服务

echo ============================================================
echo          进程内存监控系统 - 停止所有服务
echo ============================================================
echo.

echo 正在查找并停止后端服务进程...
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq 后端服务*" /fo list ^| findstr "PID:"') do (
    echo 找到后端服务进程 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo 正在查找并停止前端服务进程...
for /f "tokens=2" %%a in ('tasklist /fi "windowtitle eq 前端服务*" /fo list ^| findstr "PID:"') do (
    echo 找到前端服务进程 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo 正在查找 Java 进程（进程内存监控）...
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo list ^| findstr "PID:"') do (
    echo 找到 Java 进程 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo 正在查找 Node 进程...
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq node.exe" /fo list ^| findstr "PID:"') do (
    echo 找到 Node 进程 PID: %%a
    taskkill /pid %%a /f >nul 2>&1
)

echo.
echo ============================================================
echo          所有服务已停止
echo ============================================================
echo.

pause
