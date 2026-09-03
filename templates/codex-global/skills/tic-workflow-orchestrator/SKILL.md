---
name: tic-workflow-orchestrator
description: Use when the user explicitly requests TIC workflow planning, governance review, or a decision summary for protected actions. Ordinary local tasks do not require this capability.
---

# TIC Workflow Orchestrator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read `<rules_dir>/Workflow/core.md`.
5. Read and follow `<rules_dir>/Skills/tic-workflow-orchestrator.md`.
6. Do not copy TIC Skills into project-local or global skills.
7. Treat related capabilities as discovery hints, not automatic routing.

If the target TIC capability is missing, produce only a lightweight decision
summary containing outcome, boundaries, done criteria, verification, authority,
product baseline status, planning depth, execution authority, verification scope,
review level, fact persistence, and pending confirmations. Do not generate a task tier, fixed
capability graph, skipped-capability inventory, or mandatory external workflow.
