#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setting up Custom Antigravity Skills ===${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure config and skills directories exist
mkdir -p ~/.gemini/config/plugins
mkdir -p ~/.gemini/antigravity-cli/skills
mkdir -p ~/.gemini/config/skills

# Link the custom skills plugin
echo -e "\n${BLUE}Linking custom skills plugin:${NC}"
SRC_PLUGIN="$DOTFILES_DIR/my-custom-skills"
DEST_PLUGIN="$HOME/.gemini/config/plugins/my-custom-skills"

if [ -e "$DEST_PLUGIN" ] || [ -L "$DEST_PLUGIN" ]; then
  if [ -L "$DEST_PLUGIN" ] && [ "$(readlink "$DEST_PLUGIN")" = "$SRC_PLUGIN" ]; then
    echo -e "  ${GREEN}✓${NC} Custom skills plugin is already correctly linked."
  else
    echo -e "  ${YELLOW}!${NC} Backing up existing $DEST_PLUGIN to ${DEST_PLUGIN}.backup"
    mv "$DEST_PLUGIN" "${DEST_PLUGIN}.backup"
    echo -e "  ${GREEN}✓${NC} Linking $SRC_PLUGIN to $DEST_PLUGIN"
    ln -s "$SRC_PLUGIN" "$DEST_PLUGIN"
  fi
else
  echo -e "  ${GREEN}✓${NC} Linking $SRC_PLUGIN to $DEST_PLUGIN"
  ln -s "$SRC_PLUGIN" "$DEST_PLUGIN"
fi

# Link individual custom skills to global skill locations
echo -e "\n${BLUE}Linking individual skills to global skill locations:${NC}"
for SKILL_DIR in "$SRC_PLUGIN/skills/"*/; do
  if [ -d "$SKILL_DIR" ]; then
    SKILL_NAME="$(basename "$SKILL_DIR")"

    # ~/.gemini/antigravity-cli/skills/<skill_name>
    CLI_SKILL_DEST="$HOME/.gemini/antigravity-cli/skills/$SKILL_NAME"
    rm -rf "$CLI_SKILL_DEST"
    ln -s "$SKILL_DIR" "$CLI_SKILL_DEST"
    echo -e "  ${GREEN}✓${NC} Linked $SKILL_NAME to ~/.gemini/antigravity-cli/skills/"

    # ~/.gemini/config/skills/<skill_name>
    CONFIG_SKILL_DEST="$HOME/.gemini/config/skills/$SKILL_NAME"
    rm -rf "$CONFIG_SKILL_DEST"
    ln -s "$SKILL_DIR" "$CONFIG_SKILL_DEST"
    echo -e "  ${GREEN}✓${NC} Linked $SKILL_NAME to ~/.gemini/config/skills/"
  fi
done

# Optional: Setup official agent-skills repo if desired
echo -e "\n${BLUE}Checking official agent-skills plugin:${NC}"
SKILLS_REPO_DIR="$HOME/.gemini/config/plugins/agent-skills"
SKILLS_REPO_URL="https://github.com/addyosmani/agent-skills.git"

if [ -d "$SKILLS_REPO_DIR" ]; then
  echo -e "  ${GREEN}✓${NC} agent-skills repository already exists. Pulling latest updates..."
  git -C "$SKILLS_REPO_DIR" pull
else
  echo -e "  ${GREEN}✓${NC} Cloning agent-skills repository..."
  git clone "$SKILLS_REPO_URL" "$SKILLS_REPO_DIR"
fi

echo -e "\n${GREEN}=== Setup completed successfully! ===${NC}"
