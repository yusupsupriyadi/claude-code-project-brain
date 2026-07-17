[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = (Get-Location).Path,

    [switch]$InstallDependencies,
    [switch]$InstallClaudeCode,
    [switch]$InstallObsidian,
    [switch]$SkipOpenWolfScan,
    [switch]$ForceRefresh
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TemplateRoot = $PSScriptRoot
$MarkerStart = "<!-- BEGIN CLAUDE-CODE-PROJECT-BRAIN -->"
$MarkerEnd = "<!-- END CLAUDE-CODE-PROJECT-BRAIN -->"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Warning $Message
}

function Test-Command {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @()
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Perintah gagal dengan exit code $LASTEXITCODE`: $Command $($Arguments -join ' ')"
    }
}

function Install-WingetPackage {
    param([string]$Id)

    if (-not (Test-Command "winget")) {
        throw "WinGet tidak tersedia. Install App Installer dari Microsoft Store terlebih dahulu."
    }

    Invoke-Checked "winget" @(
        "install",
        "--id", $Id,
        "--exact",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )
}

function Refresh-ProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

function Get-NodeMajorVersion {
    if (-not (Test-Command "node")) {
        return $null
    }

    $raw = (& node --version).Trim()
    if ($raw -notmatch "^v(?<major>\d+)") {
        return $null
    }

    return [int]$Matches.major
}

function Add-OrReplaceMarkerBlock {
    param(
        [string]$Path,
        [string]$StartMarker,
        [string]$EndMarker,
        [string]$Body
    )

    $newBlock = @"
$StartMarker
$Body
$EndMarker
"@

    if (Test-Path $Path) {
        $existing = Get-Content -Raw -Path $Path
        $pattern = "(?s)" + [regex]::Escape($StartMarker) + ".*?" + [regex]::Escape($EndMarker)

        if ($existing -match $pattern) {
            $updated = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
                param($match)
                return $newBlock
            })
        }
        else {
            $separator = if ($existing.EndsWith("`n")) { "`n" } else { "`n`n" }
            $updated = $existing + $separator + $newBlock + "`n"
        }
    }
    else {
        $updated = $newBlock + "`n"
    }

    Set-Content -Path $Path -Value $updated -Encoding UTF8
}

function Copy-TemplateIfMissing {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Destination)) {
        $parent = Split-Path -Parent $Destination
        if ($parent) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Copy-Item -Path $Source -Destination $Destination
        Write-Ok "Membuat $Destination"
    }
    else {
        Write-Host "[SKIP] Sudah ada: $Destination" -ForegroundColor DarkYellow
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "Script ini khusus Windows native."
}

$resolvedProject = (Resolve-Path -Path $ProjectPath).Path
Write-Step "Menyiapkan project: $resolvedProject"

if (-not (Test-Path -Path $resolvedProject -PathType Container)) {
    throw "ProjectPath bukan folder yang valid: $resolvedProject"
}

Write-Step "Memeriksa dependency"

if (-not (Test-Command "git")) {
    if ($InstallDependencies) {
        Install-WingetPackage "Git.Git"
        Refresh-ProcessPath
    }
    else {
        Write-Warn "Git belum tersedia. Jalankan ulang dengan -InstallDependencies."
    }
}

$nodeMajor = Get-NodeMajorVersion
if ($null -eq $nodeMajor -or $nodeMajor -lt 20) {
    if ($InstallDependencies) {
        Install-WingetPackage "OpenJS.NodeJS.LTS"
        Refresh-ProcessPath
        $nodeMajor = Get-NodeMajorVersion
    }
    else {
        throw "OpenWolf membutuhkan Node.js 20+. Jalankan ulang dengan -InstallDependencies."
    }
}

if ($null -eq $nodeMajor -or $nodeMajor -lt 20) {
    throw "Node.js 20+ belum terdeteksi setelah instalasi. Tutup PowerShell, buka kembali, lalu ulangi script."
}
Write-Ok "Node.js major version: $nodeMajor"

if (-not (Test-Command "uv")) {
    if ($InstallDependencies) {
        Install-WingetPackage "astral-sh.uv"
        Refresh-ProcessPath
    }
    else {
        throw "uv belum tersedia. Jalankan ulang dengan -InstallDependencies."
    }
}

if (-not (Test-Command "uv")) {
    throw "uv belum terdeteksi setelah instalasi. Tutup PowerShell, buka kembali, lalu ulangi script."
}
Write-Ok "uv tersedia"

if ($InstallClaudeCode -and -not (Test-Command "claude")) {
    Write-Step "Menginstal Claude Code"
    Install-WingetPackage "Anthropic.ClaudeCode"
    Refresh-ProcessPath
}

if ($InstallObsidian -and -not (Get-Command "obsidian" -ErrorAction SilentlyContinue)) {
    Write-Step "Menginstal Obsidian"
    Install-WingetPackage "Obsidian.Obsidian"
    Refresh-ProcessPath
}

Write-Step "Menginstal atau memeriksa OpenWolf"

if (-not (Test-Command "openwolf")) {
    if (-not $InstallDependencies) {
        throw "OpenWolf belum tersedia. Jalankan ulang dengan -InstallDependencies."
    }
    Invoke-Checked "npm" @("install", "-g", "openwolf")
}
elseif ($ForceRefresh) {
    Invoke-Checked "npm" @("install", "-g", "openwolf@latest")
}
Write-Ok "OpenWolf tersedia"

Write-Step "Menginstal atau memeriksa Graphify"

if (-not (Test-Command "graphify")) {
    if (-not $InstallDependencies) {
        throw "Graphify belum tersedia. Jalankan ulang dengan -InstallDependencies."
    }
    Invoke-Checked "uv" @("tool", "install", "graphifyy")
    Refresh-ProcessPath
}
elseif ($ForceRefresh) {
    Invoke-Checked "uv" @("tool", "upgrade", "graphifyy")
}

if (-not (Test-Command "graphify")) {
    throw "Graphify belum terdeteksi. Tutup PowerShell, buka kembali, lalu ulangi script."
}
Write-Ok "Graphify tersedia"

Push-Location $resolvedProject
try {
    Write-Step "Membuat struktur dokumentasi dan Obsidian Vault"

    $templateDocs = Join-Path $TemplateRoot "templates\docs"
    $docMappings = @{
        "architecture\README.md" = "docs\architecture\README.md"
        "decisions\README.md" = "docs\decisions\README.md"
        "features\README.md" = "docs\features\README.md"
        "bugs\README.md" = "docs\bugs\README.md"
        "sessions\README.md" = "docs\sessions\README.md"
        "HOME.md" = "docs\HOME.md"
    }

    foreach ($entry in $docMappings.GetEnumerator()) {
        Copy-TemplateIfMissing `
            -Source (Join-Path $templateDocs $entry.Key) `
            -Destination (Join-Path $resolvedProject $entry.Value)
    }

    $obsidianDir = Join-Path $resolvedProject ".obsidian"
    New-Item -ItemType Directory -Force -Path $obsidianDir | Out-Null

    Copy-TemplateIfMissing `
        -Source (Join-Path $TemplateRoot "templates\.obsidian\app.json") `
        -Destination (Join-Path $obsidianDir "app.json")

    Copy-TemplateIfMissing `
        -Source (Join-Path $TemplateRoot "templates\.obsidian\appearance.json") `
        -Destination (Join-Path $obsidianDir "appearance.json")

    Write-Step "Menggabungkan aturan ke CLAUDE.md"
    $claudeFragment = Get-Content -Raw -Path (Join-Path $TemplateRoot "templates\CLAUDE.fragment.md")
    Add-OrReplaceMarkerBlock `
        -Path (Join-Path $resolvedProject "CLAUDE.md") `
        -StartMarker $MarkerStart `
        -EndMarker $MarkerEnd `
        -Body $claudeFragment
    Write-Ok "CLAUDE.md berhasil digabungkan"

    Write-Step "Menggabungkan aturan aman ke .gitignore"
    $gitignoreFragment = Get-Content -Raw -Path (Join-Path $TemplateRoot "templates\gitignore.fragment")
    Add-OrReplaceMarkerBlock `
        -Path (Join-Path $resolvedProject ".gitignore") `
        -StartMarker "# BEGIN CLAUDE-CODE-PROJECT-BRAIN" `
        -EndMarker "# END CLAUDE-CODE-PROJECT-BRAIN" `
        -Body $gitignoreFragment
    Write-Ok ".gitignore berhasil digabungkan"

    Write-Step "Menginisialisasi OpenWolf untuk Claude Code"
    Invoke-Checked "openwolf" @("init", "--agent", "claude")

    if (-not $SkipOpenWolfScan) {
        Write-Step "Menjalankan scan awal OpenWolf"
        Invoke-Checked "openwolf" @("scan")
    }

    Write-Step "Menginstal Graphify secara project-scoped"
    Invoke-Checked "graphify" @("install", "--project")
    Invoke-Checked "graphify" @("claude", "install", "--project")

    Write-Step "Menjalankan verifikasi"
    & (Join-Path $TemplateRoot "scripts\verify-project.ps1") -ProjectPath $resolvedProject

    Write-Host ""
    Write-Host "Setup selesai." -ForegroundColor Green
    Write-Host ""
    Write-Host "Langkah berikutnya:" -ForegroundColor Cyan
    Write-Host "  1. Buka folder ini sebagai Obsidian Vault:"
    Write-Host "     $resolvedProject"
    Write-Host "  2. Jalankan Claude Code:"
    Write-Host "     cd `"$resolvedProject`""
    Write-Host "     claude"
    Write-Host "  3. Di dalam Claude Code jalankan:"
    Write-Host "     /graphify ."
    Write-Host ""
    Write-Host "Setelah perubahan struktur besar gunakan:"
    Write-Host "  openwolf scan"
    Write-Host "  /graphify . --update"
}
finally {
    Pop-Location
}
