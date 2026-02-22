#!/usr/bin/env bash
#
# adapt-codex.sh — Create symlinks from .project/ to Codex CLI locations
#
# Maps the .project standard directory structure to where OpenAI Codex CLI
# expects its configuration files. Uses relative symlinks so the repo
# stays portable across machines.
#
# Usage:
#   ./scripts/adapt-codex.sh [project-root]   # default: repo root
#   ./scripts/adapt-codex.sh --clean [root]    # remove created symlinks
#
# Mappings (from Appendix B.2 of the .project spec + Codex docs):
#
#   .project/instructions/index.md    -> AGENTS.md
#   .project/skills/<name>/index.md   -> .agents/skills/<name>/SKILL.md
#
# Supported platforms: macOS, Linux, WSL, Windows (Git Bash / MSYS2)
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CLEAN=false
if [[ "${1:-}" == "--clean" ]]; then
    CLEAN=true
    shift
fi

PROJECT_ROOT="$(cd "${1:-$SCRIPT_DIR/..}" && pwd)"
DOT_PROJECT="$PROJECT_ROOT/.project"

# ---------------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------------

if [[ ! -d "$DOT_PROJECT" ]]; then
    echo "Error: no .project/ directory found at $PROJECT_ROOT" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------

OS="$(uname -s)"

symlink() {
    local target="$1" # relative path from link location to real file
    local link="$2"   # path where the symlink is created

    if $CLEAN; then
        if [[ -L "$link" ]]; then
            rm "$link"
            echo "  REMOVED: $link"
        fi
        return
    fi

    # Never overwrite a real (non-symlink) file
    if [[ -e "$link" && ! -L "$link" ]]; then
        echo "  SKIP: $link exists and is not a symlink" >&2
        return
    fi

    mkdir -p "$(dirname "$link")"

    case "$OS" in
        MINGW*|MSYS*|CYGWIN*)
            local win_target win_link
            win_target="$(cygpath -w "$PROJECT_ROOT/$target" 2>/dev/null || echo "$target")"
            win_link="$(cygpath -w "$link" 2>/dev/null || echo "$link")"
            rm -f "$link" 2>/dev/null || true
            if ! cmd //c mklink "$win_link" "$win_target" >/dev/null 2>&1; then
                if ! ln -sf "$target" "$link" 2>/dev/null; then
                    echo "  FAIL: $link (enable Developer Mode or run as admin)" >&2
                    return 1
                fi
            fi
            ;;
        *)
            ln -sf "$target" "$link"
            ;;
    esac

    echo "  LINK: $link -> $target"
}

# ---------------------------------------------------------------------------
# 1. instructions/index.md -> AGENTS.md
# ---------------------------------------------------------------------------

INSTRUCTIONS_DIR="$DOT_PROJECT/instructions"
if [[ -f "$INSTRUCTIONS_DIR/index.md" ]]; then
    symlink ".project/instructions/index.md" "$PROJECT_ROOT/AGENTS.md"
fi

# ---------------------------------------------------------------------------
# 2. skills/<name>/index.md -> .agents/skills/<name>/SKILL.md
#    Codex scans .agents/skills/ at every directory level up to repo root.
# ---------------------------------------------------------------------------

SKILLS_DIR="$DOT_PROJECT/skills"
if [[ -d "$SKILLS_DIR" ]]; then
    for skill_dir in "$SKILLS_DIR"/*/; do
        [[ -d "$skill_dir" ]] || continue
        [[ -f "$skill_dir/index.md" ]] || continue
        name="$(basename "$skill_dir")"
        symlink "../../../.project/skills/$name/index.md" "$PROJECT_ROOT/.agents/skills/$name/SKILL.md"
    done
fi

# ---------------------------------------------------------------------------
# Clean up empty directories on --clean
# ---------------------------------------------------------------------------

if $CLEAN; then
    # Remove skill subdirectories first
    if [[ -d "$PROJECT_ROOT/.agents/skills" ]]; then
        for sdir in "$PROJECT_ROOT/.agents/skills"/*/; do
            [[ -d "$sdir" ]] || continue
            if [[ -z "$(ls -A "$sdir" 2>/dev/null)" ]]; then
                rmdir "$sdir" 2>/dev/null || true
            fi
        done
    fi
    # Then remove parent directories
    for dir in "$PROJECT_ROOT/.agents/skills" \
               "$PROJECT_ROOT/.agents"; do
        if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
            rmdir "$dir" 2>/dev/null || true
        fi
    done
    echo "Done. Symlinks removed."
else
    echo "Done. Codex symlinks created."
fi
