$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredPaths = @('README.md','SECURITY.md','docs/rules-of-engagement.md','docs/project-plan.md','dashboard','collector','scenarios','detections','infra','tests','skill/SKILL.md')
$missing = @($requiredPaths | Where-Object { -not (Test-Path -LiteralPath (Join-Path $repoRoot $_)) })
$roe = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'docs/rules-of-engagement.md')
$sections = @('Owners and stop authority','Time window and participants','Approved scope','Explicit production exclusions','Data handling and retention','Stop, incident, and restart procedure','Approval record','Phase 0 exit checklist')
$missingSections = @($sections | Where-Object { $roe -notmatch [regex]::Escape($_) })
$unresolved = ([regex]::Matches($roe, '\[REQUIRED(?:[^\]]*)\]')).Count
$pending = ([regex]::Matches($roe, '\| Pending \|')).Count
if ($missing.Count) { Write-Error "Missing paths: $($missing -join ', ')" }
if ($missingSections.Count) { Write-Error "Missing ROE sections: $($missingSections -join ', ')" }
if ($unresolved -or $pending) {
    Write-Host 'PHASE 0 GATE: OPEN'
    Write-Host "Unresolved required fields: $unresolved"
    Write-Host "Pending approval rows: $pending"
    exit 2
}
if ($roe -notmatch 'Gate decision:\s*(?:CLOSED|APPROVED)') { Write-Error 'Explicit gate decision missing.' }
Write-Host 'PHASE 0 GATE: CLOSED'
