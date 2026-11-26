foreach ($file in Get-ChildItem "$PSScriptRoot/Private", "$PSScriptRoot/Public" -Filter *.ps1) { . $file.FullName }
Export-ModuleMember -Function (Get-ChildItem "$PSScriptRoot/Public" -Filter *.ps1).BaseName
