# Plasma 5 development

## Symlink issue

Plasma 5 does not reliably detect plasmoids installed through symbolic links
inside ~/.local/share/plasma/plasmoids/.

For development, copy the plasmoid directory instead:

```shell
cp -a \
~/projects/plasma-power-workflow/plasmoid5/org.kde.plasma.lock_logout.workflow \
~/.local/share/plasma/plasmoids/
```

After updates:

```shell
kbuildsycoca5
kquitapp5 plasmashell
plasmashell &
```

---

## Useful commands

Restart Plasma and collect logs:

```shell
kquitapp5 plasmashell
QT_LOGGING_RULES="*=true" plasmashell > plasma.log 2>&1
```

Search for QML errors:

```shell
grep -i "error\|warning" plasma.log
```

Check plasmoid configuration:

```shell
grep -R "workflow" \
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

---

## FileDialog

Plasma 5 uses:

```qml
import QtQuick.Dialogs 1.3
```

Using other versions may cause:

```text
FileDialog is not a type
```

The dialog should normally be declared outside FormLayout rows and opened through:

```qml
fileDialog.visible = true
```

---

## Workflow dialog architecture

Keep responsibilities separated:

```text
ConfigWorkflow.qml
    ↓
Configuration only

lockout.qml
    ↓
Workflow engine

WorkflowDialog.qml
    ↓
Presentation only
```

Avoid placing workflow logic inside WorkflowDialog.qml.

---

## Plasma configuration

For ordinary settings:

```qml
property alias cfg_someSetting: control.value
```

For dynamic tables and repeaters:

```qml
plasmoid.configuration.someSetting
```

works and persists correctly.

Direct writes:

```qml
plasmoid.configuration.someSetting = value
```

save immediately and do not activate the Apply button.

---

## Executable engine

The Plasma executable engine returns data through:

```qml
PlasmaCore.DataSource {
    engine: "executable"
}
```

Useful debugging:

```qml
print(sourceName)
print(JSON.stringify(data))
```

---

## Workflow protocol

### Start

Command:

```shell
workflow.sh start shutdown
```

Response:

```json
{
    "id": "12345"
}
```

---

### Status

Command:

```shell
workflow.sh status 12345
```

Running:

```json
{
    "state": "running",
    "workflow_name": "Shutdown workflow",
    "step_name": "Waiting for rsync",
    "workflow_percent": 50,
    "step_percent": 80
}
```

Success:

```json
{
    "state": "success"
}
```

Cancelled:

```json
{
    "state": "cancelled"
}
```

Error:

```json
{
    "state": "error",
    "message": "Network unavailable",
    "on_error": "terminate"
}
```

or

```json
{
    "state": "error",
    "message": "Yandex Disk not responding",
    "on_error": "proceed"
}
```

---

### Cancel

Command:

```shell
workflow.sh cancel 12345
```

Response is optional.

---

## Error handling

### terminate

Workflow stops.

User may:

```text
Force Action
Cancel
```

depending on configuration.

### proceed

Workflow reports a non-critical error.

If enabled:

```text
Force Action (15)
```

counts down and automatically performs the KDE action.

Otherwise behaves like terminate.

---

## Full-screen overlay

Displaying workflow state inside the plasmoid itself is insufficient.

A dedicated QML Window is preferable:

```text
WorkflowDialog.qml
```

Advantages:

* covers the entire screen;
* independent of panel size;
* supports progress bars;
* supports error handling UI.

---

## Virtual machine development

For isolated Plasma testing:

```shell
VBoxManage list vms
VBoxManage startvm <name>
```

When using differencing disks, the parent image must be registered before attaching the child disk.

Typical error:

```text
Parent medium ... is not found in the media registry
```

Fix:

```shell
VBoxManage openmedium disk base.vdi
```

before attaching the differencing image.

---

## Common debugging checklist

Before blaming Plasma:

1. Check QML syntax errors.
2. Check missing imports.
3. Verify configuration values.
4. Verify executable engine output.
5. Verify JSON returned by workflow scripts.
6. Verify timers are stopped on cancel.
7. Verify workflow state is reset before every run.
