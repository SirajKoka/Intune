BeforeAll {
    $regionPattern = '(?s)#region SharedNameLogic.*?#endregion SharedNameLogic'
    $script:detectBlock    = [regex]::Match((Get-Content "$PSScriptRoot/Detect.ps1" -Raw), $regionPattern).Value
    $script:remediateBlock = [regex]::Match((Get-Content "$PSScriptRoot/Remediate.ps1" -Raw), $regionPattern).Value
    . ([scriptblock]::Create($script:detectBlock))
}

Describe 'Shared name logic' {
    It 'exists in both scripts' {
        $detectBlock    | Should -Not -BeNullOrEmpty
        $remediateBlock | Should -Not -BeNullOrEmpty
    }

    It 'is identical in Detect.ps1 and Remediate.ps1' {
        $remediateBlock | Should -BeExactly $detectBlock
    }
}

Describe 'Get-ExpectedDeviceName' {
    It 'builds prefix + serial in upper case' {
        Get-ExpectedDeviceName -Serial 'abc1234' -Prefix 'TPK-' | Should -BeExactly 'TPK-ABC1234'
    }

    It 'keeps the tail of a long serial (12-char Surface)' {
        Get-ExpectedDeviceName -Serial '012345678912' -Prefix 'TPK-' | Should -BeExactly 'TPK-12345678912'
    }

    It 'never exceeds 15 characters' {
        (Get-ExpectedDeviceName -Serial ('X' * 40) -Prefix 'TPK-').Length | Should -Be 15
    }

    It 'strips invalid characters' {
        Get-ExpectedDeviceName -Serial ' AB_12 34 ' -Prefix 'TPK-' | Should -BeExactly 'TPK-AB1234'
    }

    It 'returns null for placeholder serial <_>' -ForEach 'To Be Filled By O.E.M.', 'System Serial Number', '0', '', 'Default string' {
        Get-ExpectedDeviceName -Serial $_ -Prefix 'TPK-' | Should -BeNullOrEmpty
    }

    It 'throws when the prefix is too long' {
        { Get-ExpectedDeviceName -Serial 'ABC' -Prefix 'WAYTOOLONGPREFIX' } | Should -Throw
    }
}
