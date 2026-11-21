# Token, Context & Model Efficiency Rules

## 1. Output & Tool Hygiene (Minimize Token Burn)
- **Brevity & Directness:** Keep responses to 2–4 short bullets or 1–2 brief paragraphs. Skip preamble, filler, and internal reasoning walkthroughs.
- **Targeted Code Edits:** Output only targeted diffs or modified functions—never regenerate full files or boilerplate.
- **Minimal Context Footprint:**
  - Read only needed line ranges (`StartLine`/`EndLine`) or use `grep_search` instead of reading entire large files into the main context.
  - Combine shell checks into a single command rather than chaining multiple exploratory tool calls.
  - Recommend `/compact` when a session's context grows long.

## 2. Automatic Model-per-Task & Subagent Routing
Explicit user requirement: Route tasks to minimize quota/token cost and keep the main context window small. **Never spawn a subagent if direct execution uses fewer tokens than subagent startup overhead.**

- **Tier 0 — Direct Fast Execution (Zero Subagent Overhead):**
  - *Scope:* Routine check-ins (`selfcare`), 1–3 file edits, targeted bash/git commands, and direct Q&A.
  - *Action:* Execute directly in the main session in 1–2 tool calls.
- **Tier 1 — Context Offloading (`TypeName='research'`, `Model='flash'` or `'flash_lite'`):**
  - *Scope:* Noisy/broad searches (`>4` files), large log/transcript parsing (`flash_lite`), or doc/web lookups (`flash`) that would bloat the main conversation history.
  - *Action:* Spawn `research` with `Model='flash'` or `'flash_lite'` and require a concise bulleted summary back.
- **Tier 2 — Standard Development (Main Session or `Model='inherit'`):**
  - *Scope:* Standard feature work, debugging, and tests where files are already known.
  - *Action:* Handle directly in the main session (use `Model='inherit'` subagents only for parallel independent work).
- **Tier 3 — Deep Architecture & Audits (`TypeName='self'`, `Model='pro'` or `/boost`):**
  - *Scope:* Complex 4+ file refactors, security/auth/HMAC logic, subtle concurrency bugs, or `/boost` reviews.
  - *Action:* Delegate to `Model='pro'` (or `DeepCoder`/`DeepInvestigator` on `/boost`) with verification checks.
- **Project Context Overrides:**
  - **`/home/vikharitonov/projects/selfcare`:** Strictly Tier 0 (1 CLI command + 2–4 bullet response) unless an explicit system upgrade is requested.
  - **Code Projects (`doubtless` / `shopify-ai-qa`):** Offload broad doc/spec scans to `research` (`flash`), do targeted coding in the main session, and reserve `pro` for multi-file architecture or security/App Proxy routes.
  - **Post-Reboot eGPU Reminder (`"remaind command"` / `"remind command"`):** When the user says `"remaind command"`, output and explain `cat /proc/cmdline && cat /sys/bus/pci/devices/0000:03:00.0/pp_dpm_pcie && journalctl -b 0 -k | grep -c "AER:"` (checks active GRUB `amdgpu` flags, RX 9060 XT PCIe link speed/DPM states, and `0` PCIe AER bus errors).

## 3. Fundamental Code & Comment Principles (Always Enforce on Write/Update/Delete)
- **Minimal Code & Small Chunks (KISS / YAGNI):** Write the fewest lines of code possible per task. Keep functions and logic chunks small, flat, and single-purpose. Never add speculative features, premature abstractions, or single-use wrappers.
- **Self-Explaining Names & Clean Code Mechanics:**
  - *Names over comments:* Functions, variables, and types must clearly state their intent. Extract complex boolean conditions into intention-revealing variables or small helpers instead of commenting them.
  - *Guard clauses over nesting:* Use early returns (`if (!isValid) return;`) to keep indentation flat (max 1–2 levels).
  - *Small signatures & named constants:* Limit functions to 2–3 arguments (avoid boolean flag arguments; use an options object or separate functions). Replace magic numbers/strings with named constants.
- **Comments as a "Last Resort" Signal:**
  - Presence of a comment signals either a failure to write clear names/logic OR a non-obvious domain constraint/workaround (*why*, never *what*).
  - Keep necessary comments to 1 short line. Never write narrator comments (`// loop through items`) or redundant JSDoc/boilerplate.
- **Strict Comment-Code Lifecycle (Sync or Delete):**
  - Every time code is modified or deleted, inspect adjacent comments.
  - If the code change alters the logic, immediately **update** the comment or **delete** it if no longer valid or if the new code speaks for itself.
- **Surgical Edits & Zero Drive-By Refactoring:**
  - Produce the smallest possible diff. Touch only the lines required for the task.
  - Never reformat, rename, or refactor unrelated adjacent code. Delete only dead imports, variables, or comments that your own edit rendered obsolete.
