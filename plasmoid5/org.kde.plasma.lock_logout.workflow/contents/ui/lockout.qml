/*
 *  SPDX-FileCopyrightText: 2011 Viranch Mehta <viranch.mehta@gmail.com>
 *  SPDX-FileCopyrightText: 2026 Oleg Evseev <oleg.a.yevseyev@gmail.com>
 *
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.5 as QtControls
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import "data.js" as Data
import org.kde.plasma.private.sessions 2.0

Flow {
    id: lockout

    property bool workflowRunning: false
    property bool workflowPolling: false

    property string workflowId: ""
    property string workflowState: ""
    property string workflowName: ""
    property string stepName: ""

    property int stepCurrent: 0
    property int stepTotal: 0
    property int stepPercent: 0
    property int workflowPercent: 0

    property string onErrorPolicy: "terminate"
    property string pendingOperation: ""
    property string pendingActionName: ""

    property bool forceCountdownRunning: false
    property int forceCountdownSeconds: 0

    property string startCommand: ""
    property string statusCommand: ""
    property string cancelCommand: ""

    property string pendingScript: ""

    Layout.minimumWidth: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return 0
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return height < minButtonSize * visibleButtons ? height * visibleButtons : height / visibleButtons - 1
        } else {
            return width > height ? minButtonSize * visibleButtons : minButtonSize
        }
    }

    Layout.minimumHeight: {
        if (plasmoid.formFactor === PlasmaCore.Types.Vertical) {
            return width >= minButtonSize * visibleButtons ? width / visibleButtons - 1 : width * visibleButtons
        } else if (plasmoid.formFactor === PlasmaCore.Types.Horizontal) {
            return 0
        } else {
            return width > height ? minButtonSize : minButtonSize * visibleButtons
        }
    }

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    readonly property int minButtonSize: PlasmaCore.Units.iconSizes.small

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    readonly property int visibleButtons: {
        var count = 0

        for (var i = 0, j = items.count; i < j; ++i) {
            if (items.itemAt(i).visible) {
                ++count
            }
        }

        return count
    }

    flow: {
        if ((plasmoid.formFactor === PlasmaCore.Types.Vertical && width >= minButtonSize * visibleButtons) ||
            (plasmoid.formFactor === PlasmaCore.Types.Horizontal && height < minButtonSize * visibleButtons) ||
            (width > height)) {
            return Flow.LeftToRight
            } else {
                return Flow.TopToBottom
            }
    }

    SessionManagement {
        id: session
    }

    PlasmaCore.DataSource {
        id: executable

        engine: "executable"

        connectedSources: []

        onNewData: {
            executable.disconnectSource(sourceName)

            if (sourceName === lockout.startCommand) {
                handleWorkflowStartResult(data)
                return
            }

            if (sourceName === lockout.statusCommand) {
                handleWorkflowStatusResult(data)
                return
            }

            if (sourceName === lockout.cancelCommand) {
                handleWorkflowCancelResult(data)
                return
            }

            print("Unknown executable result:", sourceName)
            print(JSON.stringify(data))
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

    Timer {
        id: forceTimer

        interval: 1000

        repeat: true

        onTriggered: {
            lockout.forceCountdownSeconds--

            if (lockout.forceCountdownSeconds <= 0) {
                stop()

                workflowWindow.visible = false
                lockout.workflowRunning = false

                session[lockout.pendingOperation]()
            } else {
                updateForceButton()
            }
        }
    }

    WorkflowDialog {
        id: workflowWindow

        workflowName: lockout.workflowName
        stepName: lockout.stepName

        stepCurrent: lockout.stepCurrent
        stepTotal: lockout.stepTotal

        stepPercent: lockout.stepPercent
        workflowPercent: lockout.workflowPercent

        onCancelRequested: {
            cancelWorkflow()
        }
        onForceRequested: {
            forceTimer.stop()

                workflowWindow.visible = false
                lockout.workflowRunning = false

                session[lockout.pendingOperation]()
        }
    }

    Repeater {
        id: items

        property int itemWidth: parent.flow === Flow.LeftToRight ? Math.floor(parent.width / visibleButtons) : parent.width
        property int itemHeight: parent.flow === Flow.TopToBottom ? Math.floor(parent.height / visibleButtons) : parent.height
        property int iconSize: Math.min(itemWidth, itemHeight)

        model: Data.data

        delegate: Item {
            id: iconDelegate

            visible: plasmoid.configuration["show_" + modelData.configKey] &&
            (!modelData.hasOwnProperty("requires") || session["can" + modelData.requires])

            width: items.itemWidth
            height: items.itemHeight

            PlasmaCore.IconItem {
                id: iconButton

                width: items.iconSize
                height: items.iconSize

                anchors.centerIn: parent

                source: modelData.icon
                scale: mouseArea.pressed ? 0.9 : 1
                active: mouseArea.containsMouse

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    onReleased: {
                        clickHandler(modelData.operation, this)
                    }

                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent

                        mainText: modelData.tooltip_mainText
                        subText: modelData.tooltip_subText
                    }
                }
            }
        }
    }

    function clickHandler(what, button) {
        performOperation(what)
    }

    function getWorkflowScript(operation) {
        switch (operation) {
            case "lock":
                return plasmoid.configuration.lockScript

            case "switchUser":
                return plasmoid.configuration.switchUserScript

            case "requestShutdown":
                return plasmoid.configuration.shutdownScript

            case "requestReboot":
                return plasmoid.configuration.rebootScript

            case "requestLogout":
                return plasmoid.configuration.logoutScript

            case "suspend":
                return plasmoid.configuration.sleepScript

            case "hibernate":
                return plasmoid.configuration.hibernateScript

            default:
                return ""
        }
    }

    function workflowAction(operation) {
        switch (operation) {
            case "lock":
                return "lock"

            case "switchUser":
                return "switch-user"

            case "requestShutdown":
                return "shutdown"

            case "requestReboot":
                return "reboot"

            case "requestLogout":
                return "logout"

            case "suspend":
                return "sleep"

            case "hibernate":
                return "hibernate"

            default:
                return ""
        }
    }

    function resetWorkflowState(operation, action) {

        workflowWindow.showForceButton = false
        workflowWindow.forceButtonText = ""

        lockout.workflowRunning = true
        lockout.workflowPolling = false

        lockout.workflowId = ""
        lockout.workflowState = "starting"

        lockout.workflowName = "Starting workflow"
        lockout.stepName = "Starting workflow script..."

        lockout.stepCurrent = 0
        lockout.stepTotal = 0

        lockout.stepPercent = 0
        lockout.workflowPercent = 0

        lockout.onErrorPolicy = "terminate"

        lockout.pendingOperation = operation
        lockout.pendingActionName = action

        lockout.pendingScript = getWorkflowScript(operation)
    }

    function performOperation(operation) {
        var workflowScript = getWorkflowScript(operation)

        print(
            "Power Workflow:",
            operation,
            "workflowScript=",
            workflowScript
        )

        if (!workflowScript || workflowScript === "") {
            session[operation]()
            return
        }

        var action = workflowAction(operation)

        if (action === "") {
            print("Unknown workflow operation:", operation)
            return
        }

        resetWorkflowState(operation, action)

        workflowWindow.showFullScreen()
        workflowWindow.raise()
        workflowWindow.requestActivate()

        startWorkflow(action)

        print("Workflow interception active")
    }

    function startWorkflow(action) {
        lockout.startCommand =
        lockout.pendingScript +
        " start " +
        action

        executable.connectSource(lockout.startCommand)
    }

    function startWorkflowPolling(id) {
        lockout.workflowId = id
        lockout.workflowPolling = true

        workflowPoller.restart()
        pollWorkflow()
    }

    function stopWorkflowPolling() {
        lockout.workflowPolling = false
        workflowPoller.stop()
    }

    function pollWorkflow() {
        if (!lockout.workflowId) {
            return
        }

        lockout.statusCommand =
        lockout.pendingScript +
        " status " +
        lockout.workflowId

        executable.connectSource(lockout.statusCommand)
    }

    function cancelWorkflow() {
        stopWorkflowPolling()

        forceTimer.stop()

        if (lockout.workflowId !== "") {
            lockout.cancelCommand =
            lockout.pendingScript +
            " cancel " +
            lockout.workflowId

            executable.connectSource(lockout.cancelCommand)
        }

        lockout.workflowRunning = false
        workflowWindow.visible = false
    }

    function parseWorkflowJson(data, context) {
        if (data["exit code"] !== 0) {
            print("Workflow command failed:", context)
            print(JSON.stringify(data))
            return null
        }

        var stdout = String(data.stdout).trim()

        if (stdout === "") {
            print("Empty workflow response:", context)
            return null
        }

        try {
            return JSON.parse(stdout)
        } catch (e) {
            lockout.workflowState = "error"

            lockout.workflowName = "Workflow failed"

            lockout.stepName =
            "Invalid JSON returned by workflow"

            workflowWindow.errorMessage =
            lockout.stepName

            workflowWindow.showForceButton =
            plasmoid.configuration.allowForceDefaultAction

            finishWorkflowError({
                message: "Invalid JSON returned by workflow"
            })

            return null
        }
    }

    function handleWorkflowStartResult(data) {
        var result = parseWorkflowJson(data, "start")

        if (!result) {
            lockout.workflowName = "Workflow start failed"
            lockout.stepName = "Could not start workflow script"
            lockout.workflowState = "error"
            return
        }

        lockout.workflowId = result.id || ""
        lockout.onErrorPolicy = result.on_error || "terminate"

        if (lockout.workflowId === "") {
            lockout.workflowName = "Workflow start failed"
            lockout.stepName = "Workflow did not return an ID"
            lockout.workflowState = "error"
            return
        }

        lockout.workflowName = result.workflow_name || "Workflow"
        lockout.stepName = result.step_name || "Workflow started"

        startWorkflowPolling(lockout.workflowId)
    }

    function handleWorkflowStatusResult(data) {
        var status = parseWorkflowJson(data, "status")

        if (!status) {
            return
        }

        applyWorkflowStatus(status)

        if (lockout.workflowState === "running") {
            return
        }

        stopWorkflowPolling()

        if (lockout.workflowState === "success") {
            finishWorkflowSuccess()
            return
        }

        if (lockout.workflowState === "error") {
            finishWorkflowError(status)
            return
        }

        if (lockout.workflowState === "cancelled") {
            finishWorkflowCancelled()
            return
        }
    }

    function handleWorkflowCancelResult(data) {
        var result = parseWorkflowJson(data, "cancel")

        if (result) {
            print("Workflow cancelled:", JSON.stringify(result))
        }
    }

    function applyWorkflowStatus(status) {
        lockout.workflowState = status.state || "running"
        lockout.onErrorPolicy = status.on_error || lockout.onErrorPolicy

        lockout.workflowName = status.workflow_name || lockout.workflowName || "Workflow"
        lockout.stepName = status.step_name || status.message || lockout.stepName || ""

        lockout.stepCurrent = numberOrDefault(status.step_current, lockout.stepCurrent)
        lockout.stepTotal = numberOrDefault(status.step_total, lockout.stepTotal)

        lockout.stepPercent = clampPercent(
            numberOrDefault(status.step_percent, lockout.stepPercent)
        )

        if (status.workflow_percent !== undefined) {
            lockout.workflowPercent = clampPercent(Number(status.workflow_percent))
        } else {
            lockout.workflowPercent = estimateWorkflowPercent()
        }
    }

    function numberOrDefault(value, fallback) {
        if (value === undefined || value === null || value === "") {
            return fallback
        }

        var number = Number(value)

        if (isNaN(number)) {
            return fallback
        }

        return number
    }

    function clampPercent(value) {
        if (isNaN(value)) {
            return 0
        }

        if (value < 0) {
            return 0
        }

        if (value > 100) {
            return 100
        }

        return Math.round(value)
    }

    function estimateWorkflowPercent() {
        if (lockout.stepTotal <= 0 || lockout.stepCurrent <= 0) {
            return lockout.workflowPercent
        }

        var completedSteps = lockout.stepCurrent - 1
        var currentStepPart = lockout.stepPercent / 100.0
        var percent = ((completedSteps + currentStepPart) / lockout.stepTotal) * 100.0

        return clampPercent(percent)
    }

    function finishWorkflowSuccess() {
        forceTimer.stop()

        workflowWindow.showForceButton = false
        workflowWindow.errorMessage = ""

        lockout.workflowName = "Workflow completed"
        lockout.stepName = "Workflow completed successfully"

        lockout.workflowPercent = 100
        lockout.stepPercent = 100

        lockout.workflowRunning = false
        workflowWindow.visible = false

        print("Workflow success:", lockout.pendingOperation)

        session[lockout.pendingOperation]()
    }

    function finishWorkflowError(status) {
        lockout.workflowName = "Workflow failed"
        lockout.stepName = status.message || "Workflow failed"

        print("Workflow error:", lockout.onErrorPolicy, lockout.stepName)

        workflowWindow.errorMessage = lockout.stepName

        if (
            lockout.onErrorPolicy === "proceed" &&
            plasmoid.configuration.proceedOnNonCriticalError &&
            plasmoid.configuration.allowForceDefaultAction
        ) {

            workflowWindow.showForceButton = true

            lockout.forceCountdownSeconds =
            plasmoid.configuration.nonCriticalErrorDelay

            updateForceButton()

            forceTimer.start()

                return
        }

        forceTimer.stop()

        workflowWindow.showForceButton =
        plasmoid.configuration.allowForceDefaultAction

        if (plasmoid.configuration.allowForceDefaultAction) {
            workflowWindow.forceButtonText =
            "Force " + lockout.pendingActionName
        }
    }

    function finishWorkflowCancelled() {
        forceTimer.stop()

        workflowWindow.showForceButton = false
        workflowWindow.errorMessage = ""

        lockout.workflowName = "Workflow cancelled"
        lockout.stepName = "Workflow was cancelled"

        workflowWindow.showForceButton = false

        lockout.workflowRunning = false
    }

    function updateForceButton() {
        workflowWindow.forceButtonText =
        "Force " +
        lockout.pendingActionName +
        " (" +
        lockout.forceCountdownSeconds +
        ")"
    }
}
