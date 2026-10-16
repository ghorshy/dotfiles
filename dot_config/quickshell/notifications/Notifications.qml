import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.common

Scope {
    id: root

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true

        onNotification: notification => notification.tracked = true
    }

    PanelWindow {
        screen: Screens.focused
        visible: server.trackedNotifications.values.length > 0
        anchors {
            top: true
            right: true
        }
        margins {
            top: 8
            right: 8
        }
        exclusiveZone: 0
        implicitWidth: 320
        implicitHeight: column.implicitHeight
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:notifications"

        Column {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                // newest on top, like mako's sort=-time
                model: ScriptModel {
                    values: [...server.trackedNotifications.values].reverse()
                }

                delegate: NotificationCard {}
            }
        }
    }
}
