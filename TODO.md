# Setup Improvements Backlog

Next-session tasks to push `dotfiles-ai` and active repos from 8.8/10 to 10/10.

- [x] **Remove duplicate `GEMINI.md` injection:** Clear the duplicate `user_global` rule copy so only `plugins/dotfiles-ai/rules/GEMINI.md` loads (~1,800 tokens saved per turn).
- [x] **Audit overlapping skills:** Review overlap between `dotfiles-ai/skills/testing-standards` vs. `agent-skills/test-driven-development` and `dotfiles-ai/skills/commit` vs. `agent-skills/git-workflow-and-versioning`; keep only non-overlapping value.
- [ ] **Add hard code/test gates in `doubtless`:** Ratify `CONSTRAINTS.md` and wire automated lint/typecheck/test gates in CI or git hooks.
