import QtQuick
import Quickshell.Widgets
import qs.common

// One clickable line in a popup: glyph or icon, label, optional detail and trailing items.
MouseArea {
    id: row

    property string glyph
    property string iconSource
    property string label
    property string detail
    property bool active
    property bool dim
    property bool interactive: true
    default property alias trailing: trail.data

    width: parent?.width ?? 0
    implicitHeight: 30
    hoverEnabled: interactive
    acceptedButtons: interactive ? Qt.LeftButton | Qt.RightButton : Qt.NoButton
    cursorShape: interactive ? Qt.PointingHandCursor : Qt.ArrowCursor

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: row.containsMouse ? Theme.alpha(Theme.surface, Theme.opacity.hover) : "transparent"
    }

    Item {
        id: lead
        x: 6
        width: 20
        height: parent.height

        Text {
            visible: row.iconSource === ""
            anchors.centerIn: parent
            text: row.glyph
            color: row.dim ? Theme.textFaint : Theme.text
            font.family: Theme.fontIcons
            font.weight: Theme.fontWeight
            font.styleName: "Medium"
            font.pointSize: Theme.fontSize + 1
        }

        IconImage {
            visible: row.iconSource !== ""
            anchors.centerIn: parent
            implicitSize: 16
            source: row.iconSource
        }
    }

    Text {
        anchors.left: lead.right
        anchors.leftMargin: 6
        anchors.right: detailText.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: row.label
        elide: Text.ElideRight
        color: row.dim ? Theme.textFaint : Theme.text
        font.family: Theme.fontUi
        font.pointSize: Theme.fontSize
        font.weight: row.active ? Font.DemiBold : Theme.fontWeight
    }

    Text {
        id: detailText
        anchors.right: trail.left
        anchors.rightMargin: trail.width > 0 ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        text: row.detail
        color: Theme.textFaint
        font.family: Theme.fontUi // icons fall back to Theme.fontIcons
        font.weight: Theme.fontWeight
        font.pointSize: Theme.fontSize
    }

    Row {
        id: trail
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
    }
}
