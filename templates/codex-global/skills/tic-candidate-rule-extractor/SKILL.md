---
name: tic-candidate-rule-extractor
description: Use when the user explicitly requests candidate business-rule extraction from traceable evidence without promoting candidates to formal rules.
---

# TIC Candidate Rule Extractor Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. If `.tic-rules.local` explicitly sets `rules_source=local_config` with an accessible `rules_dir=` containing `Workflow/core.md`, use that branch-independent local source.
2. Otherwise resolve `.tic-rules.lock` `rules_path=`, then `.tic-rules.local` `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/candidate-rule-extractor.md`.
5. Do not automatically invoke code investigation or any related capability.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, extract only candidate rules with source evidence and confidence labels; never promote inferred rules automatically.
