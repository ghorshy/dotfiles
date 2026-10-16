import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.common

PanelWindow {
    id: bar

    required property ShellScreen modelData
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:bar"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Theme.shade, 1) }
            GradientStop { position: 0.95; color: Theme.alpha(Theme.shade, 0.4) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.shade, 0) }
        }
    }

    Workspaces {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: Theme.gapsOut
        anchors.verticalCenter: parent.verticalCenter
        monitor: bar.monitor
    }

    WindowTitle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1
        width: Math.min(implicitWidth, bar.width - 2 * Math.max(left.width + 8, right.width) - 200)
        monitor: bar.monitor
    }

    Row {
        id: right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Battery {}
        Tray {
            anchors.verticalCenter: parent.verticalCenter
        }
        NetworkIcon {
            barWindow: bar
        }
        BluetoothIcon {
            barWindow: bar
        }
        Volume {}
        Microphone {
            padRight: 0
        }
        Clock {
            barWindow: bar
        }
    }
}
