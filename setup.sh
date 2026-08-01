#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setting up Custom Antigravity Skills ===${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure plugins directory exists
mkdir -p ~/.gemini/config/plugins

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
