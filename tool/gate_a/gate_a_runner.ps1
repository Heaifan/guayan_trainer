# Gate A 运行器（含机器绝对路径，已 .gitignore 不入库）
#
# 背景与本机 `scripts/flutter.local.ps1` 相同：$env:PATH 被裁剪，
# `dart` 不在 PATH 中，且 dart.exe 依赖 System32 下的基础命令。
# 本脚本在调用 dart 前把 System32 与工具链目录重新拼进 PATH。
#
# 用法（仓库根目录）：
#   pwsh -File tool/gate_a/gate_a_runner.ps1 run
#   pwsh -File tool/gate_a/gate_a_runner.ps1 test
#   pwsh -File tool/gate_a/gate_a_runner.ps1 analyze

$ErrorActionPreference = 'Stop'

# dart/flutter 会把正常进度写进 stderr；Stop 会把它当致命错误中断脚本。
$DartRoot = 'D:\MyApp\app-flutter\flutter\bin\cache\dart-sdk'
$GitRoot = 'D:\MyApp\app-git\Git'

$dartExe = Join-Path $DartRoot 'bin\dart.exe'

if (-not (Test-Path $dartExe)) {
  throw "找不到 dart: $dartExe（请修改本脚本顶部的 `$DartRoot）"
}

$systemDirs = @(
  "$env:SystemRoot\System32"
  "$env:SystemRoot"
  "$env:SystemRoot\System32\Wbem"
)
$toolDirs = @(
  (Join-Path $DartRoot 'bin')
  (Join-Path $GitRoot 'cmd')
)

$existing = $env:PATH -split ';' | Where-Object { $_ -ne '' }
$missing = @($systemDirs + $toolDirs) |
  Where-Object { $existing -notcontains $_ } |
  Select-Object -Unique
$env:PATH = (@($missing) + $existing) -join ';'

$ErrorActionPreference = 'Continue'

switch ($args[0]) {
  'run' { & $dartExe run tool/gate_a/gate_a_main.dart @($args[1..($args.Count - 1)]) }
  'test' { & $dartExe run tool/gate_a/gate_a_selftest.dart }
  default {
    Write-Host '用法: pwsh -File tool/gate_a/gate_a_runner.ps1 [run|test]'
    exit 1
  }
}
exit $LASTEXITCODE
