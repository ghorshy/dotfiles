import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common

Row {
    id: root

    required property HyprlandMonitor monitor

    spacing: 3

    Repeater {
        model: ScriptModel {
            values: Hyprland.workspaces.values.filter(w => w.id > 0 && w.monitor === root.monitor)
        }

        delegate: Rectangle {
            id: button

            required property HyprlandWorkspace modelData
            readonly property bool isActive: root.monitor?.activeWorkspace === modelData

            anchors.verticalCenter: parent.verticalCenter
            // GTK button min-width (16) + waybar padding (0 5px)
            implicitWidth: Math.max(16, label.implicitWidth) + 10
            implicitHeight: 24
            radius: Theme.radius
            color: {
                if (isActive)
                    return Theme.alpha(Theme.surface, hover.hovered ? 1 : Theme.opacity.active);
                return hover.hovered ? Theme.alpha(Theme.surface, Theme.opacity.hover) : "transparent";
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve
                }
            }

            // waybar's "pulse" animation for urgent workspaces
            Rectangle {
                id: pulse
                anchors.fill: parent
                radius: parent.radius
                color: Theme.textDim
                opacity: 0

                SequentialAnimation on opacity {
                    running: button.modelData.urgent
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) pulse.opacity = 0
                    PauseAnimation { duration: 400 }
                    NumberAnimation { to: Theme.opacity.muted; duration: 400 }
                    NumberAnimation { to: 0; duration: 1000 }
                    PauseAnimation { duration: 200 }
                }
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: button.modelData.name
                color: button.isActive ? Theme.text : Theme.textDim
                font.family: Theme.fontUi
                font.pointSize: Theme.fontSize
                font.weight: button.isActive ? Font.ExtraBold : Font.Normal
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${button.modelData.id} })`)
            }
        }
    }
}
