import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.common

Surface {
    id: card

    required property Notification modelData
    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: modelData.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: modelData.actions.filter(a => a.identifier !== "default")
    readonly property string iconSource: {
        if (modelData.image)
            return modelData.image;
        if (modelData.appIcon.startsWith("/"))
            return `file://${modelData.appIcon}`;
        if (modelData.appIcon.includes("://"))
            return modelData.appIcon;
        if (modelData.appIcon)
            return Quickshell.iconPath(modelData.appIcon, true);
        return "";
    }

    width: parent?.width ?? 320
    implicitHeight: content.implicitHeight + 20
    tint: critical ? Theme.urgentBg : Theme.base
    borderTint: critical ? Theme.urgent : Theme.border

    // slide in from the right
    opacity: 0
    transform: Translate {
        id: slide
        x: 24
    }
    Component.onCompleted: appear.start()
    ParallelAnimation {
        id: appear
        NumberAnimation { target: card; property: "opacity"; to: 1; duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
        NumberAnimation { target: slide; property: "x"; to: 0; duration: Theme.animNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.curve }
    }

    Timer {
        // mako: default-timeout=5000, critical stays until dismissed
        interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : 5000
        running: !card.critical && !mouse.containsMouse
        onTriggered: card.modelData.expire()
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.LeftButton && card.defaultAction)
                card.defaultAction.invoke();
            else
                card.modelData.dismiss();
        }
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        IconImage {
            Layout.alignment: Qt.AlignTop
            visible: card.iconSource !== ""
            source: card.iconSource
            implicitSize: 64
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: card.modelData.summary
                color: Theme.text
                font.family: Theme.fontUi
                font.pointSize: Theme.fontSize
                font.weight: Font.Bold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.modelData.body
                textFormat: Text.StyledText
                color: Theme.text
                font.family: Theme.fontUi
                font.pointSize: Theme.fontSize
                wrapMode: Text.Wrap
                maximumLineCount: 6
                elide: Text.ElideRight
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 6
                visible: card.buttons.length > 0
                spacing: 6

                Repeater {
                    model: card.buttons

                    delegate: Rectangle {
                        required property NotificationAction modelData

                        implicitWidth: actionLabel.implicitWidth + 16
                        implicitHeight: actionLabel.implicitHeight + 8
                        radius: Theme.radius
                        color: Theme.alpha(Theme.surface, actionMouse.containsMouse ? 1 : Theme.opacity.muted)

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: parent.modelData.text
                            color: Theme.text
                            font.family: Theme.fontUi
                            font.pointSize: Theme.fontSize - 1
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
