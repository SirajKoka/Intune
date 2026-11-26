# Win32Apps

One folder per app:

```
<App>/
  src/        # everything that goes into the package (install.ps1, uninstall.ps1, assets)
  README.md   # install/uninstall command lines, detection rule, requirements
```

Build the package with the [Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool). Download it at build time; don't commit it:

```powershell
IntuneWinAppUtil.exe -c .\<App>\src -s install.ps1 -o .\out -q
```

`.intunewin` files and `out/` are gitignored. Publish built packages as GitHub Release assets.
