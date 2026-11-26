# ConfigurationProfiles

Intune policies as JSON, one file per policy. They're produced by `Export-IntuneConfiguration`, so don't edit the files by hand.

| Folder | Graph source (beta) |
|---|---|
| `SettingsCatalog/` | `deviceManagement/configurationPolicies` (plus their settings) |
| `EndpointSecurity/` | `configurationPolicies` with an `endpointSecurity*` template |
| `Compliance/` | `deviceManagement/deviceCompliancePolicies` |
| `DeviceConfiguration/` | `deviceManagement/deviceConfigurations` (legacy templates) |
| `AppProtection/` | `deviceAppManagement/managedAppPolicies` |

IDs, timestamps, versions and scope tags are stripped so that diffs show only real setting changes. Assignments aren't exported.

Naming convention for policies in the tenant: `<Platform>-<Area>-<Purpose>`, e.g. `WIN-SC-BitLocker`.

## Manual export

```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
Connect-MgGraph -Scopes DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All
Import-Module ./Modules/IntuneToolkit
Export-IntuneConfiguration -Path ./ConfigurationProfiles
```

## Nightly export (GitHub Actions)

The [`export-config.yml`](../.github/workflows/export-config.yml) workflow stays skipped until you set it up:

1. Create an Entra app registration and grant it the **application** permissions `DeviceManagementConfiguration.Read.All` and `DeviceManagementApps.Read.All`, then grant admin consent.
2. On the app, add a federated credential: GitHub Actions, repo `SirajKoka/Intune`, entity `Branch`, value `main`.
3. In the repo, go to Settings > Secrets and variables > Actions > **Variables** and add `AZURE_CLIENT_ID` and `AZURE_TENANT_ID`.

There's no client secret anywhere.
