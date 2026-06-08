/*
 *  SPDX-FileCopyrightText: 2026 Oleg Evseev <oleg.a.yevseyev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.5 as QtControls
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3

import org.kde.kirigami 2.5 as Kirigami

Kirigami.FormLayout {
    id: workflowPage

    property alias cfg_workflowPollingInterval: pollingInterval.value
    property alias cfg_allowForceDefaultAction: allowForceDefaultAction.checked
    property alias cfg_proceedOnNonCriticalError: proceedOnNonCriticalError.checked
    property alias cfg_nonCriticalErrorDelay: nonCriticalErrorDelay.value

    property string currentConfigKey: ""

    property var workflowEvents: [
        { key: "shutdownScript",  label: i18n("Shutdown") },
        { key: "rebootScript",    label: i18n("Reboot") },
        { key: "logoutScript",    label: i18n("Logout") },
        { key: "lockScript",      label: i18n("Lock") },
        { key: "sleepScript",     label: i18n("Sleep") },
        { key: "hibernateScript", label: i18n("Hibernate") },
        { key: "switchUserScript", label: i18n("Switch User") }
    ]

    ColumnLayout {
        Kirigami.FormData.isSection: true

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 420

        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true

            QtControls.Label {
                text: i18n("Event")
                font.bold: true

                Layout.preferredWidth: 90
            }

            QtControls.Label {
                text: i18n("Script")
                font.bold: true

                Layout.fillWidth: true
            }

            Item {
                Layout.preferredWidth: 100
            }
        }

        Repeater {
            model: workflowEvents

            delegate: RowLayout {
                width: parent.width

                QtControls.Label {
                    text: modelData.label

                    Layout.preferredWidth: 90
                }

                QtControls.TextField {
                    Layout.fillWidth: true

                    text: plasmoid.configuration[modelData.key]

                    placeholderText: i18n("Default KDE behaviour")

                    onTextChanged: {
                        plasmoid.configuration[modelData.key] = text
                    }
                }

                QtControls.Button {
                    text: i18n("Browse...")

                    Layout.preferredWidth: 100

                    onClicked: {
                        currentConfigKey = modelData.key
                        fileDialog.visible = true
                    }
                }
            }
        }

        QtControls.Label {
            text: "Leave a field empty to use the default KDE behaviour."

            horizontalAlignment: Text.AlignHCenter

            Layout.alignment: Qt.AlignHCenter

            Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
        }
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
        id: allowForceDefaultAction

        Kirigami.FormData.label: i18n("Workflow failures:")

        text: i18n("Allow forcing the default KDE action")
    }

    QtControls.CheckBox {
        id: proceedOnNonCriticalError

        enabled: allowForceDefaultAction.checked

        Kirigami.FormData.label: ""

        text: i18n("Proceed automatically after non-critical errors")
    }

    QtControls.SpinBox {
        id: nonCriticalErrorDelay

        enabled:
        allowForceDefaultAction.checked &&
        proceedOnNonCriticalError.checked

        Kirigami.FormData.label: i18n("Auto-proceed delay (s):")

        from: 1
        to: 600

        editable: true
    }

    FileDialog {
        id: fileDialog

        visible: false

        title: i18n("Choose workflow script")

        selectMultiple: false

        onAccepted: {
            if (fileUrls.length > 0 && currentConfigKey !== "") {
                plasmoid.configuration[currentConfigKey] =
                fileUrls[0].toString().replace("file://", "")
            }
        }
    }
}
