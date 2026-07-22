$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$required = @(
    'infra/README.md', 'infra/topology.md', 'infra/config/lab.example.psd1',
    'infra/scripts/Test-LabConfig.ps1', 'infra/scripts/Test-LabHost.ps1',
    'infra/scripts/New-LabPlan.ps1', 'infra/.gitignore'
)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $path))) {
        $errors.Add("Missing required file: $path")
    }
}

$configPath = Join-Path $repoRoot 'infra/config/lab.example.psd1'
$config = Import-PowerShellDataFile -LiteralPath $configPath
if ($config.Governance.NoPublicIngress -ne $true) { $errors.Add('NoPublicIngress must be true.') }
if ($config.Network.SwitchType -ne 'Internal') { $errors.Add('SwitchType must be Internal.') }
if ($config.Environment -ne 'test-only') { $errors.Add('Environment must be test-only.') }
if (@($config.Vms).Count -ne 5) { $errors.Add('Exactly five isolated component VMs must be defined.') }
if (@($config.Vms | Where-Object StartDisconnected -ne $true).Count) {
    $errors.Add('Every VM must start disconnected.')
}
$names = @($config.Vms | ForEach-Object Name)
if ($names.Count -ne ($names | Sort-Object -Unique).Count) { $errors.Add('VM names must be unique.') }
$addresses = @($config.Vms | ForEach-Object Address)
if ($addresses.Count -ne ($addresses | Sort-Object -Unique).Count) { $errors.Add('VM addresses must be unique.') }

$scriptText = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'infra/scripts') -Filter '*.ps1' |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }
$scriptFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'infra/scripts') -Filter '*.ps1')
foreach ($scriptFile in $scriptFiles) {
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $scriptFile.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    )
    foreach ($parseError in @($parseErrors)) {
        $errors.Add("PowerShell syntax error in $($scriptFile.Name): $($parseError.Message)")
    }
}
$mutatingHyperVCmdlets = @(
    'New-VMSwitch', 'Set-VMSwitch', 'Remove-VMSwitch', 'New-VM', 'Set-VM',
    'Remove-VM', 'New-VHD', 'Set-VMNetworkAdapter', 'New-NetNat',
    'New-NetFirewallRule', 'Set-NetFirewallRule', 'New-NetRoute'
)
foreach ($cmdlet in $mutatingHyperVCmdlets) {
    if ($scriptText -match "(?m)^\s*$([regex]::Escape($cmdlet))\b") {
        $errors.Add("Mutating host command is prohibited in the preparation package: $cmdlet")
    }
}

$allInfraText = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'infra') -Recurse -File |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }
if ($allInfraText -match '(?i)authorization:\s*bearer|eyJ[A-Za-z0-9_-]{10,}\.eyJ') {
    $errors.Add('Potential raw authentication material found in infra files.')
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Host 'INFRA STATIC TESTS: PASS'
Write-Host 'The package contains configuration, planning, and read-only checks only.'
