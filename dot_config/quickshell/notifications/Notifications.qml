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
        // leave room for the card shadow, cards sit gapsOut px from the edges like windows
        margins {
            top: Theme.gapsOut - Theme.shadowRange
            right: Theme.gapsOut - Theme.shadowRange
        }
        exclusiveZone: 0
        implicitWidth: 320 + 2 * Theme.shadowRange
        implicitHeight: column.implicitHeight + 2 * Theme.shadowRange
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:notifications"

        Column {
            id: column
            x: Theme.shadowRange
            y: Theme.shadowRange
            width: parent.width - 2 * Theme.shadowRange
            spacing: 10

            Repeater {
                // newest on top
                model: ScriptModel {
                    values: [...server.trackedNotifications.values].reverse()
                }

                delegate: NotificationCard {}
            }
        }
    }
}
