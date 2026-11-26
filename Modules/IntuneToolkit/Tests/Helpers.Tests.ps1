BeforeAll {
    . "$PSScriptRoot/../Private/Helpers.ps1"
}

Describe 'ConvertTo-PortableObject' {
    It 'drops volatile properties and keeps the rest' {
        $obj = [pscustomobject]@{ id = '1'; lastModifiedDateTime = 'x'; displayName = 'BitLocker'; settings = @(1, 2) }
        $result = $obj | ConvertTo-PortableObject
        $result.PSObject.Properties.Name | Should -Be @('displayName', 'settings')
    }
}

Describe 'ConvertTo-SafeFileName' {
    It 'replaces invalid characters' {
        ConvertTo-SafeFileName 'WIN: BitLocker / OS?' | Should -BeExactly 'WIN_ BitLocker _ OS_'
    }
}
