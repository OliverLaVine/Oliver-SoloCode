@echo off
chcp 65001 >nul
title 数据库初始化

echo ============================================================
echo          进程内存监控系统 - 数据库初始化
echo ============================================================
echo.

cd /d "%~dp0"

set SQL_FILE=..\sql\init.sql

if not exist "%SQL_FILE%" (
    echo [错误] 未找到数据库初始化脚本: %SQL_FILE%
    pause
    exit /b 1
)

echo 请输入 MySQL 连接信息：
echo.

set /p MYSQL_USER=用户名 (默认 root): 
if "%MYSQL_USER%"=="" set MYSQL_USER=root

set /p MYSQL_PASS=密码 (默认 root): 
if "%MYSQL_PASS%"=="" set MYSQL_PASS=root

set /p MYSQL_HOST=主机地址 (默认 localhost): 
if "%MYSQL_HOST%"=="" set MYSQL_HOST=localhost

set /p MYSQL_PORT=端口 (默认 3306): 
if "%MYSQL_PORT%"=="" set MYSQL_PORT=3306

echo.
echo 正在执行数据库初始化...
echo.

mysql -h %MYSQL_HOST% -P %MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASS% < "%SQL_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo          [OK] 数据库初始化成功！
    echo ============================================================
) else (
    echo.
    echo ============================================================
    echo          [错误] 数据库初始化失败！
    echo ============================================================
    echo.
    echo 请检查：
    echo   1. MySQL 服务是否已启动
    echo   2. 用户名和密码是否正确
    echo   3. 用户是否有创建数据库的权限
    echo.
)

echo.
pause
