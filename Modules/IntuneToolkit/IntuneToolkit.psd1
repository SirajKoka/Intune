@{
    RootModule        = 'IntuneToolkit.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '6f0b1c9e-3a4d-4c8e-9b7a-2d5e8f1a0c34'
    Author            = 'Siraj Kokawalage'
    Description       = 'Admin-side Intune tooling: Graph exports, reporting, bulk operations.'
    PowerShellVersion = '7.2'
    RequiredModules   = @('Microsoft.Graph.Authentication')
    FunctionsToExport = @('Export-IntuneConfiguration')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
