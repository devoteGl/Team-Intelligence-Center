---
name: tic-project-adapter-maintainer
description: Create, enrich, audit, migrate, or repair a project's ai-harness/project-adapter.md while preserving confirmed project facts, custom sections, ownership, commands, E2E verification configuration, risk boundaries, Git policy, and local decisions.
---

# TIC Project Adapter Maintainer Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/project-adapter-maintainer.md`.
5. Preserve existing non-placeholder content and unknown custom sections by default.
6. When migrating `verification.e2e`, derive runner, commands, environment, auth, data, cleanup, journeys, and evidence roots only from project evidence; never store secrets or personal absolute paths.
7. Use `<rules_dir>/Skills/code-investigator.md` only for evidence discovery; do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, perform a read-only audit and do not replace an existing adapter with a generated template.
