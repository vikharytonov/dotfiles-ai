---
name: commit
description: Fast 1-command Conventional Commits v1.0.0 generator with Docs-Drift Gate and QRH verification. Use when asked to commit changes or write a commit message (defer branching, worktrees, semver releases, and changelogs to `git-workflow-and-versioning`).
---

# Commit Skill

Generate concise, accurate **Conventional Commits v1.0.0** messages with minimal tool calls.

## 1. Context Gathering & Pre-Commit Gates

Gather branch, status, and diff in **one** shell command:
```bash
git status -sb && git diff HEAD
```
- The agent `MUST` gather git context in one command before drafting a commit message.
- The agent `MUST` group logically related changes into atomic commits and split unrelated changes.
- `IF` `git diff HEAD` modifies CLI flags, `.env*`, `package.json` scripts, public routes/APIs, or architecture without updating `README.md` or `docs/`, `THEN` the agent `MUST` sync or delete affected docs before committing.
- The agent `MUST NOT` stage or commit `.env` files, secrets, credentials, or private keys.

## 2. Format & Specification Table

```text
<type>(<scope>): <short summary>

- <bullet 1 explaining what/why>
- <bullet 2 explaining what/why>

[BREAKING CHANGE: <description>]
[Fixes #<issue>]
```

| Part | Length / Format | EARS Rule (`MUST` / `MUST NOT`) |
| :--- | :--- | :--- |
| **Header** | `<type>(<scope>): <summary>`, ≤80 chars | `MUST` use imperative present tense (`add`, `fix`), lowercase summary, and no trailing period. |
| **Body** | Blank line after header, `- ` bullets, ≤60 chars/line | `MUST` explain *what* and *why* (not *how*); omit for trivial 1-line changes. |
| **Breaking / Footer** | `feat(scope)!: ...` or `BREAKING CHANGE:` | `MUST` mark breaking changes with `!` or footer; optionally append `Fixes #<issue>`. |

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

## 4. Commit Verification (QRH)

Stage scoped files and commit with the formatted message:
```bash
git add <files> && git commit -m "<header>" -m "<body>"
```
**Verify:** Run `git status -sb && git log -1 --oneline` to confirm a clean working tree for committed paths and a valid header.
