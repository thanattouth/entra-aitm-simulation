[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$findings = [System.Collections.Generic.List[object]]::new()

function Add-Finding([string]$Check, [string]$Status, [string]$Detail) {
    $findings.Add([pscustomobject]@{ Check = $Check; Status = $Status; Detail = $Detail })
}

if (-not $IsWindows) {
    Add-Finding 'Operating system' 'FAIL' 'Hyper-V host review requires Windows.'
} else {
    Add-Finding 'Operating system' 'PASS' 'Windows detected.'
}

$hyperV = Get-Module -ListAvailable -Name Hyper-V | Select-Object -First 1
if ($hyperV) { Add-Finding 'Hyper-V module' 'PASS' "Version $($hyperV.Version)" }
else { Add-Finding 'Hyper-V module' 'FAIL' 'Hyper-V PowerShell module not found.' }

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Add-Finding 'Administrator session' $(if ($isAdmin) { 'PASS' } else { 'WARN' }) $(if ($isAdmin) { 'Elevated.' } else { 'Read-only checks may be incomplete.' })

if ($config.Host.ComputerName -notmatch '^\[REQUIRED') {
    $matchesHost = $env:COMPUTERNAME -ieq $config.Host.ComputerName
    Add-Finding 'Approved host' $(if ($matchesHost) { 'PASS' } else { 'FAIL' }) "Current=$env:COMPUTERNAME Approved=$($config.Host.ComputerName)"
}

if ($hyperV) {
    $switch = Get-VMSwitch -Name $config.Network.InternalSwitchName -ErrorAction SilentlyContinue
    if (-not $switch) { Add-Finding 'Switch-name collision' 'PASS' 'No existing switch uses the proposed name.' }
    elseif ($switch.SwitchType -eq 'Internal') { Add-Finding 'Existing switch' 'WARN' 'An Internal switch already uses the proposed name; peer review is required.' }
    else { Add-Finding 'Existing switch' 'FAIL' "Proposed name belongs to a $($switch.SwitchType) switch." }

    foreach ($vm in $config.Vms) {
        $existing = Get-VM -Name $vm.Name -ErrorAction SilentlyContinue
        Add-Finding "VM collision: $($vm.Name)" $(if ($existing) { 'FAIL' } else { 'PASS' }) $(if ($existing) { 'VM already exists.' } else { 'Name is available.' })
    }
}

foreach ($rootName in @('VmRoot','SnapshotRoot')) {
    $root = $config.Host[$rootName]
    if ($root -match '^\[REQUIRED') {
        Add-Finding $rootName 'FAIL' 'Path is unresolved.'
        continue
    }
    $drive = [System.IO.Path]::GetPathRoot($root)
    $driveInfo = Get-PSDrive -Name $drive.TrimEnd('\').TrimEnd(':') -ErrorAction SilentlyContinue
    if (-not $driveInfo) { Add-Finding $rootName 'FAIL' "Drive for $root is unavailable."; continue }
    $freeGB = [math]::Round($driveInfo.Free / 1GB, 1)
    Add-Finding $rootName $(if ($freeGB -ge $config.Host.MinimumFreeSpaceGB) { 'PASS' } else { 'FAIL' }) "Free=${freeGB}GB Required=$($config.Host.MinimumFreeSpaceGB)GB"
}

$findings | Format-Table -AutoSize
$failed = @($findings | Where-Object Status -eq 'FAIL').Count
Write-Host "Host review failures: $failed"
Write-Host 'No host changes were made.'
if ($failed) { exit 2 }
