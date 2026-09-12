# Gate A runner (local absolute paths).
#
# ASCII-only on purpose: Windows PowerShell 5.1 mis-parses this file when it
# contains non-ASCII comments or long quoted paths inside blocks, so all
# documentation lives in the Dart sources instead.
#
# Usage (from the repository root):
#   powershell -File tool/gate_a/gate_a_runner.ps1 run tool/gate_a/gate_a_main.dart
#   powershell -File tool/gate_a/gate_a_runner.ps1 test
#   powershell -File tool/gate_a/gate_a_runner.ps1 cross
#   powershell -File tool/gate_a/gate_a_runner.ps1 residual
#   powershell -File tool/gate_a/gate_a_runner.ps1 closeout
#   powershell -File tool/gate_a/gate_a_runner.ps1 enumerate

$ErrorActionPreference = 'Stop'

$DartRoot = 'D:\MyApp\app-flutter\flutter\bin\cache\dart-sdk'
$GitRoot = 'D:\MyApp\app-git\Git'

$dartExe = Join-Path $DartRoot 'bin\dart.exe'
if (-not (Test-Path $dartExe)) {
  throw "dart not found: $dartExe"
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

# dart writes progress to stderr; Stop would abort on it.
$ErrorActionPreference = 'Continue'

if ($args.Count -lt 1) {
  Write-Host 'usage: gate_a_runner.ps1 [run <script.dart>|test|cross|residual|closeout|enumerate|diag|solve]'
  exit 1
}

$mode = [string]$args[0]

if ($mode -eq 'test') { & $dartExe run tool/gate_a/tools/selftest.dart; exit $LASTEXITCODE }
if ($mode -eq 'cross') { & $dartExe run tool/gate_a/astro/cross_source.dart; exit $LASTEXITCODE }
if ($mode -eq 'residual') { & $dartExe run tool/gate_a/tools/oracle_residual.dart; exit $LASTEXITCODE }
if ($mode -eq 'closeout') { & $dartExe run tool/gate_a/tools/precision_closeout.dart; exit $LASTEXITCODE }
if ($mode -eq 'enumerate') { & $dartExe run tool/gate_a/tools/enumerate_hexagrams.dart; exit $LASTEXITCODE }
if ($mode -eq 'diag') { & $dartExe run tool/gate_a/astro/diag_oracle.dart; exit $LASTEXITCODE }
if ($mode -eq 'solve') {
  if ($args.Count -lt 3) { Write-Host 'solve needs <from> <to> hexagram names'; exit 1 }
  & $dartExe run tool/gate_a/tools/solve_cases.dart ([string]$args[1]) ([string]$args[2])
  exit $LASTEXITCODE
}

if ($mode -ne 'run') {
  Write-Host "unknown mode: $mode"
  exit 1
}

if ($args.Count -lt 2) {
  Write-Host 'run mode needs a script path, e.g. run tool/gate_a/gate_a_main.dart'
  exit 1
}

& $dartExe run ([string]$args[1])
exit $LASTEXITCODE
