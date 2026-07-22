[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$raw = Get-Content -Raw -LiteralPath $Path
$event = $raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

$required = @(
    'schema_version','scenario_id','event_id','timestamp_utc','source',
    'actor_alias','display_ip','device_state','authentication_strength',
    'risk_level','conditional_access_result','reason_code',
    'session_fingerprint','response_status'
)
$allowed = $required
$names = @($event.PSObject.Properties.Name)

foreach ($name in $required) {
    if ($name -notin $names) { $errors.Add("Missing required field: $name") }
}
foreach ($name in $names) {
    if ($name -notin $allowed) { $errors.Add("Field is not allowlisted: $name") }
}

$forbiddenPattern = '(?i)(password|otp|cookie|authorization|access[_-]?token|refresh[_-]?token|id[_-]?token|bearer\s+|eyJ[A-Za-z0-9_-]{10,}\.)'
if ($raw -match $forbiddenPattern) { $errors.Add('Forbidden authentication material name or value detected.') }

if ($event.schema_version -ne '1.0') { $errors.Add('schema_version must be 1.0.') }
if ($event.scenario_id -notmatch '^[A-Z0-9][A-Z0-9_-]{2,39}$') { $errors.Add('Invalid scenario_id.') }
if ($event.event_id -notmatch '^[A-Z0-9][A-Z0-9_-]{2,63}$') { $errors.Add('Invalid event_id.') }
if ($event.actor_alias -notmatch '^synthetic-[a-z0-9-]{1,40}$') { $errors.Add('actor_alias must be synthetic.') }
if ($event.display_ip -notmatch '^(192\.0\.2|198\.51\.100|203\.0\.113)\.(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$') {
    $errors.Add('display_ip must use a documentation range.')
}
if ($event.session_fingerprint -notmatch '^sha256:[a-f0-9]{64}$') {
    $errors.Add('session_fingerprint must be a SHA-256 fingerprint, not a credential.')
}
$timestamp = [datetimeoffset]::MinValue
if (-not [datetimeoffset]::TryParse($event.timestamp_utc, [ref]$timestamp) -or $timestamp.Offset -ne [timespan]::Zero) {
    $errors.Add('timestamp_utc must be a valid UTC timestamp.')
}

$enumRules = @{
    source = @('entra_signin','entra_audit','lab_marker','operator')
    device_state = @('unmanaged','registered','compliant','unknown')
    authentication_strength = @('ordinary_mfa','phishing_resistant','unknown')
    risk_level = @('none','low','medium','high','unknown')
    conditional_access_result = @('allowed','not_applied','report_only','blocked','restricted','unknown')
    response_status = @('none','observed','contained','revoked','reset','blocked')
}
foreach ($field in $enumRules.Keys) {
    if ($event.$field -notin $enumRules[$field]) { $errors.Add("Invalid value for $field.") }
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Host 'SANITIZED EVENT: PASS'
Write-Host "Scenario=$($event.scenario_id) Event=$($event.event_id)"
