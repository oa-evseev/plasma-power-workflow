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

Development platform:

* KDE Plasma 6

## Licence

This project is licensed under the GNU General Public License version 3, or (at your option) any later version.

See the [LICENSE](LICENSE) file for details.

## Origin

This project started as a fork of the KDE Plasma Lock/Logout plasmoid (`org.kde.plasma.lock_logout`).

The original KDE code is distributed under a combination of GPL-2.0-or-later and LGPL-2.0-or-later licences. This repository preserves the original copyright notices and licence information where applicable.

All modifications made specifically for the plasma-power-workflow project are distributed under the GNU General Public License version 3, or (at your option) any later version.

