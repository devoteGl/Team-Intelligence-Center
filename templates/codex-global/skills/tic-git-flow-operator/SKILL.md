---
name: tic-git-flow-operator
description: Use when the user requests branch creation, merge, tag, push, back-merge, or release ref changes, or asks for a policy-aware Git operation plan.
---

# TIC Git Flow Operator Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/git-flow-operator.md`.
5. Treat explicit authorization in the current task as sufficient when the remote, refs, version, and impact resolve uniquely; ask again only for ambiguity or expanded scope.
6. After any release/hotfix tag, keep the operation open until the project-required back-merge or closeout evidence, or an explicit user deferral/waiver, is recorded.

If the target TIC Skill is missing, do not perform unresolved Git writes. Report the known authorization, exact refs, remote freshness, ambiguity, and the smallest decision still needed.
