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

if not exist dist mkdir dist

echo [3/3] 打包发布文件...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path 'build/windows/x64/runner/Release/*' -DestinationPath 'dist/zerotierapi-windows-x64.zip' -Force"
if %ERRORLEVEL% NEQ 0 exit /b 1

echo 完成: dist\zerotierapi-windows-x64.zip
echo 解压后双击 zerotierapi.exe 即可运行。

endlocal
