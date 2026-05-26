# Lightweight Automation Design

Team-Intelligence-Center remains a rules and skills knowledge base. The automation layer only installs a small project entrypoint and validates that the rules package is complete.

## Adopted From Codex_Project

- Manifest-based versioning.
- Idempotent project bootstrap.
- Marker-bounded `AGENTS.md` merge.
- `--dry-run` installation preview.
- Lightweight lock file for diagnostics.
- Risk-based task routing.
- SDD + TDD as the default engineering principle for standard and critical changes.
- OpenSpec as an optional spec carrier when the project already uses it or the change needs durable behavior tracking.

## Deliberately Excluded

- Codex-only workflow binding.
- Vendored binaries or runtime dependencies.
- Default Git hooks.
- RTK or other wrapper requirements.
- Full/patch distribution packaging.
- Historical PRD/test/docs payloads.
- Forced SDD/Plan/Approval for consulting, read-only, or micro tasks.
- Branch lifecycle automation and default Git mutation.

## Installed Files

The bootstrap script writes only:

```text
AGENTS.md
.tic-rules.lock
docs/ai-rules-usage.md
ai-harness/project-adapter.md
```

`AGENTS.md` is merged inside a marker block so project-owned instructions can coexist with TIC rules.

## Intended Workflow

```bash
bash tools/validate-pack.sh
bash tools/bootstrap-project.sh --dry-run /path/to/project
bash tools/bootstrap-project.sh --yes /path/to/project
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools\bootstrap-project.ps1 -DryRun -ProjectRoot C:\path\to\project
powershell -ExecutionPolicy Bypass -File tools\bootstrap-project.ps1 -Yes -ProjectRoot C:\path\to\project
```

The default install is intentionally minimal. Teams can still use the deeper TIC skills manually when a task justifies the extra structure.

## SDD + TDD And OpenSpec

The lightweight automation does not force every conversation through OpenSpec. The rule is:

- Consulting and micro tasks stay direct.
- Standard and critical changes require SDD + TDD.
- If the business project has `openspec/`, store or link the SDD in the OpenSpec change.
- If OpenSpec is not present, use `docs/sdd/` or the project-approved spec location.
- Tests or explicit verification checks should be derived from the SDD acceptance criteria before implementation.

OpenSpec is therefore integrated as a spec carrier, not as a mandatory heavy workflow for every task.

## Optional Git Advice

TIC provides read-only Git advice scripts for developers who want help naming branches and commits without letting automation mutate repository state.

macOS / Linux / WSL:

```bash
bash tools/git-advice.sh --type feature "lightweight automation"
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools\git-advice.ps1 -Type feature "lightweight automation"
```

These scripts only inspect:

- Current repository root, branch, upstream, and changed file count.
- Whether the current branch looks long-lived.
- Suggested short branch name and commit title.
- Local/runtime file risk reminders.

They never run `git switch`, `git add`, `git commit`, `git push`, `git merge`, `git tag`, or branch deletion.

## How Developers Pull The Rules

Use Git as the distribution boundary.

For a developer-local rules checkout:

```bash
git clone https://ycbl.xadazhihui.cn:18443/NexusAI/Team-Intelligence-Center.git
git pull --ff-only
```

For a business project that should pin the rules version, prefer a submodule:

```bash
git submodule add https://ycbl.xadazhihui.cn:18443/NexusAI/Team-Intelligence-Center.git .ai-rules/Team-Intelligence-Center
git submodule update --init --recursive
```

Then run the bootstrap from the checked-out rules directory and pass the business project path.
