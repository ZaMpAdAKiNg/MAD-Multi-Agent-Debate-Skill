#!/usr/bin/env bash
# install.sh — symlink the `mad` engine onto your PATH and print how to wire the skill.
# Non-destructive: it only creates a symlink of the binary. Never copies/overwrites the skill.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/bin/mad"
TARGET_DIR="${MAD_BIN_DIR:-$HOME/.local/bin}"
TARGET="$TARGET_DIR/mad"

echo "==> mad installer"

# 1) dependencies (the real bottleneck: both CLIs, authenticated)
missing=0
for bin in "${MAD_CLAUDE_BIN:-claude}" "${MAD_CODEX_BIN:-codex}"; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "    ok: '$bin' found"
  else
    echo "    WARNING: '$bin' is not on PATH — mad needs it installed and authenticated" >&2
    missing=1
  fi
done

# 2) symlink the binary
mkdir -p "$TARGET_DIR"
chmod +x "$SRC"
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  if cmp -s "$SRC" "$TARGET" 2>/dev/null; then
    # a previous install on a no-symlink filesystem (e.g. Git Bash/MSYS) copied the
    # file instead of linking it — refresh our own copy in place.
    rm -f "$TARGET"
  else
    echo "    WARNING: '$TARGET' already exists and is not a symlink — refusing to overwrite." >&2
    echo "    Remove it by hand or point MAD_BIN_DIR somewhere else." >&2
    exit 1
  fi
fi
ln -sf "$SRC" "$TARGET"
echo "    symlink: $TARGET -> $SRC"

# 3) check PATH (macOS and Git Bash don't include ~/.local/bin by default)
case ":$PATH:" in
  *":$TARGET_DIR:"*) echo "    ok: '$TARGET_DIR' is on PATH" ;;
  *) echo ""
     echo "    NOTE: '$TARGET_DIR' is NOT on your PATH — mad won't be found."
     echo "    Add this to your shell rc:  export PATH=\"$TARGET_DIR:\$PATH\"" ;;
esac

# 4) skill instructions (printed, never auto-applied — the skills dir varies by runtime)
echo ""
echo "==> To enable the /mad skill, make SKILL.md visible to your agent runtime."
echo "    The SAME SKILL.md works for both Claude Code and Codex:"
echo "        # Claude Code (global skills):"
echo "        mkdir -p ~/.claude/skills/mad && ln -sf \"$REPO_DIR/SKILL.md\" ~/.claude/skills/mad/SKILL.md"
echo "        # Codex (global skills):"
echo "        mkdir -p ~/.codex/skills/mad && ln -sf \"$REPO_DIR/SKILL.md\" ~/.codex/skills/mad/SKILL.md"
echo "    (the exact skills dir varies by version/runtime — check yours first)."

echo ""
if [ "$missing" -eq 0 ]; then
  echo "==> done. Try:  MAD_DRY_RUN=1 mad \"monolith or services?\""
else
  echo "==> installed, but CLIs are missing. Install/authenticate claude and codex before using."
fi
