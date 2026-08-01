---
name: commit
description: Generate Conventional Commit messages based on git diffs, task context, branch name, and feedback.
---

# Commit Skill

Use this skill when you need to generate a git commit message for changes made in the workspace.

## 📌 Context Information to Collect
1. **Git Branch Name**: Run `git branch --show-current` to understand the branch-specific task context.
2. **Git Diff**: Run `git diff` (and `git diff --cached`) to inspect code additions, modifications, and deletions.
3. **Task / Goal Context**: Read recent conversation turns or issue/PR context to understand the *why* behind changes.
4. **Reviews / Feedback**: Review any user or reviewer requests that led to changes.

---

## 🚦 Formatting Guidelines

Your generated commit message MUST follow these strict formatting guidelines:

### 1. Title (Header)
* Use the **Conventional Commits** format: `<type>(<scope>): <short summary>` (e.g., `feat(auth): add login endpoint`).
* Limit the title to around **80 characters** maximum.
* Do not end the title with a period.
* Use the imperative mood (e.g., "add", "fix", "relocate" instead of "added", "fixed", "relocated").

### 2. Body / Bullet Points (Optional)
* If additional context is needed, provide a bulleted list of changes.
* Each bullet point must be a short description of what was done.
* **Strict Limit**: Each bullet point must NOT exceed **60 characters**.
* Example:
  ```
  - Move configuration file to new skill subdirectory
  - Update imports and paths in relevant files
  ```
