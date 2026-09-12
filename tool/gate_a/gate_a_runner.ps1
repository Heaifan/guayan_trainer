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
#   powershell -File tool/gate_a/gate_a_runner.ps1 gov
#   powershell -File tool/gate_a/gate_a_runner.ps1 imports
#   powershell -File tool/gate_a/gate_a_runner.ps1 diag
#   powershell -File tool/gate_a/gate_a_runner.ps1 solve <from> <to>
#
# POST-R3-GOV-01 (S0): four of the eight modes used to point at files that no
# longer exist after the tool/gate_a subdirectory migration (commit 1541660):
#   tools/oracle_residual.dart, tools/precision_closeout.dart,
#   tools/enumerate_hexagrams.dart, tools/solve_cases.dart.
# Every mode therefore now resolves through $Scripts and refuses to run when
# its target is missing, instead of silently producing no evidence.
#
# 'verify' runs the read-only gate chain in a fixed order and stops at the
# first failure. The order matters: 'generate' must succeed BEFORE 'gov',
# because gov compares gate-a/*.md against the golden SHA256 -- if the
# generator crashed, the old files are still on disk and the hash comparison
# would look like a PASS while proving nothing.

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

# Single source of truth for mode -> script path.
$Scripts = @{
  'test'      = 'tool/gate_a/tools/selftest.dart'
  'cross'     = 'tool/gate_a/astro/cross_source.dart'
  'residual'  = 'tool/gate_a/tools/diag/oracle_residual.dart'
  'closeout'  = 'tool/gate_a/tools/diag/precision_closeout.dart'
  'enumerate' = 'tool/gate_a/tools/checks/enumerate_hexagrams.dart'
  'diag'      = 'tool/gate_a/astro/diag_oracle.dart'
  'gov'       = 'tool/gate_a/tools/checks/gov_selfcheck.dart'
  'imports'   = 'tool/gate_a/tools/checks/check_imports.dart'
}

if ($args.Count -lt 1) {
  Write-Host 'usage: gate_a_runner.ps1 [run <script.dart>|test|cross|residual|closeout|enumerate|gov|imports|diag|solve|verify]'
  exit 1
}

$mode = [string]$args[0]

# Read-only gate chain, in dependency order. Stops at the first failure.
if ($mode -eq 'verify') {
  $chain = @(
    @{ name = 'imports';  script = 'tool/gate_a/tools/checks/check_imports.dart' }
    @{ name = 'generate'; script = 'tool/gate_a/gate_a_main.dart' }
    @{ name = 'gov';      script = 'tool/gate_a/tools/checks/gov_selfcheck.dart' }
    @{ name = 'selftest'; script = 'tool/gate_a/tools/selftest.dart' }
    @{ name = 'cross';    script = 'tool/gate_a/astro/cross_source.dart' }
  )
  $failed = @()
  foreach ($step in $chain) {
    Write-Host ''
    Write-Host "=== $($step.name) ==="
    if (-not (Test-Path $step.script)) {
      Write-Host "MISSING script for step '$($step.name)': $($step.script)"
      $failed += $step.name
      break
    }
    & $dartExe run $step.script
    if ($LASTEXITCODE -ne 0) {
      Write-Host "STEP FAILED: $($step.name) (exit $LASTEXITCODE)"
      $failed += $step.name
      if ($step.name -eq 'generate') {
        Write-Host 'STOP: generator failed, so the golden SHA256 check would prove NOTHING.'
      }
      break
    }
  }
  Write-Host ''
  if ($failed.Count -eq 0) {
    Write-Host 'VERIFY: PASS (imports + generate + gov + selftest + cross)'
    exit 0
  }
  Write-Host "VERIFY: FAIL (first failing step: $($failed[0]))"
  exit 1
}

if ($mode -eq 'solve') {
  if ($args.Count -lt 3) { Write-Host 'solve needs <from> <to> hexagram names'; exit 1 }
  $solveScript = 'tool/gate_a/tools/checks/solve_cases.dart'
  if (-not (Test-Path $solveScript)) {
    Write-Host "MISSING script for mode 'solve': $solveScript"
    exit 1
  }
  & $dartExe run $solveScript ([string]$args[1]) ([string]$args[2])
  exit $LASTEXITCODE
}

if ($Scripts.ContainsKey($mode)) {
  $script = $Scripts[$mode]
  if (-not (Test-Path $script)) {
    Write-Host "MISSING script for mode '$mode': $script"
    exit 1
  }
  & $dartExe run $script
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

$target = [string]$args[1]
if (-not (Test-Path $target)) {
  Write-Host "MISSING script: $target"
  exit 1
}

& $dartExe run $target
exit $LASTEXITCODE
