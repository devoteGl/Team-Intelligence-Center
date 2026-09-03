---
name: tic-collaboration-memory-maintainer
description: Use when the user explicitly requests collaboration-memory extraction, review, promotion, reconciliation, audit, or deprecation, or confirms long-term reuse value.
---

# TIC Collaboration Memory Maintainer Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:

1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an
   accessible `rules_dir=` containing `Workflow/core.md`, use that
   branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local`
   `rules_dir=`.
3. If no project source exists, use fallback rules source:
   `{{TIC_RULES_DIR}}`.
4. Read and follow
   `<rules_dir>/Skills/collaboration-memory-maintainer.md`.
5. Do not read other tasks or chats without explicit user authorization or
   explicit project policy.
6. Read project `AGENTS.md`, `ai-harness/project-adapter.md`, shared memory,
   and local profile only as required by the selected mode.
7. Never copy raw conversations, secrets, PII, or private task transcripts
   into committed assets.
8. Do not copy TIC Skills into project-local or global skills.

If the canonical Skill is missing, do not promote inferred memories. Produce a
local-only candidate summary with evidence and sensitivity labels, report the
missing rule, and wait before changing team or project assets.
