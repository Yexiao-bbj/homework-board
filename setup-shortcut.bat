@echo off
chcp 936 >nul 2>&1
setlocal EnableExtensions
title 班级每日作业展示板 - 创建桌面快捷方式

rem ================================================================
rem  双击本文件，在桌面生成「班级每日作业展示板」快捷方式，
rem  并自动套用同目录的 homework-board.ico 图标。
rem
rem  用法：把本 bat 与 index.html、homework-board.ico 放在同一目录，
rem        然后双击。可重复运行，会覆盖同名快捷方式。
rem  说明：路径全部自动取本文件所在目录，换机器 / 换盘符 / 中文路径
rem        都不用改；不会改动 index.html 里的任何内容。
rem ================================================================

set "HERE=%~dp0"
set "TARGET=%HERE%index.html"
set "ICON=%HERE%homework-board.ico"
set "LNKNAME=班级每日作业展示板"
set "DESC=班级每日作业展示板"

echo.
echo   ============================================
echo     班级每日作业展示板 · 桌面快捷方式
echo   ============================================
echo   所在目录: "%HERE%"
echo.

if not exist "%TARGET%" (
  echo   [错误] 找不到 index.html
  echo          请把本 bat 与 index.html 放在同一个目录。
  goto :FAIL
)
if not exist "%ICON%" (
  echo   [错误] 找不到 homework-board.ico
  echo          请把本 bat 与 homework-board.ico 放在同一个目录。
  goto :FAIL
)

set "HW_TARGET=%TARGET%"
set "HW_ICON=%ICON%"
set "HW_NAME=%LNKNAME%"
set "HW_DESC=%DESC%"

rem ---------- 方案 A：PowerShell（Win7 及以上自带）----------
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $w=New-Object -ComObject WScript.Shell; $d=[Environment]::GetFolderPath('Desktop'); if(-not $d){exit 5}; if(-not (Test-Path -LiteralPath $env:HW_TARGET)){exit 3}; if(-not (Test-Path -LiteralPath $env:HW_ICON)){exit 4}; $p=Join-Path -Path $d -ChildPath ($env:HW_NAME+'.lnk'); $s=$w.CreateShortcut($p); $s.TargetPath=$env:HW_TARGET; $s.WorkingDirectory=Split-Path -Path $env:HW_TARGET -Parent; $s.IconLocation=$env:HW_ICON+',0'; $s.Description=$env:HW_DESC; $s.Save(); if(Test-Path -LiteralPath $p){exit 0}else{exit 6}" >nul 2>&1
if not errorlevel 1 goto :OK

echo   正在尝试备用方式 ...

rem ---------- 方案 B：Windows 脚本宿主（PowerShell 被禁用时）----------
set "VBS=%TEMP%\hwshortcut_%RANDOM%.vbs"
>  "%VBS%" echo Option Explicit
>> "%VBS%" echo Dim a, fso, sh, sc, t, i, n, d, p
>> "%VBS%" echo Set a = WScript.Arguments
>> "%VBS%" echo t = a(0)
>> "%VBS%" echo i = a(1)
>> "%VBS%" echo n = a(2)
>> "%VBS%" echo Set fso = CreateObject("Scripting.FileSystemObject")
>> "%VBS%" echo If Not fso.FileExists(t) Then WScript.Quit 3
>> "%VBS%" echo If Not fso.FileExists(i) Then WScript.Quit 4
>> "%VBS%" echo Set sh = CreateObject("WScript.Shell")
>> "%VBS%" echo d = sh.SpecialFolders("Desktop")
>> "%VBS%" echo If Len(d) = 0 Then WScript.Quit 5
>> "%VBS%" echo p = fso.BuildPath(d, n + ".lnk")
>> "%VBS%" echo Set sc = sh.CreateShortcut(p)
>> "%VBS%" echo sc.TargetPath = t
>> "%VBS%" echo sc.WorkingDirectory = fso.GetParentFolderName(t)
>> "%VBS%" echo sc.IconLocation = i + ",0"
>> "%VBS%" echo sc.Description = "班级每日作业展示板"
>> "%VBS%" echo sc.Save
>> "%VBS%" echo If Not fso.FileExists(p) Then WScript.Quit 6
>> "%VBS%" echo WScript.Quit 0

cscript //nologo "%VBS%" "%TARGET%" "%ICON%" "%LNKNAME%" >nul 2>&1
set "ERR=%errorlevel%"
del "%VBS%" >nul 2>&1
if "%ERR%"=="0" goto :OK

echo.
echo   [错误] 创建快捷方式失败，错误码 %ERR%
echo          可能是安全软件拦截了脚本。可手动创建：
echo          右键 index.html ^-^> 发送到 ^-^> 桌面快捷方式，
echo          再右键该快捷方式 ^-^> 属性 ^-^> 更改图标 ^-^> 浏览选 ico。
goto :FAIL

:OK
echo.
echo   [完成] 桌面已生成「班级每日作业展示板」快捷方式
echo          图标已应用 homework-board.ico
echo          双击即可打开；若图标未刷新，在桌面按 F5。
echo.
timeout /t 6 >nul 2>&1
exit /b 0

:FAIL
echo.
echo   操作未完成，按任意键关闭窗口。
pause >nul
exit /b 1
