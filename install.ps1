# install.ps1 - Copy chaoscougar resources into a local FiveM txData tree.
#
# Usage:
#   .\install.ps1                              # copies to .\txData\resources\[local]\cougars
#   .\install.ps1 -TxDataPath C:\FXServer\txData
#   .\install.ps1 -IncludeRepl                 # also copy cougars_repl
#   .\install.ps1 -GenerateToken               # set chaoscougar_dev_token in server.cfg
#
# Requires PowerShell 5+ (Windows PowerShell or PowerShell 7+).

[CmdletBinding()]
param(
    [string]$TxDataPath = ".\txData",
    [switch]$IncludeRepl,
    [switch]$GenerateToken
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot | Split-Path -Parent
$LocalDir = Join-Path $TxDataPath "resources\[local]"

function Write-Status($msg) {
    Write-Host "[install] $msg" -ForegroundColor Cyan
}

# --- Sanity checks -----------------------------------------------------------

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "fivemchaos\resource\fxmanifest.lua"))) {
    throw "Cannot find fivemchaos/resource/fxmanifest.lua under $RepoRoot. Run this script from the repo root."
}

if (-not (Test-Path -LiteralPath $TxDataPath)) {
    Write-Status "Creating $TxDataPath..."
    New-Item -ItemType Directory -Path $TxDataPath -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $LocalDir)) {
    Write-Status "Creating $LocalDir..."
    New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null
}

# --- Copy main resource ------------------------------------------------------

$MainDest = Join-Path $LocalDir "cougars"
if (Test-Path -LiteralPath $MainDest) {
    Write-Status "Removing existing cougars/ at $MainDest"
    Remove-Item -LiteralPath $MainDest -Recurse -Force
}
Write-Status "Copying fivemchaos/resource -> $MainDest"
Copy-Item -Recurse -Force (Join-Path $RepoRoot "fivemchaos\resource") $MainDest

# --- Optionally copy REPL ----------------------------------------------------

if ($IncludeRepl) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "fivemchaos\resource_repl\fxmanifest.lua"))) {
        Write-Warning "fivemchaos/resource_repl/fxmanifest.lua not found; skipping."
    } else {
        $ReplDest = Join-Path $LocalDir "cougars_repl"
        if (Test-Path -LiteralPath $ReplDest) {
            Write-Status "Removing existing cougars_repl/ at $ReplDest"
            Remove-Item -LiteralPath $ReplDest -Recurse -Force
        }
        Write-Status "Copying fivemchaos/resource_repl -> $ReplDest"
        Copy-Item -Recurse -Force (Join-Path $RepoRoot "fivemchaos\resource_repl") $ReplDest
    }
}

# --- Optionally generate dev token -------------------------------------------

if ($GenerateToken) {
    $ServerCfg = Join-Path $TxDataPath "server.cfg"
    if (-not (Test-Path -LiteralPath $ServerCfg)) {
        Write-Status "No server.cfg found at $ServerCfg; copying example template."
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "server.cfg.example"))) {
            throw "server.cfg.example missing from repo root."
        }
        Copy-Item -LiteralPath (Join-Path $RepoRoot "server.cfg.example") $ServerCfg
    }
    $Token = [guid]::NewGuid().Guid
    Write-Status "Generated dev token: $Token"
    $Content = Get-Content -LiteralPath $ServerCfg -Raw
    if ($Content -match 'setr\s+chaoscougar_dev_token\s+"([^"]+)"') {
        $Old = $Matches[1]
        if ($Old -eq "CHANGE_ME_LONG_RANDOM_STRING" -or $Old -eq "") {
            $Content = $Content -replace 'setr\s+chaoscougar_dev_token\s+"[^"]+"', "setr chaoscougar_dev_token `"$Token`""
            Set-Content -LiteralPath $ServerCfg -Value $Content -NoNewline
            Write-Status "Wrote token to $ServerCfg"
        } else {
            Write-Status "server.cfg already has a token; leaving as-is."
        }
    } else {
        Add-Content -LiteralPath $ServerCfg -Value "`r`nsetr chaoscougar_dev_token `"$Token`"`r`n"
        Write-Status "Appended setr chaoscougar_dev_token to $ServerCfg"
    }
}

Write-Status "Done."
Write-Status ""
Write-Status "Next steps:" -ForegroundColor Green
Write-Status "  1. Edit $TxDataPath\server.cfg and set sv_licenseKey." -ForegroundColor Green
Write-Status "  2. Start FXServer.exe from $TxDataPath's parent directory." -ForegroundColor Green
Write-Status "  3. In the server console, type:  ensure cougars" -ForegroundColor Green
