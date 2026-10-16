import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.common

Row {
    id: root

    spacing: 16
    rightPadding: 10
    layoutDirection: Qt.RightToLeft

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: item

            required property SystemTrayItem modelData

            // waybar hides passive items (e.g. udiskie -s with nothing mounted);
            // nm-applet and blueman only run as hidden agents, the bar has its own icons for them
            visible: modelData.status !== Status.Passive && !["nm-applet", "blueman"].includes(modelData.id)
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 16
            implicitHeight: 16
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            opacity: containsMouse ? 0.7 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve
                }
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && !modelData.onlyMenu)
                    modelData.activate();
                else if (mouse.button === Qt.MiddleButton)
                    modelData.secondaryActivate();
                else if (modelData.hasMenu)
                    menu.open();
            }
            onWheel: wheel => modelData.scroll(wheel.angleDelta.y / 120, false)

            IconImage {
                anchors.fill: parent
                source: item.modelData.icon
            }

            QsMenuAnchor {
                id: menu
                menu: item.modelData.menu
                anchor.item: item
                anchor.rect.y: item.height + 8
            }

            Tooltip {
                target: item
                text: item.modelData.tooltipTitle || item.modelData.title
                hovered: item.containsMouse
            }
        }
    }
}
