---
name: tic-git-flow-operator
description: Use before creating, merging, tagging, pushing, or back-merging Git Flow branches. Requires business-named feature branches, version-style release/hotfix branches such as 1.0.004, no-v-prefix tags, evidence, and user confirmation before execution.
---

# TIC Git Flow Operator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/git-flow-operator.md`.
5. Do not create branches, merge, tag, push, or back-merge until the user confirms the proposed command.

If the target TIC Skill is missing, produce a Git Flow confirmation card with business-named feature branch or `*.*.***` release/hotfix branch, no-v-prefix tag candidate when relevant, scanned branch/tag evidence, base commit, proposed command, and wait for user confirmation.
