@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0\.."

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  if exist "%USERPROFILE%\tools\flutter\bin\flutter.bat" (
    set "PATH=%USERPROFILE%\tools\flutter\bin;%PATH%"
  )
)

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] flutter 未找到，请先安装 Flutter 或配置 PATH。
  exit /b 1
)

echo [1/3] 拉取依赖...
call flutter pub get || exit /b 1

echo [2/3] 构建 Windows release...
call flutter build windows || exit /b 1

set "BUILD_DIR="
set "ARCH="
for %%A in (x64 arm64 arm x86) do (
  if exist "build\windows\%%A\runner\Release\zerotierapi.exe" (
    set "BUILD_DIR=build\windows\%%A\runner\Release"
    set "ARCH=%%A"
    goto :found_build
  )
)

if not exist "build\windows" (
  echo [ERROR] 找不到 Windows 构建目录，构建可能失败。
  exit /b 1
)

for /d %%D in ("build\windows\*") do (
  if exist "%%~fD\runner\Release\zerotierapi.exe" (
    set "BUILD_DIR=%%~fD\runner\Release"
    set "ARCH=%%~nxD"
    goto :found_build
  )
)

echo [ERROR] 找不到 Windows Release 目录，构建可能失败。
exit /b 1

:found_build
if not exist dist mkdir dist
set "OUT_FILE=dist\zerotierapi-windows-!ARCH!.zip"

echo [3/3] 打包发布文件...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '!BUILD_DIR!\*' -DestinationPath '!OUT_FILE!' -Force"
if %ERRORLEVEL% NEQ 0 exit /b 1

echo 完成: !OUT_FILE!
echo 解压后双击 zerotierapi.exe 即可运行。

endlocal
