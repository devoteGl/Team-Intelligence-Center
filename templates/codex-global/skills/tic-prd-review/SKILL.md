---
name: tic-prd-review
description: Use when reviewing an existing PRD or deciding whether a product baseline is ready to authorize durable implementation.
---

# TIC PRD Review Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Resolve the project rules source from `.tic-rules.lock`, then `.tic-rules.local`.
2. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
3. Read and follow `<rules_dir>/Skills/prd-review-checklist.md`.
4. Do not copy TIC Skills into project-local or global skills.

If the checklist is missing, report the gap and review only outcome, users, journey,
scope, non-goals, acceptance, evidence, conflicts, and authorization state.
