# Dotfiles-AI Improvement Backlog

Backlog scoped to `dotfiles-ai` rules, skills, templates, and workflow automation.

- [x] **Remove duplicate `GEMINI.md` injection:** Clear the duplicate `user_global` rule copy so only `plugins/dotfiles-ai/rules/GEMINI.md` loads (~1,800 tokens saved per turn).
- [x] **Audit overlapping skills:** Review overlap between `dotfiles-ai/skills/testing-standards` vs. `agent-skills/test-driven-development` and `dotfiles-ai/skills/commit` vs. `agent-skills/git-workflow-and-versioning`; keep only non-overlapping value.
- [x] **Generalize repo gate onboarding:** Add `setup.sh --init-repo [dir]` for `CONSTRAINTS.md`, `PROGRESS.md`, and `pre-commit` scaffolding, plus a 1-line repo creation/audit trigger in `rules/GEMINI.md`.
- [ ] **Add reusable CI gate templates (`templates/ci/`):** Provide minimal GitHub Actions templates (Node/TS, Python) that enforce `CONSTRAINTS.md` lint, typecheck, and test gates.
- [ ] **Audit `react-component-standards` and `react-router` skills:** Trim redundant prose/examples for token efficiency and verify alignment with React 19 and React Router v7+.
- [ ] **Add `dotfiles-ai` self-check script:** Validate `setup.sh` syntax (`bash -n`), `plugin.json`, skill YAML frontmatter, and `verify-docs.sh` across all Markdown files.
