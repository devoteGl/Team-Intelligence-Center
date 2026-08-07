---
name: tic-candidate-rule-extractor
description: Compatibility wrapper. Candidate rule extraction is now a code-investigator subflow with confidence labels and source evidence.
---

# TIC Candidate Rule Extractor Wrapper

This is a Codex global wrapper for Team-Intelligence-Center.

When invoked:
1. Locate the current project's `.tic-rules.lock`; if it has a non-empty `rules_path=`, resolve it relative to the project root.
2. If no project-relative source exists, read `.tic-rules.local` and use its `rules_dir=`.
3. If no project source exists, use fallback rules source: `{{TIC_RULES_DIR}}`.
4. Prefer the business-rule discovery section of
   `<rules_dir>/Skills/code-investigator.md` when full investigation context is needed.
5. If the user explicitly asks for rule extraction only, read `<rules_dir>/Skills/candidate-rule-extractor.md`.
6. Do not copy TIC Skills into project-local or global skills.

If the target TIC Skill is missing, extract only candidate rules with source evidence and confidence labels; never promote inferred rules automatically.
