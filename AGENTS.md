# Project instructions

Before planning or modifying files, read:

`~/projects/AGENTS.md`

If the workspace policy cannot be read, stop and report that it is unavailable.

The rules below supplement or tighten the workspace policy for this repository.

## Project boundary

- This maintenance plasmoid targets KDE Plasma 5; Plasma 6 remains documented future research, not an implied migration task.
- Preserve the JSON workflow protocol, existing Plasma user experience, error policies, and separation between the plasmoid and external workflow logic.
- Never test by initiating shutdown, reboot, logout, sleep, hibernate, or a real backup/synchronization workflow.

## Actual contract and done criteria

- `scripts/deploy-plasma5.sh` changes the user's installed plasmoid and requires a direct deployment request.
- Repository examples are protocol references; use synthetic commands only when validating them.
- There is no Makefile, package metadata, automated test suite, or CI workflow.
- Changes are complete after static/protocol consistency review and a clear statement of any live Plasma verification deferred to the operator.
