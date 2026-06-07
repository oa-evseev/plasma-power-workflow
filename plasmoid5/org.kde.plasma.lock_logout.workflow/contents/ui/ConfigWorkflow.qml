/*
 *  SPDX-FileCopyrightText: 2026 Oleg Evseev <oleg.a.yevseyev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.5 as QtControls
import org.kde.kirigami 2.5 as Kirigami

Kirigami.FormLayout {
    id: workflowPage

    anchors.left: parent.left
    anchors.right: parent.right

    property alias cfg_workflowScript: workflowScript.text
    property alias cfg_workflowPollingInterval: pollingInterval.value
    property alias cfg_proceedOnError: proceedOnError.checked

    QtControls.TextField {
        id: workflowScript

        Kirigami.FormData.label: i18n("Workflow script:")

        placeholderText: i18n("builtin or /path/to/workflow.sh")
    }

    QtControls.Label {
        text: i18n(
            "'builtin' uses the bundled demonstration workflow."
        )

        wrapMode: Text.WordWrap
    }

    QtControls.SpinBox {
        id: pollingInterval

        Kirigami.FormData.label: i18n("Polling interval (ms):")

        from: 100
        to: 10000
        stepSize: 100

        editable: true
    }

    QtControls.CheckBox {
        id: proceedOnError

        Kirigami.FormData.label: i18n("Error handling:")

        text: i18n("Proceed on non-critical workflow errors")
    }

}
