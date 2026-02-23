<#
.SYNOPSIS
    Create symlinks from .project/ to Codex CLI locations.

.DESCRIPTION
    Maps the .project standard directory structure to where OpenAI Codex CLI
    expects its configuration files. Uses relative symlinks so the repo
    stays portable across machines.

    Requires Developer Mode enabled (Settings > Update & Security > For developers)
    or an elevated (Administrator) PowerShell session.

.PARAMETER ProjectRoot
    Path to the project root containing .project/. Defaults to the parent of
    the directory containing this script.

.PARAMETER Clean
    Remove previously created symlinks instead of creating them.

.EXAMPLE
    .\scripts\adapt-codex.ps1
    .\scripts\adapt-codex.ps1 -Clean
    .\scripts\adapt-codex.ps1 -ProjectRoot C:\repos\my-app
#>

[CmdletBinding()]
param(
    [string]$ProjectRoot,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

if (-not $ProjectRoot) {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$DotProject = Join-Path $ProjectRoot '.project'

if (-not (Test-Path $DotProject -PathType Container)) {
    Write-Error "No .project/ directory found at $ProjectRoot"
    exit 1
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function New-Symlink {
    param(
        [string]$Target,
        [string]$Link
    )

    if ($Clean) {
        if (Test-Path $Link) {
            $item = Get-Item $Link -Force -ErrorAction SilentlyContinue
            if ($item.LinkType -eq 'SymbolicLink') {
                Remove-Item $Link -Force
                Write-Host "  REMOVED: $Link"
            }
        }
        return
    }

    if (Test-Path $Link) {
        $item = Get-Item $Link -Force -ErrorAction SilentlyContinue
        if ($item.LinkType -ne 'SymbolicLink') {
            Write-Warning "  SKIP: $Link exists and is not a symlink"
            return
        }
    }

    $parentDir = Split-Path -Parent $Link
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path $Link) {
        Remove-Item $Link -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Host "  LINK: $Link -> $Target"
    }
    catch {
        Write-Warning "  FAIL: $Link (enable Developer Mode or run as Administrator)"
    }
}

function Remove-EmptyDir {
    param([string]$Path)
    if ((Test-Path $Path -PathType Container) -and
        @(Get-ChildItem $Path -Force).Count -eq 0) {
        Remove-Item $Path -Force
    }
}

# ---------------------------------------------------------------------------
# 1. instructions/index.md -> AGENTS.md
# ---------------------------------------------------------------------------

$InstructionsDir = Join-Path $DotProject 'instructions'
if ((Test-Path (Join-Path $InstructionsDir 'index.md')) -or $Clean) {
    New-Symlink -Target '.project\instructions\index.md' `
                -Link (Join-Path $ProjectRoot 'AGENTS.md')
}

# ---------------------------------------------------------------------------
# 2. skills/<name>/index.md -> .agents/skills/<name>/SKILL.md
# ---------------------------------------------------------------------------

$SkillsSource = Join-Path $DotProject 'skills'
$SkillsDir = Join-Path $ProjectRoot '.agents\skills'

if ($Clean) {
    if (Test-Path $SkillsDir) {
        Get-ChildItem $SkillsDir -Directory -Force | ForEach-Object {
            $skillMd = Join-Path $_.FullName 'SKILL.md'
            if (Test-Path $skillMd) {
                $item = Get-Item $skillMd -Force -ErrorAction SilentlyContinue
                if ($item.LinkType -eq 'SymbolicLink') {
                    New-Symlink -Target '' -Link $skillMd
                }
            }
        }
    }
}
elseif (Test-Path $SkillsSource -PathType Container) {
    Get-ChildItem $SkillsSource -Directory | ForEach-Object {
        $indexMd = Join-Path $_.FullName 'index.md'
        if (Test-Path $indexMd) {
            $name = $_.Name
            New-Symlink -Target "..\..\..\.project\skills\$name\index.md" `
                        -Link (Join-Path $SkillsDir "$name\SKILL.md")
        }
    }
}

# ---------------------------------------------------------------------------
# Clean up empty directories on --clean
# ---------------------------------------------------------------------------

if ($Clean) {
    if (Test-Path $SkillsDir) {
        Get-ChildItem $SkillsDir -Directory -Force | ForEach-Object {
            Remove-EmptyDir $_.FullName
        }
    }
    Remove-EmptyDir $SkillsDir
    $agentsDir = Join-Path $ProjectRoot '.agents'
    Remove-EmptyDir $agentsDir

    Write-Host 'Done. Symlinks removed.'
}
else {
    Write-Host 'Done. Codex symlinks created.'
}
