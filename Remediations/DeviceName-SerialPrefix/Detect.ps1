<#
 Intune Remediation - DETECTION
 Compliant (exit 0) when the device name, or a pending rename, equals <Prefix><Serial>.
 Run as SYSTEM, 64-bit PowerShell.
#>
$Prefix = 'TPK-'
$MaxLen = 15   # NetBIOS limit

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
    $serial   = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
    $expected = Get-ExpectedDeviceName -Serial $serial -Prefix $Prefix -MaxLen $MaxLen
    if (-not $expected) {
        Write-Output "Serial not usable ('$serial'); nothing to do."
        exit 0
    }

    $current = $env:COMPUTERNAME
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
