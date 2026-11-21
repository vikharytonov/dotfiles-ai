# Commit Types Reference & Real-World Examples

Select the appropriate commit `type` from the standardized table below.

---

## 1. Standard Commit Types Table

| Type | When to Use | Example |
| :--- | :--- | :--- |
| `feat` | Adding a new user-facing feature or API capability | `feat(auth): add OAuth2 Google login flow` |
| `fix` | Fixing a bug or unexpected behavior | `fix(checkout): resolve price calculation error` |
| `docs` | Documentation changes only (README, inline docs, skill guides) | `docs(readme): add installation instructions` |
| `style` | Code style changes (formatting, missing semi-colons, whitespace) | `style(lint): format files according to prettier` |
| `refactor` | Code change that neither fixes a bug nor adds a feature | `refactor(store): extract user reducer into module` |
| `perf` | Code change that improves runtime or build performance | `perf(query): optimize SQL join on orders table` |
| `test` | Adding missing tests or correcting existing test suites | `test(auth): add unit tests for token validation` |
| `build` | Changes affecting build scripts, tooling, or package dependencies | `build(deps): upgrade React to v19` |
| `ci` | Changes to CI/CD pipelines and automation scripts | `ci(github): add automated test workflow` |
| `chore` | Maintenance tasks, gitignore edits, or tooling config | `chore(gitignore): ignore local build output folder` |
| `revert` | Reverting a previous commit | `revert: revert commit 4a8b1c2` |

---

## 2. Real-World Commit Examples

### Single-Line Commit (Short Change)
```text
fix(nav): fix mobile drawer navigation overlap
```

### Multi-Line Commit with Bullet Points (Body Line Length <= 60 chars)
```text
feat(settings): add user notification preferences page

- Add email and push notification toggle switches
- Save preference state to backend API
- Add optimistic UI updates on toggle change
```

### Scoped Commit for Component Standards
```text
docs(react-component-standards): add accessibility guide

- Add WCAG ARIA attributes reference guide
- Add keyboard navigation code examples
- Link sources in skill index table
```

### Breaking Change Commit
```text
feat(api)!: rename user endpoint query parameter

- Rename param 'user_id' to 'userId' for consistency

BREAKING CHANGE: API consumers must update query param 'user_id' to 'userId'.
```
