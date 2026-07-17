[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$project = (Resolve-Path $ProjectPath).Path
$checks = @(
    @{ Name = "CLAUDE.md"; Path = "CLAUDE.md"; Type = "File" },
    @{ Name = ".gitignore"; Path = ".gitignore"; Type = "File" },
    @{ Name = ".claude"; Path = ".claude"; Type = "Directory" },
    @{ Name = ".wolf"; Path = ".wolf"; Type = "Directory" },
    @{ Name = ".obsidian"; Path = ".obsidian"; Type = "Directory" },
    @{ Name = "docs"; Path = "docs"; Type = "Directory" },
    @{ Name = "docs/architecture"; Path = "docs\architecture"; Type = "Directory" },
    @{ Name = "docs/decisions"; Path = "docs\decisions"; Type = "Directory" },
    @{ Name = "docs/features"; Path = "docs\features"; Type = "Directory" },
    @{ Name = "docs/bugs"; Path = "docs\bugs"; Type = "Directory" },
    @{ Name = "docs/sessions"; Path = "docs\sessions"; Type = "Directory" }
)

Write-Host ""
Write-Host "Verifikasi project: $project" -ForegroundColor Cyan

$failed = @()

foreach ($check in $checks) {
    $fullPath = Join-Path $project $check.Path
    $exists = if ($check.Type -eq "File") {
        Test-Path $fullPath -PathType Leaf
    }
    else {
        Test-Path $fullPath -PathType Container
    }

    if ($exists) {
        Write-Host "[OK]   $($check.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "[MISS] $($check.Name)" -ForegroundColor Red
        $failed += $check.Name
    }
}

$commands = @("node", "npm", "uv", "openwolf", "graphify", "claude")
foreach ($command in $commands) {
    if (Get-Command $command -ErrorAction SilentlyContinue) {
        Write-Host "[OK]   command: $command" -ForegroundColor Green
    }
    else {
        Write-Host "[WARN] command tidak ditemukan: $command" -ForegroundColor Yellow
    }
}

if (Get-Command "openwolf" -ErrorAction SilentlyContinue) {
    Push-Location $project
    try {
        Write-Host ""
        Write-Host "OpenWolf status:" -ForegroundColor Cyan
        & openwolf status
    }
    finally {
        Pop-Location
    }
}

if ($failed.Count -gt 0) {
    throw "Verifikasi gagal untuk: $($failed -join ', ')"
}

Write-Host ""
Write-Host "Verifikasi struktur berhasil." -ForegroundColor Green
Write-Host "graphify-out/ belum wajib ada sebelum graph pertama dibangun."
