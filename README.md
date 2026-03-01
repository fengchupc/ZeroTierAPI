# ZeroTierAPI (Flutter)

基于 Flutter 的 ZeroTier 设备状态查看应用。当前建议优先走桌面端（Windows / macOS / Linux）发布。

## 当前策略

- 桌面端优先：先做到“打包后双击直接运行”。
- 移动端后续：Android / iOS 暂不作为当前交付目标。
- Web 仍可用，但 Web 模式通常需要本地代理处理 CORS。
- 内置双字体：Noto Sans（英文主字体，约 608KB）+ Droid Sans Fallback（中文兜底，约 3.9MB），避免中英文任一方块乱码。

## 前置要求

- Flutter SDK（建议 3.41+）
- Dart SDK（随 Flutter 提供）
- ZeroTier API Token

## 开发运行（桌面调试）

```bash
flutter pub get
flutter run -d linux
```

在 Windows / macOS 上分别使用 `-d windows` 或 `-d macos`。

## 一键打包（桌面）

### Linux（在 Linux 机器上执行）

```bash
./scripts/package_desktop.sh
```

产物：`dist/zerotierapi-linux-<arch>.tar.gz`  
解压后双击 `zerotierapi` 即可运行。

### Windows（在 Windows 机器上执行）

```bat
scripts\package_desktop.bat
```

产物：`dist\zerotierapi-windows-<arch>.zip`（支持 `x86` / `x64` / `arm` / `arm64`）  
解压后双击 `zerotierapi.exe` 即可运行。

### macOS（在 macOS 机器上执行）

```bash
./scripts/package_desktop_macos.sh
```

产物：`dist/zerotierapi-macos.zip`  
解压后双击 `zerotierapi.app` 即可运行。

## GitHub Actions 自动打包（Win/macOS/Linux）

仓库已提供工作流：`.github/workflows/desktop-build.yml`

- 触发方式：
  - push 到 `main`
  - 手动触发（Actions -> Build Desktop Packages -> Run workflow）
- 构建平台：Windows / macOS / Linux
- 产物：在每次工作流运行的 Artifacts 中下载
  - `zerotierapi-windows`
  - `zerotierapi-macos`
  - `zerotierapi-linux`
- 自动发布：工作流成功后会自动创建 GitHub Release，并附带上述产物

## Web 运行（可选）

推荐使用一键脚本：

```bash
./scripts/run_web_with_proxy.sh
```

行为说明：
- 默认启动 proxy（`127.0.0.1:3000`）+ Flutter web-server（`127.0.0.1:8080`）。
- 若 proxy 端口或 web 端口已被占用，会自动跳过对应服务，不会中断脚本。
- 默认使用 release 模式；可用 `--debug` 启动 debug 模式。

可选环境变量：

```bash
PROXY_PORT=3001 WEB_PORT=8081 ./scripts/run_web_with_proxy.sh
```

前端说明：
- Web 默认请求 `http://<当前页面主机>:3000/api`，因此在局域网用 IP 打开页面时也可正常访问代理。
- 如需自定义代理地址，可在启动时传入：`--dart-define=ZT_PROXY_URL=http://127.0.0.1:3000/api`。

## 配置

首次启动后，在配置页面填写 ZeroTier API Token 与 Network ID，应用会加密保存在本地并在下次启动自动回填。

