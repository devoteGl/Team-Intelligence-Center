---
name: tic-candidate-rule-extractor
description: Use when the user explicitly requests candidate business-rule extraction from traceable evidence without promoting candidates to formal rules.
---

# TIC Candidate Rule Extractor Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Read and follow `<rules_dir>/Skills/candidate-rule-extractor.md`.
5. Do not automatically invoke code investigation or any related capability.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, extract only candidate rules with source evidence and confidence labels; never promote inferred rules automatically.
