# Dotfiles-AI: Global AI Rules & Modular Skills

Version-controlled global AI rules (`GEMINI.md`) and modular skills for Google Antigravity (`agy`), Claude Code, Gemini CLI, and Cursor.

## Quick Start

Install the full bundle locally or via the native Antigravity plugin CLI.

1. Clone the repository and run the full installer:
   ```bash
   git clone https://github.com/vikharytonov/dotfiles-ai.git ~/projects/dotfiles-ai && ~/projects/dotfiles-ai/setup.sh
   ```
   **Verify:** Output ends with `=== Setup completed successfully! ===` and `readlink ~/.gemini/config/plugins/dotfiles-ai` resolves to `~/projects/dotfiles-ai`.
2. Or install natively with the Antigravity plugin CLI ([plugin.json](plugin.json)):
   ```bash
   agy plugin install https://github.com/vikharytonov/dotfiles-ai
   ```
   **Verify:** `agy plugin list` includes `dotfiles-ai`.

## Modular Installation (`setup.sh`)

Run [setup.sh](setup.sh) flags to install or remove individual rules and skills without modifying unrelated modules.

| Command | Action | Target Paths |
| :--- | :--- | :--- |
| `./setup.sh` | Install plugin (includes `GEMINI.md`), all skills, and `agent-skills` | `~/.gemini/{config/plugins,config/skills,antigravity-cli/skills}` |
| `./setup.sh --list` | List available skills in `skills/` | `stdout` |
| `./setup.sh --rules` | Link standalone global rules for non-plugin tools | `~/.gemini/GEMINI.md`, `~/.gemini/AGENTS.md` |
| `./setup.sh --skill <name>` | Symlink a single skill by directory name | `~/.gemini/{config,antigravity-cli}/skills/<name>` |
| `./setup.sh --remove-skill <name>` | Remove a single installed skill symlink | `~/.gemini/{config,antigravity-cli}/skills/<name>` |
| `./setup.sh --init-repo [dir]` | Copy `CONSTRAINTS.md`, `PROGRESS.md`, and install `pre-commit` gate (non-destructive) | `<dir>/CONSTRAINTS.md`, `<dir>/PROGRESS.md`, `<dir>/.git/hooks/pre-commit` |

**Verify:** Run `~/projects/dotfiles-ai/setup.sh --list` or `ls -la ~/.gemini/antigravity-cli/skills/` to confirm expected skill symlinks exist.

### Remote Single-Item Install (No Clone)

1. Install or update one skill directly from GitHub:
   ```bash
   SKILL=commit && mkdir -p ~/.gemini/config/skills ~/.gemini/antigravity-cli/skills && \
     curl -sL https://github.com/vikharytonov/dotfiles-ai/archive/refs/heads/main.tar.gz | \
     tar -xz --strip-components=2 -C ~/.gemini/config/skills "dotfiles-ai-main/skills/$SKILL" && \
     ln -sfn ~/.gemini/config/skills/$SKILL ~/.gemini/antigravity-cli/skills/$SKILL
   ```
   **Verify:** `test -f ~/.gemini/antigravity-cli/skills/$SKILL/SKILL.md && echo "OK"` outputs `OK`.
2. Install or update only global rules (`GEMINI.md` and `AGENTS.md`):
   ```bash
   mkdir -p ~/.gemini && curl -sL https://raw.githubusercontent.com/vikharytonov/dotfiles-ai/main/rules/GEMINI.md \
     -o ~/.gemini/GEMINI.md && ln -sfn ~/.gemini/GEMINI.md ~/.gemini/AGENTS.md
   ```
   **Verify:** `head -n 1 ~/.gemini/AGENTS.md` outputs `# Token, Context & Model Efficiency Rules`.

## Documentation & Skills Map (Diátaxis Index)

Core rules and modular skills organized by Diátaxis type and Gemini 4 execution tier.

| Module | Type | Tier | Path | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Global Rules** | Reference | All Tiers (Baseline) | [rules/GEMINI.md](rules/GEMINI.md) | Token efficiency, model routing, Clean Code, docs, testing, and safety baseline |
| **Secret Guard Hook** | Reference | Global `PreToolUse` | [hooks.json](hooks.json) | Hard-blocks agent reads/writes/shell access to `.env*`, keys, and creds (`force_ask` on hook edits) |
| **Backend & Data Standards** | Reference | Tier 2–3 (Neon/Argon) | [skills/backend-data-standards/SKILL.md](skills/backend-data-standards/SKILL.md) | Stack-agnostic boundary validation, transactions, idempotency, and error taxonomy |
| **Commit** | How-To | Tier 0–1 (Hydrogen) | [skills/commit/SKILL.md](skills/commit/SKILL.md) | Conventional Commits v1.0.0 generator with Doc-Drift Gate |
| **Documentation Standards** | Reference / How-To | Tier 1–4 (Doc-scoped) | [skills/documentation-standards/SKILL.md](skills/documentation-standards/SKILL.md) | Dual-Audience (STE100, Diátaxis, EARS, C4, QRH) rules and validator |
| **Project Lifecycle Models** | Explanation | Tier 2–4 (Phase gates) | [skills/project-lifecycle-models/SKILL.md](skills/project-lifecycle-models/SKILL.md) | 8-phase SDLC framework and Gemini 4 model selection |
| **React Component Standards** | Reference | Tier 2 (Neon) | [skills/react-component-standards/SKILL.md](skills/react-component-standards/SKILL.md) | React Clean Code, derived state, effect hygiene, and WCAG rules |
| **React Router (v7+)** | Reference | Tier 2 (Neon) | [skills/react-router/SKILL.md](skills/react-router/SKILL.md) | React Router v7+ modes, `loader`/`action`, fetchers, and typegen |
| **Testing Standards** | Reference / How-To | Tier 1–3 (Test-scoped) | [skills/testing-standards/SKILL.md](skills/testing-standards/SKILL.md) | EARS-to-Test mapping, 6-point BVA, WCAG locators, clean blueprints & diff gate |
| **Pre-Commit Gate Template** | How-To | Per-Repo Hook | [templates/pre-commit](templates/pre-commit) | Deterministic secret scan, zero bar-lowering diff gate, and `verify-docs.sh` hook |
| **Constraints Template** | Reference | Phase 4 / Audit | [templates/CONSTRAINTS.md](templates/CONSTRAINTS.md) | Starter quality-bar contract (EARS invariants, verification commands, budgets) |
| **Progress Template** | Reference | Session State | [templates/PROGRESS.md](templates/PROGRESS.md) | Starter ≤40-line session continuity log for phase gates and `/compact` |
