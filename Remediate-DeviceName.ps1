<#
 Intune Remediation - REMEDIATION
 Renames the device to TPK-<Serial> (max 15 chars, NetBIOS limit).
 Run as SYSTEM, 64-bit PowerShell. Rename takes effect after a reboot.
#>
$Prefix = 'TPK-'
$MaxLen = 15

# Optional: schedule a reboot so the name applies without user action.
# Set to $true only if you're OK with a forced restart (e.g. during provisioning).
$ScheduleRestart  = $true
$RestartDelaySecs = 600   # 10 min warning to the user

$log = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\DeviceRename.log"
function Write-Log($m) { "$(Get-Date -Format s) $m" | Tee-Object -FilePath $log -Append }

try {
    $serial = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
    $serial = ($serial -replace '[^A-Za-z0-9-]', '').Trim('-')

    $badSerials = 'SystemSerialNumber','ToBeFilledByOEM','Defaultstring','None','0','123456789'
    if ([string]::IsNullOrWhiteSpace($serial) -or $badSerials -contains $serial) {
        Write-Log "Serial not usable ('$serial'); aborting."
        exit 1
    }

    $newName = ($Prefix + $serial)
    if ($newName.Length -gt $MaxLen) { $newName = $newName.Substring(0, $MaxLen) }
    $newName = $newName.ToUpper()

    if ($env:COMPUTERNAME -ieq $newName) { Write-Log "Already named $newName"; exit 0 }

    Write-Log "Renaming $env:COMPUTERNAME -> $newName"
    Rename-Computer -NewName $newName -Force -ErrorAction Stop
    Write-Log "Rename queued. Reboot required."

    if ($ScheduleRestart) {
        shutdown.exe /r /t $RestartDelaySecs /c "Your device is being renamed to $newName. It will restart shortly."
        Write-Log "Restart scheduled in $RestartDelaySecs seconds."
    }
    exit 0
}
catch {
    Write-Log "Remediation error: $($_.Exception.Message)"
    exit 1
}
