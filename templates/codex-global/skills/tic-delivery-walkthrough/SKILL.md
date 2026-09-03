---
name: tic-delivery-walkthrough
description: Use when an identified consumer needs an asynchronous review, QA, demo, usage, or takeover walkthrough backed by existing delivery evidence.
---

# TIC Delivery Walkthrough Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/delivery-walkthrough.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a concise delivery walkthrough with scope, user-visible changes, changed files, verification evidence, UI screenshots or recordings when relevant, review guidance, known risks, and follow-up actions.
