# Git Context Gathering Protocol

Before generating a commit message, an AI agent must collect complete context from the workspace to ensure accurate, precise, and meaningful commit messages.

---

## 1. Context Gathering Checklist

To form an accurate commit message, execute the following commands and checks in order:

### Step 1: Check Current Branch & Worktree State
```bash
git branch --show-current
git status
```
* **Why**: Identifies feature/bugfix branch intent (e.g. `feat/user-auth` or `fix/checkout-crash`) and distinguishes between staged, unstaged, and untracked files.

### Step 2: Inspect Code Diffs
```bash
# Inspect unstaged changes
git diff

# Inspect staged changes
git diff --cached
```
* **Why**: Reveals the precise line additions, modifications, and deletions. Do not guess what changed; read the actual diff output!

### Step 3: Inspect Untracked Files
If `git status` lists untracked files, view their content using `view_file` or check their location to understand what new modules/files are being introduced.

### Step 4: Analyze Conversation & Task Context
* Review recent user prompts, issue descriptions, or PR requirements to extract the *intent* (the "why") behind the code edits.
* Review any user feedback or code review notes that prompted the changes.

---

## 2. Atomic Commits Strategy

When reviewing workspace changes:
- **Group Related Changes**: Ensure the commit groups changes that belong to a single logical task.
- **Separate Unrelated Changes**: If the workspace contains multiple unrelated edits (e.g., a bug fix AND an unrelated formatting change), stage them separately into atomic commits.
- **Do Not Commit Secrets**: Verify that `.env`, credentials, private keys, or API tokens are NOT included in the diff before committing.
