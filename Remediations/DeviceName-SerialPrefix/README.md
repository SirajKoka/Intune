# DeviceName-SerialPrefix

Renames Windows devices to `<Prefix><Serial>` (default `TPK-<Serial>`). Useful for Windows Autopilot device preparation (Autopilot v2), which has no device naming template.

## Intune settings

| Setting | Value |
|---|---|
| Detection script | `Detect.ps1` |
| Remediation script | `Remediate.ps1` |
| Run as logged-on user | No (SYSTEM) |
| 64-bit PowerShell | Yes |
| Enforce signature check | Per your tenant policy |
| Schedule | Daily |

## Behaviour

- Name = prefix + **last** N characters of the BIOS serial, upper case, max 15 chars (NetBIOS).
- OEM placeholder serials (`To Be Filled By O.E.M.`, `System Serial Number`, etc.) are skipped.
- Detection is compliant if the current **or pending** name already matches, so a device waiting for a reboot isn't renamed again.
- `$RestartMode` in `Remediate.ps1`:
  - `None`: never restart; the name applies on the next natural reboot.
  - `IfNoUser` (default): restart only when nobody is signed in.
  - `Always`: restart after `$RestartDelaySecs`. Don't use this fleet-wide during business hours.
- Log: `%ProgramData%\Microsoft\IntuneManagementExtension\Logs\DeviceRename.log`

## Caveats

- **Entra-joined devices only.** On hybrid-joined devices, a SYSTEM rename needs line of sight to a domain controller and rights on the computer object. Use a different approach there.
- Change `$Prefix` in **both** scripts. The Pester test fails if the shared name logic drifts between them.

## Test

```powershell
Invoke-Pester ./Remediations/DeviceName-SerialPrefix
```
