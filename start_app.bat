@echo off
echo Starting ZeroTier API Web Application...

REM Start the proxy server in a new window
start "ZeroTier Proxy Server" cmd /c "dart run bin/proxy_server.dart"

REM Wait for a moment to ensure proxy server is started
timeout /t 2 /nobreak

REM Start Flutter web app
start "ZeroTier Web App" cmd /c "flutter run -d edge --web-port=8080"

echo Application started! Please wait for the browser to open... 