import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item target
    property string text
    property bool hovered

    anchor.item: target
    anchor.rect.x: (target.width - width) / 2
    anchor.rect.y: target.height + 4

    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 10
    visible: delay.ready && hovered && text !== ""
    color: "transparent"

    onHoveredChanged: {
        delay.ready = false;
        if (hovered)
            delay.restart();
    }

    Timer {
        id: delay
        property bool ready: false
        interval: 400
        onTriggered: ready = true
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.alpha(Theme.base, 0.8)

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: Theme.text
            font.family: Theme.fontUi
            font.pixelSize: 13
        }
    }
}
