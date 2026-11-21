# Dotfiles-AI: Global AI Rules & Modular Skills

Version-controlled global rules (`GEMINI.md` / `AGENTS.md`) and modular skills for Google Antigravity (`agy`), Claude Code, Gemini CLI, and Cursor.

## Repository Structure (Flat Layout)
```text
dotfiles-ai/
├── plugin.json                  # Root Antigravity plugin manifest
├── setup.sh                     # Modular installer (all, rules-only, or single skill)
├── rules/
│   └── GEMINI.md                # Always-on global rules (Clean Code, surgical edits, model routing)
└── skills/
    ├── commit/                  # Conventional commit generator
    ├── react-component-standards/
    ├── react-router/
    ├── selfcare-coach/
    ├── session-manager/
    └── wow-linux-setup/
```

---

## Option 1: Install a Single Skill or Rule Only (No Full Clone Required)

### Install or Update One Skill Directly from GitHub (One-Liner)
Replace `<skill-name>` with any folder under `skills/` (e.g., `commit`, `react-router`, `selfcare-coach`):
```bash
SKILL=commit && mkdir -p ~/.gemini/config/skills ~/.gemini/antigravity-cli/skills && \
  curl -sL https://github.com/vikharytonov/dotfiles-ai/archive/refs/heads/main.tar.gz | \
  tar -xz --strip-components=2 -C ~/.gemini/config/skills "dotfiles-ai-main/skills/$SKILL" && \
  ln -sfn ~/.gemini/config/skills/$SKILL ~/.gemini/antigravity-cli/skills/$SKILL
```

### Install or Update Only Global Rules (`GEMINI.md` & `AGENTS.md`)
```bash
mkdir -p ~/.gemini && curl -sL https://raw.githubusercontent.com/vikharytonov/dotfiles-ai/main/rules/GEMINI.md \
  -o ~/.gemini/GEMINI.md && ln -sfn ~/.gemini/GEMINI.md ~/.gemini/AGENTS.md
```

---

## Option 2: Local Clone with Per-Skill CLI (`setup.sh`)

If you clone the repo (`git clone https://github.com/vikharytonov/dotfiles-ai.git ~/projects/dotfiles-ai`), `setup.sh` supports modular commands:

```bash
# List all available skills
~/projects/dotfiles-ai/setup.sh --list

# Install or update a single skill
~/projects/dotfiles-ai/setup.sh --skill commit

# Remove a single skill
~/projects/dotfiles-ai/setup.sh --remove-skill wow-linux-setup

# Install or update only global rules (GEMINI.md & AGENTS.md)
~/projects/dotfiles-ai/setup.sh --rules

# Install everything (plugin + rules + all skills)
~/projects/dotfiles-ai/setup.sh
```

---

## Option 3: Native Antigravity Plugin CLI (`agy plugin`)
Because `plugin.json` is at the repository root, you can also install or validate the entire bundle natively with `agy`:
```bash
agy plugin install https://github.com/vikharytonov/dotfiles-ai
```
