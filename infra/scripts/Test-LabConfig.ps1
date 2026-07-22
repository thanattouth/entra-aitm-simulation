[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError([string]$Message) {
    $errors.Add($Message)
}

function Test-RequiredValue($Value, [string]$Path) {
    if ($null -eq $Value) {
        Add-ValidationError "$Path is missing."
        return
    }
    if ($Value -is [string] -and ($Value -match '^\[REQUIRED' -or [string]::IsNullOrWhiteSpace($Value))) {
        Add-ValidationError "$Path is unresolved."
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) { Test-RequiredValue $Value[$key] "$Path.$key" }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $index = 0
        foreach ($item in $Value) {
            Test-RequiredValue $item "$Path[$index]"
            $index++
        }
    }
}

Test-RequiredValue $config 'Config'

if ($config.ProjectName -ne 'entra-aitm-defensive-showcase') {
    Add-ValidationError 'ProjectName must be entra-aitm-defensive-showcase.'
}
if ($config.Environment -ne 'test-only') {
    Add-ValidationError 'Environment must be test-only.'
}
if ($config.Governance.NoPublicIngress -ne $true) {
    Add-ValidationError 'Governance.NoPublicIngress must be true.'
}
if ($config.Network.SwitchType -ne 'Internal') {
    Add-ValidationError 'Only an Internal Hyper-V switch is allowed.'
}
if ($config.Network.InternalSwitchName -notmatch '^entra-aitm-lab-[a-z0-9-]+$') {
    Add-ValidationError 'InternalSwitchName must use the entra-aitm-lab- prefix.'
}
if ($config.Network.LabCidr -notmatch '^10\.(?:\d{1,3}\.){2}0/24$') {
    Add-ValidationError 'LabCidr must be an approved RFC1918 10.x.x.0/24 range.'
}

foreach ($pathName in @('VmRoot', 'SnapshotRoot')) {
    $value = $config.Host[$pathName]
    if ($value -and $value -notmatch '^\[REQUIRED' -and -not [System.IO.Path]::IsPathRooted($value)) {
        Add-ValidationError "Host.$pathName must be an absolute path."
    }
}

$expectedVms = @('lab-gateway-01','lab-aitm-01','lab-victim-01','lab-attacker-01','lab-monitor-01')
$actualVms = @($config.Vms | ForEach-Object { $_.Name })
foreach ($name in $expectedVms) {
    if ($name -notin $actualVms) { Add-ValidationError "Required VM $name is missing." }
}
if ($actualVms.Count -ne ($actualVms | Sort-Object -Unique).Count) {
    Add-ValidationError 'VM names must be unique.'
}
$addresses = @($config.Vms | ForEach-Object { $_.Address })
if ($addresses.Count -ne ($addresses | Sort-Object -Unique).Count) {
    Add-ValidationError 'VM addresses must be unique.'
}
foreach ($vm in $config.Vms) {
    if ($vm.StartDisconnected -ne $true) { Add-ValidationError "$($vm.Name) must start disconnected." }
    if ($vm.Cpu -lt 1 -or $vm.MemoryGB -lt 2 -or $vm.DiskGB -lt 20) {
        Add-ValidationError "$($vm.Name) has invalid minimum resources."
    }
}

foreach ($flow in @($config.Network.ApprovedCloudFlows)) {
    if ($flow.Destination -match '[*?]' -or [string]::IsNullOrWhiteSpace($flow.Destination)) {
        Add-ValidationError 'Cloud-flow destinations must be exact and cannot contain wildcards.'
    }
    if ($flow.Port -notin 1..65535) { Add-ValidationError 'Cloud-flow port is invalid.' }
    if ($flow.Protocol -notin @('TCP','UDP')) { Add-ValidationError 'Cloud-flow protocol must be TCP or UDP.' }
}
if (@($config.Network.ApprovedCloudFlows).Count -eq 0) {
    Add-ValidationError 'At least one exact, approved cloud flow is required before host review.'
}

if ($errors.Count) {
    Write-Host 'INFRA CONFIG: NOT READY'
    $errors | ForEach-Object { Write-Host "- $_" }
    exit 2
}

Write-Host 'INFRA CONFIG: READY FOR HOST REVIEW'
Write-Host "VM definitions: $($config.Vms.Count)"
Write-Host "Approved cloud flows: $(@($config.Network.ApprovedCloudFlows).Count)"
Write-Host 'No host changes were made.'
