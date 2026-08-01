# Custom AI Agent Skills

A repository for version controlling and synchronizing your custom global Google Antigravity skills across machines.

## Structure
- `my-custom-skills/`: Contains the plugin definition and your custom skill files.
  - `plugin.json`: Plugin description.
  - `skills/`: Put any custom `.md` skill files in this directory to share them.

## Installation / Sync

1. Clone this repository on your workstation:
   ```bash
   git clone <your-repo-url> ~/dotfiles-ai
   ```

2. Run the setup script to symlink the custom skills plugin and download the official `agent-skills` repository:
   ```bash
   chmod +x ~/dotfiles-ai/setup.sh
   ~/dotfiles-ai/setup.sh
   ```

Any changes or new skills added to `~/dotfiles-ai/my-custom-skills/skills/` will automatically be loaded by Antigravity on all linked workstations.
