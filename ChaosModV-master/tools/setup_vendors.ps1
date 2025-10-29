# ====================================
# Setup Vendor Dependencies
# ====================================

param(
    [string]$VendorPath = "../vendor"
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Setting Up Vendor Dependencies" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$VendorPath = Resolve-Path $VendorPath

# ====================================
# 1. cpp-httplib
# ====================================
Write-Host "[1/2] Setting up cpp-httplib..." -ForegroundColor Yellow

$HttplibPath = Join-Path $VendorPath "httplib"
if (-not (Test-Path $HttplibPath)) {
    New-Item -ItemType Directory -Path $HttplibPath -Force | Out-Null
}

$HttplibHeader = Join-Path $HttplibPath "httplib.h"
if (-not (Test-Path $HttplibHeader)) {
    Write-Host "  Downloading cpp-httplib..." -ForegroundColor Gray
    
    $HttplibUrl = "https://raw.githubusercontent.com/yhirose/cpp-httplib/master/httplib.h"
    Invoke-WebRequest -Uri $HttplibUrl -OutFile $HttplibHeader
    
    Write-Host "  Downloaded: httplib.h" -ForegroundColor Green
} else {
    Write-Host "  Already exists: httplib.h" -ForegroundColor Green
}

# ====================================
# 2. nlohmann/json
# ====================================
Write-Host ""
Write-Host "[2/2] Setting up nlohmann/json..." -ForegroundColor Yellow

$JsonPath = Join-Path $VendorPath "nlohmann"
if (-not (Test-Path $JsonPath)) {
    New-Item -ItemType Directory -Path $JsonPath -Force | Out-Null
}

$JsonHeader = Join-Path $JsonPath "json.hpp"
if (-not (Test-Path $JsonHeader)) {
    Write-Host "  Downloading nlohmann/json..." -ForegroundColor Gray
    
    $JsonUrl = "https://raw.githubusercontent.com/nlohmann/json/develop/single_include/nlohmann/json.hpp"
    Invoke-WebRequest -Uri $JsonUrl -OutFile $JsonHeader
    
    Write-Host "  Downloaded: json.hpp" -ForegroundColor Green
} else {
    Write-Host "  Already exists: json.hpp" -ForegroundColor Green
}

# ====================================
# Summary
# ====================================
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vendor structure:" -ForegroundColor White
Write-Host "  $VendorPath/httplib/httplib.h" -ForegroundColor Gray
Write-Host "  $VendorPath/nlohmann/json.hpp" -ForegroundColor Gray
Write-Host ""
Write-Host "You can now build the project." -ForegroundColor Green
Write-Host ""