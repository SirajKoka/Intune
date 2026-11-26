<#
 Intune Remediation - REMEDIATION
 Renames the device to <Prefix><Serial> (max 15 chars, NetBIOS limit).
 Run as SYSTEM, 64-bit PowerShell. The rename takes effect after a reboot.
#>
$Prefix = 'TPK-'
$MaxLen = 15

# None     = never restart; the name applies at the next natural reboot.
# IfNoUser = restart only when nobody is signed in (ESP / overnight). Default.
# Always   = force a restart with a warning. Fleet-wide, this WILL interrupt users.
$RestartMode      = 'IfNoUser'
$RestartDelaySecs = 600

$log = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\DeviceRename.log"
function Write-Log([string]$Message) { "$(Get-Date -Format s) $Message" | Tee-Object -FilePath $log -Append }

#region SharedNameLogic - keep identical in Detect.ps1 and Remediate.ps1 (enforced by Pester)
function Get-ExpectedDeviceName {
    param([string]$Serial, [string]$Prefix, [int]$MaxLen = 15)
    $clean = ($Serial -replace '[^A-Za-z0-9-]', '').Trim('-')
    $badSerials = 'SystemSerialNumber', 'ToBeFilledByOEM', 'DefaultString', 'None', '0', '123456789'
    if ([string]::IsNullOrWhiteSpace($clean) -or $badSerials -contains $clean) { return $null }
    $room = $MaxLen - $Prefix.Length
    if ($room -lt 1) { throw "Prefix '$Prefix' leaves no room for the serial within $MaxLen chars." }
    # Keep the tail of the serial: that's where the unique digits are.
    if ($clean.Length -gt $room) { $clean = $clean.Substring($clean.Length - $room) }
    ($Prefix + $clean).ToUpper()
}
#endregion SharedNameLogic

try {
    $serial  = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
    $newName = Get-ExpectedDeviceName -Serial $serial -Prefix $Prefix -MaxLen $MaxLen
    if (-not $newName) {
        Write-Log "Serial not usable ('$serial'); aborting."
        exit 1
    }

    $pending = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' -ErrorAction SilentlyContinue).ComputerName
    if ($env:COMPUTERNAME -ieq $newName) { Write-Log "Already named $newName"; exit 0 }

    if ($pending -ine $newName) {
        Write-Log "Renaming $env:COMPUTERNAME -> $newName"
        Rename-Computer -NewName $newName -Force -ErrorAction Stop
        Write-Log 'Rename queued. Reboot required.'
    }
    else {
        Write-Log "Rename to $newName already pending."
    }

    $userSignedIn = [bool](Get-CimInstance -ClassName Win32_ComputerSystem).UserName
    $restart = switch ($RestartMode) {
        'Always'   { $true }
        'IfNoUser' { -not $userSignedIn }
        default    { $false }
    }

    if ($restart) {
        shutdown.exe /r /t $RestartDelaySecs /c "This device is being renamed to $newName and will restart shortly."
        Write-Log "Restart scheduled in $RestartDelaySecs seconds (mode=$RestartMode)."
    }
    else {
        Write-Log "No restart (mode=$RestartMode, userSignedIn=$userSignedIn). Name applies at next reboot."
    }
    exit 0
}
catch {
    Write-Log "Remediation error: $($_.Exception.Message)"
    exit 1
}
