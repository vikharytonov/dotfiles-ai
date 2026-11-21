---
name: session-manager
description: Manage agent session transitions by compressing current context into a handoff file at the end of a session, and reading it to initialize the next session.
---

# Session Manager Skill

This skill governs how to cleanly save, compress, and restore developer agent context across separate chat sessions, ensuring maximum token efficiency and zero context loss.

## Phase 1: Ending a Session (Compression / Handoff)

Before closing a session, run the compression protocol to capture the project's exact state in a handoff file `.agent_handoff.md` inside the skill directory (`[workspace]/.agents/skills/session-manager/.agent_handoff.md`).

### Steps:
1. Identify all files created, modified, or deleted during the current session.
2. Outline the exact status of the application (e.g., "all tests passing", "dev server configured to local-only").
3. Compile a "Next Steps" checklist of the immediate features or bug fixes to implement.
4. Save this info to `[workspace]/.agents/skills/session-manager/.agent_handoff.md` in markdown format.

---

## Phase 2: Starting a New Session (Initialization / Bootstrap)

At the very beginning of a new chat session:
1. Read the `[workspace]/.agents/skills/session-manager/.agent_handoff.md` file using `view_file`.
2. Inspect the current workspace files to verify the current structure.
3. Validate typegen and build safety using `npm run typecheck` or equivalent check commands.
4. Report the summarized state to the user and confirm the priority of the next tasks.
