# 卦眼开发机 Flutter 包装脚本（本机专用，含环境修复）。
#
# 解决本机三类问题：
# 1. %APPDATA% 被 DSH harness 重定向到只读位置 → 重定向到 %TEMP%；
# 2. 命令行进程不读系统代理 → 显式走 http://127.0.0.1:10808；
# 3. flutter.bat 在本机挂起 → 直调 flutter_tools.snapshot。
#
# 用法：pwsh scripts/flutter.ps1 <flutter 参数...>
# 注意：本脚本需要能写入 Flutter SDK（E:\MyApp\app-flutter），
#       在 DSH 沙箱下运行 flutter 命令时需 danger-full-access。
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'

$env:APPDATA = Join-Path $env:TEMP 'dsh-flutter-appdata'
$env:LOCALAPPDATA = Join-Path $env:TEMP 'dsh-flutter-localappdata'
$env:FLUTTER_ALREADY_LOCKED = 'true'
$env:HTTP_PROXY = 'http://127.0.0.1:10808'
$env:HTTPS_PROXY = 'http://127.0.0.1:10808'
$env:NO_PROXY = '127.0.0.1,localhost'

$dart = 'E:\MyApp\app-flutter\bin\cache\dart-sdk\bin\dart.exe'
$packages = 'E:\MyApp\app-flutter\packages\flutter_tools\.dart_tool\package_config.json'
$snapshot = 'E:\MyApp\app-flutter\bin\cache\flutter_tools.snapshot'

& $dart --packages=$packages $snapshot @FlutterArgs
exit $LASTEXITCODE
