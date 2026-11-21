# Conventional Commits Specification & Formatting Rules

The `commit` skill enforces the **Conventional Commits v1.0.0** specification with strict length and style constraints.

---

## 1. Structure of a Commit Message

A Conventional Commit message consists of a **header**, an optional **body**, and an optional **footer**:

```text
<type>(<scope>): <short summary>

- <bullet point 1 describing change>
- <bullet point 2 describing change>

[BREAKING CHANGE: <description>]
[Fixes #<issue-number>]
```

---

## 2. Header (Title) Line Guidelines

The header line is the most visible part of your commit (shown in `git log --oneline`, GitHub PR timelines, and release notes).

* **Format**: `<type>(<scope>): <short summary>`
* **Strict Length Limit**: Maximum **80 characters**.
* **Imperative Mood**: Use imperative present tense verbs (e.g., `add`, `fix`, `update`, `remove`, `refactor` instead of `added`, `fixed`, `updated`, `removing`).
* **No Trailing Period**: Do not end the summary line with a period (`.`).
* **Casing**: Use lowercase for type, scope, and summary (unless scope refers to a proper noun/class name like `React` or `Auth`).

### Examples of Valid Headers:
```text
feat(auth): add JWT token refresh endpoint
fix(cart): prevent negative item quantities on checkout
docs(readme): update local development setup instructions
refactor(store): simplify state reducer logic
```

---

## 3. Body / Bullet Points Guidelines

Use the body to explain **what** changed and **why** (rather than *how*, which is visible in the diff).

* **Blank Line Required**: Always separate the header line from the body with a blank line.
* **Bulleted List**: Use hyphen bullet points (`- `).
* **Strict Line Length Limit**: Each bullet point line must **NOT exceed 60 characters**.
* **Concise Descriptions**: Keep bullet points focused and short. Wrap longer explanations into multiple bullets under 60 chars.

### Example of Valid Body:
```text
feat(ui): add accessible modal dialog component

- Implement focus trap hook for keyboard navigation
- Add escape key listener to close modal
- Merge utility styles safely using cn helper
```

---

## 4. Breaking Changes

Indicate breaking API or behavior changes in one of two ways:

1. **Exclamation Mark (`!`)**: Append `!` after type/scope in the header line:
   ```text
   feat(api)!: change user endpoint payload schema
   ```

2. **`BREAKING CHANGE:` Footer**: Add a footer starting with `BREAKING CHANGE: `:
   ```text
   feat(api): change user endpoint payload schema

   - Remove legacy v1 user ID field from response

   BREAKING CHANGE: The v1 user ID field has been removed in favor of UUID.
   ```

---

## 5. Issue Tracking & Footers

Link issues, pull requests, or co-authors in footers at the end of the message:

```text
Fixes #142
Closes #89
Co-authored-by: Name <user@example.com>
```
