[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ConfigPath,

    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile -LiteralPath $ConfigPath
$raw = Get-Content -Raw -LiteralPath $ConfigPath
if ($raw -match '\[REQUIRED') {
    throw 'Configuration contains unresolved [REQUIRED] values; no plan was generated.'
}
if ($config.Governance.NoPublicIngress -ne $true -or $config.Network.SwitchType -ne 'Internal') {
    throw 'Guardrail violation: plan requires no public ingress and an Internal switch.'
}

$plan = [ordered]@{
    PlanVersion = '1.0'
    GeneratedUtc = [DateTime]::UtcNow.ToString('o')
    Project = $config.ProjectName
    Authorization = [ordered]@{
        Record = $config.Governance.AuthorizationRecord
        SecurityApproval = $config.Governance.SecurityApprovalRecord
        NetworkApproval = $config.Governance.NetworkApprovalRecord
        Expiry = $config.Governance.ApprovalExpiry
        KillSwitchOwner = $config.Governance.KillSwitchOwner
    }
    Safety = [ordered]@{
        DeploymentAuthorized = $false
        PublicIngress = $false
        SwitchType = 'Internal'
        StartVmsDisconnected = $true
        ProductionRoutesPermitted = $false
    }
    Host = [ordered]@{
        ComputerName = $config.Host.ComputerName
        VmRoot = $config.Host.VmRoot
        SnapshotRoot = $config.Host.SnapshotRoot
    }
    Network = [ordered]@{
        SwitchName = $config.Network.InternalSwitchName
        LabCidr = $config.Network.LabCidr
        Gateway = $config.Network.GatewayAddress
        Dns = $config.Network.DnsAddress
        ApprovedCloudFlows = @($config.Network.ApprovedCloudFlows)
    }
    Vms = @($config.Vms | ForEach-Object {
        [ordered]@{
            Name = $_.Name; Role = $_.Role; Os = $_.Os; Cpu = $_.Cpu
            MemoryGB = $_.MemoryGB; DiskGB = $_.DiskGB; Address = $_.Address
            StartDisconnected = $true
        }
    })
    RequiredManualReviews = @(
        'Security approval and expiry are valid.',
        'Network allowlist and production-deny list were peer reviewed.',
        'ISO/VHDX checksums match approved image records.',
        'Kill switch has a named backup and tested offline procedure.',
        'Deployment tooling remains separately controlled and is not in this plan.'
    )
}

$json = $plan | ConvertTo-Json -Depth 8
if ($OutputPath) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $OutputPath -Value $json -Encoding utf8
    Write-Host "Sanitized plan written to $OutputPath"
} else {
    $json
}
Write-Host 'No host changes were made.'
