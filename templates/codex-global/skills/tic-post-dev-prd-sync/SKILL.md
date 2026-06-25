---
name: tic-post-dev-prd-sync
description: Use after standard or critical delivery when PRD updates may be needed; generates evidence-based PRD update drafts without promoting inferred rules automatically.
---

# TIC Post Dev PRD Sync Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/post-dev-prd-sync.md`.
5. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, report that and continue with an evidence-based PRD update draft: collect specs, diff, commits, tests, UI verification, API contracts, candidate rules, and pending confirmations.
