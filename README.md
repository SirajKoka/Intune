# Intune

Intune scripts, packages and configuration, kept as code.

| Folder | What goes there |
|---|---|
| [`Remediations/`](Remediations) | Detection + remediation pairs. One folder per pair, with `Detect.ps1`, `Remediate.ps1`, `README.md` and Pester tests. |
| [`PlatformScripts/`](PlatformScripts) | One-shot device scripts (Devices > Scripts). |
| [`Win32Apps/`](Win32Apps) | Win32 app sources and build scripts. `.intunewin` files are build output and are never committed. |
| [`ConfigurationProfiles/`](ConfigurationProfiles) | Policy JSON exported through Microsoft Graph. |
| [`Modules/IntuneToolkit/`](Modules/IntuneToolkit) | Admin-side PowerShell module (exports, reports, bulk operations). Runs on your machine or in CI, never on endpoints. |

## Rules

- **Endpoint scripts are self-contained.** Intune uploads them as single files, so they can't import modules. Shared logic is copied between files inside a `#region` block, and a Pester test checks the copies match.
- **No binaries.** That includes `IntuneWinAppUtil.exe` and `.intunewin` files. Build them in CI.
- **No secrets.** Commit `*.sample.json` only. CI signs in to Entra ID through OIDC federation, so there's no client secret.
- **No tenant-specific values in baselines.** Client overrides live in the client's own repo.
- Every push runs PSScriptAnalyzer and Pester ([`lint.yml`](.github/workflows/lint.yml)).

## Third-party tools previously stored here

They were removed from this repo. Use the upstream sources (fork them if you customize them):

- Autopilot Branding: https://github.com/mtniehaus/AutopilotBranding
- RenameComputer: https://github.com/mtniehaus/RenameComputer
- Intune Device Migration: https://github.com/stevecapacity/intune-device-migration
- Win32 Content Prep Tool: https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool
