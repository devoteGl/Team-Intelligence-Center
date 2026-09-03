---
name: tic-project-adapter-maintainer
description: Use when the user requests creating, enriching, auditing, migrating, or repairing project-adapter.md, or when a confirmed adapter conflict blocks current work.
---

# TIC Project Adapter Maintainer Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/project-adapter-maintainer.md`.
5. Preserve existing non-placeholder content and unknown custom sections by default.
6. When migrating `verification.e2e`, derive runner, commands, environment, auth, data, cleanup, journeys, and evidence roots only from project evidence; never store secrets or personal absolute paths.
7. Do not automatically invoke related capabilities; do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, perform a read-only audit and do not replace an existing adapter with a generated template.
