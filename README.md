# plasma-power-workflow

[![Licence: GPL v3+](https://img.shields.io/badge/Licence-GPLv3%2B-blue.svg)](LICENSE)

A KDE Plasma power workflow plasmoid.

The plasmoid inserts a configurable workflow stage between the user's power action selection and the actual execution of that action. It allows external scripts or applications to perform custom tasks before logout, reboot, or shutdown, while providing progress feedback to the user.

Typical use cases include synchronisation, backups, virtual machine shutdown, container management, and other user-defined workflows. The plasmoid itself remains workflow-agnostic and communicates only with an external workflow process.

## Project Goals

* Preserve the standard KDE Plasma user experience.
* Allow arbitrary user-defined workflows before logout, reboot, or shutdown.
* Keep workflow logic completely separate from the plasmoid.
* Provide progress reporting and estimated completion time.
* Maintain compatibility with KDE Plasma 5.
* Facilitate future support for KDE Plasma 6.

## Current Status

The project is currently based on the KDE Plasma Lock/Logout plasmoid and serves as the foundation for workflow integration development.

Target platform:

* KDE Plasma 5

Future platform:

* KDE Plasma 6 (research in progress)

## Platform Support

The current implementation targets KDE Plasma 5.

Initial Plasma 6 compatibility research has been completed and documented in:

docs/plasma6-compatibility.md

Plasma 6 support is not currently a development priority.

## Licence

This project is licensed under the GNU General Public License version 3, or (at your option) any later version.

See the [LICENSE](LICENSE) file for details.

## Origin

This project started as a fork of the KDE Plasma Lock/Logout plasmoid (`org.kde.plasma.lock_logout`).

The original KDE code is distributed under a combination of GPL-2.0-or-later and LGPL-2.0-or-later licences. This repository preserves the original copyright notices and licence information where applicable.

All modifications made specifically for the plasma-power-workflow project are distributed under the GNU General Public License version 3, or (at your option) any later version.


## JSON Contract

The plasmoid communicates with workflow implementations using a simple JSON-based command-line protocol.

A workflow implementation must support:

```bash
workflow start shutdown|reboot|logout
workflow status <id>
workflow cancel <id>
```

### Start Response

```json
{
  "id": "7b0a7d8f",
  "on_error": "terminate"
}
```

### Status Response

Minimal valid response:

```json
{
  "id": "7b0a7d8f",
  "state": "running",
  "on_error": "terminate"
}
```

Additional fields are optional:

```json
{
  "id": "7b0a7d8f",
  "state": "running",
  "on_error": "terminate",

  "workflow_name": "Shutdown Workflow",

  "step_name": "Waiting for Yandex Disk",
  "step_current": 2,
  "step_total": 5,

  "step_percent": 35,
  "workflow_percent": 63,

  "started": "2026-06-07T03:12:44Z"
}
```

### Supported States

```text
running
success
error
cancelled
```

### Error Policies

```text
terminate
proceed
ask
```

| Policy    | Behaviour                                                                          |
| --------- | ---------------------------------------------------------------------------------- |
| terminate | Stop the requested power action and ask the user whether to force it or cancel it. |
| proceed   | Show a warning and continue automatically after a countdown.                       |
| ask       | Ask the user whether to continue or cancel.                                        |

### Success Response

```json
{
  "id": "7b0a7d8f",
  "state": "success"
}
```

After receiving `success`, the plasmoid performs the requested logout, reboot, or shutdown action.

### Error Response

```json
{
  "id": "7b0a7d8f",
  "state": "error",
  "on_error": "terminate",
  "message": "Yandex Disk synchronisation timed out"
}
```

### Examples

For a complete specification see:

- docs/api.md
- examples/workflow-example-minimal.sh
- examples/workflow-example.sh
