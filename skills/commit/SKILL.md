---
name: commit
description: Generate Conventional Commit messages based on git diffs, task context, and branch name. Use when asked to commit changes or write a commit message.
---

# Commit Skill

Generate concise, accurate **Conventional Commits v1.0.0** messages with minimal tool calls.

## 1. Single-Call Context Gathering
Gather branch, status, and full diff in **one** shell command (never guess changes or run separate git commands):
```bash
git status -sb && git diff HEAD
```
- **Atomic Commits:** Group logically related changes; split unrelated changes into separate commits.
- **Doc-Drift Gate (Docs-as-Code):** If `git diff HEAD` modifies CLI flags, `.env*`, `package.json` scripts, public routes/APIs, or architecture without updating `README.md` or `docs/`, pause and sync or delete the affected documentation before committing.
- **Safety Check:** Never stage or commit `.env`, secrets, credentials, or private keys.

## 2. Format & Strict Length Limits
```text
<type>(<scope>): <short summary>

- <bullet 1 explaining what/why>
- <bullet 2 explaining what/why>

[BREAKING CHANGE: <description>]
[Fixes #<issue>]
```

- **Header (`<type>(<scope>): <summary>`):**
  - Max **80 characters**.
  - **Imperative present tense** (`add`, `fix`, `update`, `remove`, not `added` or `adds`).
  - Lowercase summary, **no trailing period**.
- **Body (Optional for trivial 1-line changes):**
  - Blank line after header.
  - Bulleted list (`- `), max **60 characters per line**.
  - Explain *what* and *why*, not *how*.
- **Breaking Changes:** Append `!` after type/scope (`feat(api)!: ...`) or add a `BREAKING CHANGE:` footer.

## 3. Commit Types
| Type | Use For | Example |
| :--- | :--- | :--- |
| `feat` | New feature or capability | `feat(auth): add OAuth2 login flow` |
| `fix` | Bug fix | `fix(cart): prevent negative item quantity` |
| `refactor` | Code restructuring without behavior change | `refactor(store): simplify user reducer` |
| `perf` | Performance improvement | `perf(query): optimize orders SQL join` |
| `test` | Adding or updating tests | `test(auth): add token validation unit tests` |
| `docs` | Documentation only | `docs(readme): update install instructions` |
| `build` / `ci` | Build system, dependencies, or CI workflows | `build(deps): upgrade React to v19` |
| `chore` / `style` | Maintenance, config, or formatting | `chore(gitignore): ignore local dist folder` |
| `revert` | Reverting a previous commit | `revert: revert commit 4a8b1c2` |
