$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repoRoot 'collector/Test-SanitizedEvent.ps1'
$fixture = Join-Path $repoRoot 'collector/fixtures/baseline-sanitized.json'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $fixture
if ($LASTEXITCODE -ne 0) { throw 'The approved sanitized fixture was rejected.' }

$badPath = Join-Path ([System.IO.Path]::GetTempPath()) 'entra-aitm-forbidden-event.json'
try {
    $bad = Get-Content -Raw -LiteralPath $fixture | ConvertFrom-Json
    $bad | Add-Member -NotePropertyName 'access_token' -NotePropertyValue 'forbidden-test-value'
    $bad | ConvertTo-Json | Set-Content -LiteralPath $badPath -Encoding utf8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $badPath *> $null
    $rejectionExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($rejectionExitCode -eq 0) { throw 'A forbidden authentication field was accepted.' }
} finally {
    Remove-Item -LiteralPath $badPath -Force -ErrorAction SilentlyContinue
}

Write-Host 'SANITIZED CONTRACT TESTS: PASS'
