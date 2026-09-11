# Gate A runner (local absolute paths; never committed to version control logic).
#
# Why this file exists: on this machine $env:PATH is trimmed so that `dart` is
# not found, and dart.exe needs System32 on PATH to run at all. This wrapper
# rebuilds a usable PATH before invoking dart.
#
# NOTE: this file is deliberately ASCII-only. Windows PowerShell 5.1 reads
# .ps1 files without a BOM as ANSI, so non-ASCII comments here would be mangled
# into a syntax error. All Chinese documentation lives in the Dart sources,
# which are always read as UTF-8.
#
# Usage (from the repository root):
#   powershell -File tool/gate_a/gate_a_runner.ps1 run
#   powershell -File tool/gate_a/gate_a_runner.ps1 run tool/gate_a/gate_a_solve.dart
#   powershell -File tool/gate_a/gate_a_runner.ps1 test
#   powershell -File tool/gate_a/gate_a_runner.ps1 astro 2026
#   powershell -File tool/gate_a/gate_a_runner.ps1 enumerate

$ErrorActionPreference = 'Stop'

$DartRoot = 'D:\MyApp\app-flutter\flutter\bin\cache\dart-sdk'
$GitRoot = 'D:\MyApp\app-git\Git'

$dartExe = Join-Path $DartRoot 'bin\dart.exe'
if (-not (Test-Path $dartExe)) {
  throw "dart not found: $dartExe (edit `$DartRoot at the top of this script)"
}

$systemDirs = @(
  "$env:SystemRoot\System32"
  "$env:SystemRoot"
  "$env:SystemRoot\System32\Wbem"
  "$env:SystemRoot\System32\WindowsPowerShell\v1.0"
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

# dart writes normal progress to stderr; Stop would abort on it.
$ErrorActionPreference = 'Continue'

$mode = if ($args.Count -gt 0) { $args[0] } else { 'run' }
$rest = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] } else { @() }

switch ($mode) {
  'run' {
    $target = if ($rest.Count -gt 0) { $rest[0] } else { 'tool/gate_a/gate_a_main.dart' }
    if ($rest.Count -gt 1) {
      & $dartExe run $target @($rest[1..($rest.Count - 1)])
    } else {
      & $dartExe run $target
    }
  }
  'test' { & $dartExe run tool/gate_a/gate_a_selftest.dart }
  'astro' { & $dartExe run tool/gate_a/gate_a_verify_astronomy.dart @rest }
  'enumerate' { & $dartExe run tool/gate_a/gate_a_enumerate.dart @rest }
  default {
    Write-Host 'usage: gate_a_runner.ps1 [run [script.dart]|test|astro [year]|enumerate]'
    exit 1
  }
}
exit $LASTEXITCODE
