import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common

// A popup that opens under a bar icon. It is a layer surface (not an xdg popup) so it can take
// keyboard input, e.g. a Wi-Fi password. The window covers the screen below the bar with a
// transparent click catcher: a click outside the popup closes it, while the bar stays clickable
// (another icon switches popups, the same icon closes it). Escape closes it too.
PanelWindow {
    id: root

    required property string name
    required property Item anchorItem
    required property var barWindow
    property int contentWidth: 300
    readonly property string key: `${name}@${barWindow.screen.name}`
    readonly property bool open: Popups.current === key
    // + PopupRow's 6px inset puts text 10px from the edge, like notification cards
    readonly property int padding: 4
    default property alias content: body.data

    // horizontal center of the icon, in screen coordinates
    property real anchorX: 0

    function toggle(): void {
        Popups.toggle(key);
    }

    visible: open
    screen: barWindow.screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // keep out of the bar's area so it stays clickable
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    // OnDemand, not Exclusive: Hyprland sends no clicks to the bar while an exclusive layer is up
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:popup"

    onOpenChanged: if (open) {
        anchorX = anchorItem.mapToItem(null, anchorItem.width / 2, 0).x;
        surface.forceActiveFocus();
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Popups.close()
    }

    Surface {
        id: surface

        // same distance from the screen edge as windows and notifications
        x: Math.max(Theme.gapsOut, Math.min(root.anchorX - width / 2, root.width - width - Theme.gapsOut))
        y: Theme.gapsOut
        width: root.contentWidth
        height: body.implicitHeight + 2 * root.padding
        focus: true
        Keys.onEscapePressed: Popups.close()

        // swallow clicks on the popup's own background so they don't reach the catcher
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        Column {
            id: body
            x: root.padding
            y: root.padding
            width: parent.width - 2 * root.padding
            spacing: 4
        }
    }
}
