/*
 *  SPDX-FileCopyrightText: 2026 Oleg Evseev <oleg.a.yevseyev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */


import QtQuick 2.0
import QtQuick.Controls 2.5 as QtControls
import QtQuick.Window 2.2

Window {
    id: root
    signal cancelRequested()

    property string workflowName: ""
    property string stepName: ""

    property int stepCurrent: 0
    property int stepTotal: 0

    property int stepPercent: 0
    property int workflowPercent: 0
    property bool workflowPolling: false

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visible: false

    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            showFullScreen()
            raise()
            requestActivate()
        }
    }

    Timer {
        id: workflowPoller

        repeat: true

        interval: plasmoid.configuration.workflowPollingInterval

        running: lockout.workflowPolling

        onTriggered: {
            pollWorkflow()
        }
    }

    function pollWorkflow() {
        if (!workflowId) {
            return
        }

        executable.connectSource(
            getWorkflowScript() +
            " status " +
            workflowId
        )
    }

    Rectangle {
        anchors.fill: parent
        color: "#60000000"

        Rectangle {
            width: 500
            height: 350

            anchors.centerIn: parent

            radius: 10

            color: "#202020"

            Column {
                anchors.fill: parent

                anchors.margins: 20

                spacing: 12

                Text {
                    id: workflowNameLabel

                    text: root.workflowName

                    color: "white"

                    font.pixelSize: 22

                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: stepNameLabel

                    text: root.stepName

                    color: "white"

                    font.pixelSize: 16

                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item { width: 1; height: 10 }

                Text {
                    text: "Overall progress"

                    color: "white"
                }

                Row {
                    width: parent.width

                    spacing: 10

                    QtControls.ProgressBar {
                        width: parent.width * 0.9

                        value: root.workflowPercent / 100.0
                    }

                    Text {
                        width: parent.width * 0.1 - 10

                        text: root.workflowPercent + "%"

                        color: "white"

                        verticalAlignment: Text.AlignVCenter

                        horizontalAlignment: Text.AlignRight
                    }
                }

                Item { width: 1; height: 10 }

                Text {
                    text: "Current step progress (step " + root.stepCurrent + " of " + root.stepTotal + "):"

                    color: "white"
                }

                Row {
                    width: parent.width

                    spacing: 10

                    QtControls.ProgressBar {
                        width: parent.width * 0.9

                        value: root.stepPercent / 100.0
                    }

                    Text {
                        width: parent.width * 0.1 - 10

                        text: root.stepPercent + "%"

                        color: "white"

                        verticalAlignment: Text.AlignVCenter

                        horizontalAlignment: Text.AlignRight
                    }
                }

                Item {
                    width: 1
                    height: 10
                }

                QtControls.Button {
                    text: "Cancel"

                    anchors.horizontalCenter: parent.horizontalCenter

                    onClicked: {
                        root.visible = false
                        root.cancelRequested()
                    }
                }
            }
        }
    }
}
