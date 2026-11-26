#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.gemini/config/plugins
mkdir -p ~/.gemini/antigravity-cli/skills
mkdir -p ~/.gemini/config/skills

usage() {
  echo -e "${BLUE}Usage:${NC}"
  echo "  ./setup.sh                      # Install everything (plugin + all skills + agent-skills)"
  echo "  ./setup.sh --list               # List available skills in dotfiles-ai"
  echo "  ./setup.sh --rules              # Link standalone global rules (GEMINI.md & AGENTS.md) for non-plugin tools"
  echo "  ./setup.sh --skill <name>        # Install/update a single skill by name"
  echo "  ./setup.sh --remove-skill <name> # Remove a single installed skill by name"
  echo "  ./setup.sh --init-repo [dir]     # Scaffold CONSTRAINTS.md, PROGRESS.md, and pre-commit gate in a repo"
}

link_rules() {
  echo -e "${BLUE}Linking global AI rules (GEMINI.md & AGENTS.md):${NC}"
  SRC_RULE="$DOTFILES_DIR/rules/GEMINI.md"
  for DEST_RULE in "$HOME/.gemini/GEMINI.md" "$HOME/.gemini/AGENTS.md"; do
    if [ -e "$DEST_RULE" ] && [ ! -L "$DEST_RULE" ]; then
      cp -f "$DEST_RULE" "${DEST_RULE}.backup"
    fi
    ln -sf "$SRC_RULE" "$DEST_RULE"
    echo -e "  ${GREEN}✓${NC} Linked $(basename "$DEST_RULE") -> $SRC_RULE"
  done
}

install_skill() {
  local SKILL_NAME="$1"
  local SKILL_DIR="$DOTFILES_DIR/skills/$SKILL_NAME"

  if [ ! -d "$SKILL_DIR" ]; then
    echo -e "  ${RED}✗${NC} Skill '$SKILL_NAME' not found in $DOTFILES_DIR/skills/"
    exit 1
  fi

  for TARGET_BASE in "$HOME/.gemini/antigravity-cli/skills" "$HOME/.gemini/config/skills"; do
    rm -rf "$TARGET_BASE/$SKILL_NAME"
    ln -s "$SKILL_DIR" "$TARGET_BASE/$SKILL_NAME"
  done
  echo -e "  ${GREEN}✓${NC} Installed skill: $SKILL_NAME"
}

remove_skill() {
  local SKILL_NAME="$1"
  rm -rf "$HOME/.gemini/antigravity-cli/skills/$SKILL_NAME" "$HOME/.gemini/config/skills/$SKILL_NAME"
  echo -e "  ${GREEN}✓${NC} Removed skill: $SKILL_NAME"
}

list_skills() {
  echo -e "${BLUE}Available skills in $DOTFILES_DIR/skills/:${NC}"
  for SKILL_DIR in "$DOTFILES_DIR/skills/"*/; do
    [ -d "$SKILL_DIR" ] && echo "  - $(basename "$SKILL_DIR")"
  done
}

init_repo() {
  local TARGET_DIR="${1:-.}"
  if [ ! -d "$TARGET_DIR" ]; then
    echo -e "  ${RED}✗${NC} Directory '$TARGET_DIR' not found."
    exit 1
  fi

  echo -e "${BLUE}Scaffolding quality gates in $TARGET_DIR:${NC}"
  for TMPL in CONSTRAINTS.md PROGRESS.md; do
    local DEST="$TARGET_DIR/$TMPL"
    if [ -e "$DEST" ]; then
      echo -e "  - Skipped $TMPL (already exists)"
    else
      cp "$DOTFILES_DIR/templates/$TMPL" "$DEST"
      echo -e "  ${GREEN}✓${NC} Created $DEST"
    fi
  done

  if git -C "$TARGET_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    local HOOK_PATH
    HOOK_PATH="$(git -C "$TARGET_DIR" rev-parse --git-path hooks/pre-commit)"
    case "$HOOK_PATH" in
      /*) ;;
      *) HOOK_PATH="$TARGET_DIR/$HOOK_PATH" ;;
    esac
    if [ -e "$HOOK_PATH" ]; then
      echo -e "  - Skipped pre-commit hook (already exists at $HOOK_PATH)"
    else
      mkdir -p "$(dirname "$HOOK_PATH")"
      cp "$DOTFILES_DIR/templates/pre-commit" "$HOOK_PATH"
      chmod +x "$HOOK_PATH"
      echo -e "  ${GREEN}✓${NC} Installed $HOOK_PATH"
    fi
  else
    echo -e "  - Skipped pre-commit hook (not a git repository)"
  fi
}

# Handle single-command flags
case "${1:-}" in
  --help|-h)
    usage
    exit 0
    ;;
  --list|-l)
    list_skills
    exit 0
    ;;
  --rules|-r)
    link_rules
    exit 0
    ;;
  --skill|-s)
    if [ -z "${2:-}" ]; then echo -e "${RED}Error: Missing skill name.${NC}"; usage; exit 1; fi
    install_skill "$2"
    exit 0
    ;;
  --remove-skill)
    if [ -z "${2:-}" ]; then echo -e "${RED}Error: Missing skill name.${NC}"; usage; exit 1; fi
    remove_skill "$2"
    exit 0
    ;;
  --init-repo)
    init_repo "${2:-.}"
    exit 0
    ;;
esac

echo -e "${BLUE}=== Setting up Dotfiles-AI (Rules & Skills) ===${NC}"

# Clean up legacy my-custom-skills symlink if present
rm -rf "$HOME/.gemini/config/plugins/my-custom-skills"

# Link root dotfiles-ai plugin (provides rules/GEMINI.md without user_global duplication)
DEST_PLUGIN="$HOME/.gemini/config/plugins/dotfiles-ai"
rm -rf "$DEST_PLUGIN"
ln -s "$DOTFILES_DIR" "$DEST_PLUGIN"
echo -e "  ${GREEN}✓${NC} Linked plugin: dotfiles-ai"

# Remove duplicate top-level rule symlinks when managed by the plugin
for DUP_RULE in "$HOME/.gemini/GEMINI.md" "$HOME/.gemini/AGENTS.md"; do
  if [ -L "$DUP_RULE" ] && [ "$(readlink "$DUP_RULE")" = "$DOTFILES_DIR/rules/GEMINI.md" ]; then
    rm -f "$DUP_RULE"
    echo -e "  ${GREEN}✓${NC} Removed duplicate rule symlink: $(basename "$DUP_RULE")"
  fi
done

echo -e "\n${BLUE}Installing all skills:${NC}"
for SKILL_DIR in "$DOTFILES_DIR/skills/"*/; do
  [ -d "$SKILL_DIR" ] && install_skill "$(basename "$SKILL_DIR")"
done

echo -e "\n${BLUE}Checking official agent-skills plugin:${NC}"
SKILLS_REPO_DIR="$HOME/.gemini/config/plugins/agent-skills"
SKILLS_REPO_URL="https://github.com/addyosmani/agent-skills.git"

if [ -d "$SKILLS_REPO_DIR" ]; then
  echo -e "  ${GREEN}✓${NC} agent-skills exists. Pulling latest updates..."
  git -C "$SKILLS_REPO_DIR" pull
else
  echo -e "  ${GREEN}✓${NC} Cloning agent-skills repository..."
  git clone "$SKILLS_REPO_URL" "$SKILLS_REPO_DIR"
fi

echo -e "\n${GREEN}=== Setup completed successfully! ===${NC}"
