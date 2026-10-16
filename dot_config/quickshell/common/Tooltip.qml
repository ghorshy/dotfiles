import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item target
    property string text
    property bool hovered

    anchor.item: target
    anchor.rect.x: (target.width - width) / 2
    anchor.rect.y: target.height + 4 - Theme.shadowRange

    // room for the Surface shadow on every side
    implicitWidth: label.implicitWidth + 16 + 2 * Theme.shadowRange
    implicitHeight: label.implicitHeight + 10 + 2 * Theme.shadowRange
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

    Surface {
        anchors.fill: parent
        anchors.margins: Theme.shadowRange

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: Theme.text
            font.family: Theme.fontUi
            font.weight: Theme.fontWeight
            font.pointSize: Theme.fontSize
        }
    }
}
