---
name: tic-delivery-walkthrough
description: Use after implementation to create a concise, evidence-based delivery walkthrough artifact with change summary, verification evidence, review guidance, screenshots or recordings when relevant, risks, and follow-up actions.
---

# TIC Delivery Walkthrough Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/delivery-walkthrough.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, produce a concise delivery walkthrough with scope, user-visible changes, changed files, verification evidence, UI screenshots or recordings when relevant, review guidance, known risks, and follow-up actions.
