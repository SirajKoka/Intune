@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # Pester BeforeAll/It scoping trips this rule constantly.
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}
