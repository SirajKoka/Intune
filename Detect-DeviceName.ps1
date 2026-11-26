<#
 Intune Remediation - DETECTION
 Compliant (exit 0) when the device name (or a pending rename) equals TPK-<Serial>.
 Run as SYSTEM, 64-bit PowerShell.
#>
$Prefix = 'TPK-'
$MaxLen = 15   # NetBIOS limit

try {
    $serial = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
    $serial = ($serial -replace '[^A-Za-z0-9-]', '').Trim('-')

    $badSerials = 'SystemSerialNumber','ToBeFilledByOEM','Defaultstring','None','0','123456789'
    if ([string]::IsNullOrWhiteSpace($serial) -or $badSerials -contains $serial) {
        Write-Output "Serial not usable ('$serial'); nothing to do."
        exit 0
    }

    $expected = ($Prefix + $serial)
    if ($expected.Length -gt $MaxLen) { $expected = $expected.Substring(0, $MaxLen) }
    $expected = $expected.ToUpper()

    $current = $env:COMPUTERNAME
    # Name queued by a previous rename that is waiting for reboot
    $pending = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' -ErrorAction SilentlyContinue).ComputerName

    if ($current -ieq $expected -or $pending -ieq $expected) {
        Write-Output "Compliant: current=$current pending=$pending expected=$expected"
        exit 0
    }

    Write-Output "Non-compliant: current=$current expected=$expected"
    exit 1
}
catch {
    Write-Output "Detection error: $($_.Exception.Message)"
    exit 1
}
