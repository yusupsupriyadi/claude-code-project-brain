[CmdletBinding()]
param(
    [string]$RepositoryName = "claude-code-project-brain",
    [ValidateSet("public", "private")]
    [string]$Visibility = "public",
    [string]$Description = "Windows-native Claude Code setup with OpenWolf, Graphify, and Obsidian",
    [switch]$InstallGitHubCli
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments = @())
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Perintah gagal: $Command $($Arguments -join ' ')"
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "Script ini khusus Windows native."
}

if (-not (Test-Command "git")) {
    throw "Git belum tersedia. Install dengan: winget install --id Git.Git -e"
}

if (-not (Test-Command "gh")) {
    if (-not $InstallGitHubCli) {
        throw "GitHub CLI belum tersedia. Jalankan ulang dengan -InstallGitHubCli atau install: winget install --id GitHub.cli -e"
    }

    Invoke-Checked "winget" @(
        "install", "--id", "GitHub.cli", "--exact",
        "--accept-package-agreements", "--accept-source-agreements"
    )

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

& gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "Silakan login ke GitHub CLI." -ForegroundColor Yellow
    Invoke-Checked "gh" @("auth", "login")
}

Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) {
    Invoke-Checked "git" @("init")
    Invoke-Checked "git" @("branch", "-M", "main")
}

Invoke-Checked "git" @("add", ".")

$hasHead = $true
& git rev-parse --verify HEAD *> $null
if ($LASTEXITCODE -ne 0) {
    $hasHead = $false
}

$hasChanges = $false
& git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    $hasChanges = $true
}

if ($hasChanges) {
    Invoke-Checked "git" @("commit", "-m", "feat: add Claude Code project brain template")
}
elseif (-not $hasHead) {
    throw "Tidak ada file yang dapat di-commit."
}

$visibilityFlag = "--$Visibility"

& gh repo view $RepositoryName *> $null
if ($LASTEXITCODE -eq 0) {
    throw "Repository '$RepositoryName' sudah ada pada akun aktif. Gunakan nama lain atau push secara manual."
}

Invoke-Checked "gh" @(
    "repo", "create", $RepositoryName,
    $visibilityFlag,
    "--description", $Description,
    "--source", ".",
    "--remote", "origin",
    "--push"
)

Write-Host ""
Write-Host "Repository berhasil dibuat dan dipush." -ForegroundColor Green
Invoke-Checked "gh" @("repo", "view", "--web")
