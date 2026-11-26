function Export-IntuneConfiguration {
    <#
    .SYNOPSIS
        Exports Intune policies to JSON, one file per policy, minus volatile properties.
    .DESCRIPTION
        Requires an existing Connect-MgGraph session with DeviceManagementConfiguration.Read.All
        and DeviceManagementApps.Read.All. Each category folder is cleared before export so
        deleted policies show up as deletions in git.
    .EXAMPLE
        Connect-MgGraph -Scopes DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All
        Export-IntuneConfiguration -Path ./ConfigurationProfiles
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [ValidateSet('SettingsCatalog', 'EndpointSecurity', 'Compliance', 'DeviceConfiguration', 'AppProtection')]
        [string[]]$Category = @('SettingsCatalog', 'EndpointSecurity', 'Compliance', 'DeviceConfiguration', 'AppProtection')
    )

    $beta = 'https://graph.microsoft.com/beta'
    $out = @{}
    foreach ($c in $Category) { $out[$c] = [System.Collections.Generic.List[object]]::new() }

    if ($Category -match 'SettingsCatalog|EndpointSecurity') {
        foreach ($p in Get-GraphCollection "$beta/deviceManagement/configurationPolicies") {
            $settings = @(Get-GraphCollection "$beta/deviceManagement/configurationPolicies/$($p.id)/settings")
            $p | Add-Member -NotePropertyName settings -NotePropertyValue $settings -Force
            $bucket = if ($p.templateReference.templateFamily -like 'endpointSecurity*') { 'EndpointSecurity' } else { 'SettingsCatalog' }
            if ($out.ContainsKey($bucket)) { $out[$bucket].Add($p) }
        }
    }
    if ($out.ContainsKey('Compliance')) {
        Get-GraphCollection "$beta/deviceManagement/deviceCompliancePolicies?`$expand=scheduledActionsForRule(`$expand=scheduledActionConfigurations)" |
            ForEach-Object { $out['Compliance'].Add($_) }
    }
    if ($out.ContainsKey('DeviceConfiguration')) {
        Get-GraphCollection "$beta/deviceManagement/deviceConfigurations" | ForEach-Object { $out['DeviceConfiguration'].Add($_) }
    }
    if ($out.ContainsKey('AppProtection')) {
        Get-GraphCollection "$beta/deviceAppManagement/managedAppPolicies" | ForEach-Object { $out['AppProtection'].Add($_) }
    }

    foreach ($c in $out.Keys) {
        $dir = Join-Path $Path $c
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Get-ChildItem $dir -Filter *.json | Remove-Item -Force

        foreach ($policy in $out[$c]) {
            $name = if ($policy.displayName) { $policy.displayName } else { $policy.name }
            $base = ConvertTo-SafeFileName $name
            $file = Join-Path $dir "$base.json"
            $n = 2
            while (Test-Path $file) { $file = Join-Path $dir "$base ($n).json"; $n++ }
            $policy | ConvertTo-PortableObject | ConvertTo-Json -Depth 100 | Set-Content -Path $file -Encoding utf8
        }
        Write-Verbose "$c : $($out[$c].Count) policies"
        [pscustomobject]@{ Category = $c; Count = $out[$c].Count }
    }
}
