import QtQuick
import qs.common

// On/off switch, monochrome like the rest of the theme.
MouseArea {
    id: root

    property bool checked
    signal toggled

    implicitWidth: 32
    implicitHeight: 18
    cursorShape: Qt.PointingHandCursor
    onClicked: toggled()

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.text : Theme.surface
        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Rectangle {
            width: parent.height - 4
            height: width
            radius: width / 2
            y: 2
            x: root.checked ? parent.width - width - 2 : 2
            color: root.checked ? Theme.base : Theme.textDim
            Behavior on x {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve
                }
            }
        }
    }
}
