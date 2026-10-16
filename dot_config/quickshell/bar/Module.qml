import QtQuick
import qs.common

// A text block on the bar: padding, min width, hover fade and an optional tooltip.
MouseArea {
    id: root

    property string text
    property string tooltip
    property int padLeft: 0
    property int padRight: 0
    property int minWidth: 0
    property int weight: Font.Normal
    property bool clickable: true

    implicitWidth: Math.max(minWidth, label.implicitWidth) + padLeft + padRight
    implicitHeight: parent?.height ?? 32

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: clickable ? Qt.PointingHandCursor : Qt.ArrowCursor

    opacity: containsMouse ? 0.7 : 1
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        x: root.padLeft + (root.width - root.padLeft - root.padRight - width) / 2
        text: root.text
        color: Theme.text
        font.family: Theme.fontIcons
        font.pixelSize: 13
        font.weight: root.weight
    }

    Tooltip {
        target: root
        text: root.tooltip
        hovered: root.containsMouse
    }
}
