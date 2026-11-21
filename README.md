# Custom AI Agent Skills & Global Rules

A repository for version-controlling and synchronizing your custom global Google Antigravity (and universal AI agent) rules and skills across machines.

## Structure
- `my-custom-skills/`: Contains the plugin definition, global rules, and custom skill files.
  - `plugin.json`: Plugin description.
  - `rules/GEMINI.md`: Always-on global AI rules (Token/Model routing + Fundamental Code & Comment Principles). Symlinked to `~/.gemini/GEMINI.md` and `~/.gemini/AGENTS.md` (compatible with Antigravity, Gemini CLI, Claude Code, Codex, and Cursor).
  - `skills/`: Put any custom skill directories in this folder to share them across machines.

## Installation / Sync on Any Laptop

1. Clone this repository on your workstation:
   ```bash
   git clone https://github.com/vikharytonov/dotfiles-ai.git ~/projects/dotfiles-ai
   ```

2. Run the setup script to symlink the global rules (`GEMINI.md` & `AGENTS.md`), custom skills plugin, and official `agent-skills` repository:
   ```bash
   chmod +x ~/projects/dotfiles-ai/setup.sh
   ~/projects/dotfiles-ai/setup.sh
   ```

Any updates pushed to `my-custom-skills/rules/GEMINI.md` or `my-custom-skills/skills/` will automatically take effect across all linked workstations after `git pull`.
