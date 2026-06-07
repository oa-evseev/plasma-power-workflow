# Plasma 6 Compatibility Notes

This document tracks temporary compatibility patches required to run the Plasma 5 implementation of the plasmoid under Plasma 6.

## Status

Current state:

* Package recognised by Plasma 6
* Widget visible in Widget Explorer
* Widget metadata loaded successfully
* Widget no longer reported as unsupported

The QML implementation has not yet been executed.

## Metadata

### Added package structure declaration

Added:

```json
"KPackageStructure": "Plasma/Applet"
```

Reason:

Plasma 6 does not recognise the package as a Plasma/Applet without an explicit package structure declaration.

Status:

* Required for Plasma 6
* Confirmed

### Added Plasma 6 API version

Added:

```json
"X-Plasma-API-Minimum-Version": "6.0"
```

Reason:

Without this field Plasma 6 reports:

```
Unsupported Widget

This widget was written for an unknown older version of Plasma and is not compatible with Plasma 6.
```

Status:

* Required for Plasma 6
* Confirmed

### Changed main script path

Changed:

```json
"X-Plasma-MainScript": "ui/lockout.qml"
```

to:

```json
"X-Plasma-MainScript": "ui/main.qml"
```

Reason:

Plasma 6 applets conventionally use `main.qml` as the entry point.

Status:

* Experimental
* Appears to be required

## UI

### Added main.qml compatibility alias

Added:

```text
contents/ui/main.qml -> lockout.qml
```

Reason:

Allows Plasma 6 to load the existing Plasma 5 implementation without renaming the original source file.

Status:

* Experimental
* Appears to be required

## Resolved

* Package registration
* Package discovery
* Widget Explorer visibility
* Unsupported Widget warning


## QML

### PlasmaCore.IconItem no longer available

Error:

```text
PlasmaCore.IconItem is not a type
```

Observed while adding the widget to the desktop.

Result:

* Package successfully loaded
* QML execution started
* First Plasma 5 → Plasma 6 API incompatibility identified

Status:

* Not resolved

