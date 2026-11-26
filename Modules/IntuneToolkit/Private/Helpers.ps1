$script:VolatileProperties = @(
    'id', 'createdDateTime', 'lastModifiedDateTime', 'version', 'settingCount',
    'isAssigned', 'creationSource', 'supportsScopeTags', 'roleScopeTagIds',
    '@odata.context', 'deployedAppCount'
)

function Get-GraphCollection {
    param([Parameter(Mandatory)][string]$Uri)
    $next = $Uri
    while ($next) {
        $page = Invoke-MgGraphRequest -Method GET -Uri $next -OutputType PSObject
        if ($page.PSObject.Properties.Name -contains 'value') { $page.value } else { $page }
        $next = $page.'@odata.nextLink'
    }
}

function ConvertTo-PortableObject {
    param([Parameter(Mandatory, ValueFromPipeline)]$InputObject)
    process {
        $copy = [ordered]@{}
        foreach ($p in $InputObject.PSObject.Properties) {
            if ($script:VolatileProperties -notcontains $p.Name) { $copy[$p.Name] = $p.Value }
        }
        [pscustomobject]$copy
    }
}

function ConvertTo-SafeFileName {
    param([Parameter(Mandatory)][string]$Name)
    $invalid = [regex]::Escape(-join [IO.Path]::GetInvalidFileNameChars() + '<>:"/\|?*')
    ($Name -replace "[$invalid]", '_' -replace '\s+', ' ').Trim()
}
