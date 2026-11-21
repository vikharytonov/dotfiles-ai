---
name: commit
description: Generate Conventional Commit messages based on git diffs, task context, branch name, and feedback.
---

# Commit Skill

Use this skill whenever you need to generate a git commit message for code changes made in the workspace. It enforces Conventional Commit formatting, header length limits (<=80 chars), body bullet limits (<=60 chars), imperative mood, and context gathering protocols.

---

## 📚 Reference Documentation Index

Before generating a commit message, consult the relevant topic guides:

| Reference | Use When |
| :--- | :--- |
| [`references/conventional-commits.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/commit/references/conventional-commits.md) | Checking strict formatting rules, header limits (<=80 chars), body bullet limits (<=60 chars), imperative mood, and breaking change syntax. |
| [`references/context-gathering.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/commit/references/context-gathering.md) | Executing the step-by-step protocol to inspect branch name, `git diff`, `git diff --cached`, untracked files, and conversation context. |
| [`references/commit-types-and-examples.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/commit/references/commit-types-and-examples.md) | Selecting the correct commit type (`feat`, `fix`, `docs`, `refactor`, `perf`, `test`, etc.) and reviewing real-world commit examples. |
| [`references/sources.md`](file:///home/vitalii/projects/dotfiles-ai/my-custom-skills/skills/commit/references/sources.md) | Checking official Conventional Commits specifications, Angular commit guidelines, and Git documentation resources. |

---

## 📌 Quick Rules Summary

1. **Header Line**:
   * Format: `<type>(<scope>): <short summary>`
   * Length limit: Maximum **80 characters**.
   * Mood: **Imperative** (e.g., `add`, `fix`, `update`, `remove`).
   * Punctuation: **No period** at the end.

2. **Body & Bullet Points**:
   * Separate header from body with a blank line.
   * Format: Bulleted list (`- `).
   * **Strict Length Limit**: Each bullet line must NOT exceed **60 characters**.

3. **Context Check**:
   * Check `git branch --show-current`, `git diff`, and `git diff --cached` before writing the message. Do not guess code changes.
