import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common

// Replacement for ~/.config/rofi/scripts/powermenu.sh, toggled with `qs ipc call powermenu toggle`.
Scope {
    id: root

    readonly property var actions: [
        { icon: Icons.lock, confirm: false, command: "loginctl lock-session" },
        { icon: Icons.suspend, confirm: true, command: "playerctl -a pause; loginctl lock-session; sleep 0.5; systemctl suspend" },
        { icon: Icons.logout, confirm: true, command: "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'" },
        { icon: Icons.reboot, confirm: true, command: "systemctl reboot" },
        { icon: Icons.shutdown, confirm: true, command: "systemctl poweroff" }
    ]

    property bool open: false
    property var pending: null

    function close(): void {
        open = false;
        pending = null;
    }

    function choose(action: var): void {
        if (action.confirm && pending !== action) {
            pending = action;
            return;
        }
        close();
        Quickshell.execDetached(["sh", "-c", action.command]);
    }

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            if (root.open)
                root.close();
            else
                root.open = true;
        }
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            screen: Screens.focused
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:powermenu"

            // click outside closes, like rofi's -click-to-exit
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            Column {
                id: menu

                property int current: 0
                readonly property var options: root.pending ? [
                    { icon: Icons.yes, run: () => root.choose(root.pending) },
                    { icon: Icons.no, run: () => root.close() }
                ] : root.actions.map(a => ({ icon: a.icon, run: () => root.choose(a) }))

                anchors.centerIn: parent
                width: root.pending ? 200 : 500
                spacing: 0
                focus: true

                onOptionsChanged: current = 0

                Keys.onPressed: event => {
                    switch (event.key) {
                    case Qt.Key_Escape:
                        root.close();
                        break;
                    case Qt.Key_Left:
                    case Qt.Key_Backtab:
                        current = (current + options.length - 1) % options.length;
                        break;
                    case Qt.Key_Right:
                    case Qt.Key_Tab:
                        current = (current + 1) % options.length;
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                    case Qt.Key_Space:
                        options[current].run();
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                Text {
                    visible: root.pending !== null
                    width: parent.width
                    padding: 8
                    horizontalAlignment: Text.AlignHCenter
                    text: "Are you sure?"
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pointSize: Theme.fontSize
                }

                Row {
                    spacing: 4

                    Repeater {
                        model: menu.options

                        delegate: Surface {
                            id: button

                            required property var modelData
                            required property int index
                            readonly property bool selected: menu.current === index

                            width: (menu.width - (menu.options.length - 1) * 4) / menu.options.length
                            height: glyph.implicitHeight + 50
                            // opaque like the old rofi power menu
                            level: 1
                            borderTint: selected ? Theme.borderActive : Theme.border

                            Text {
                                id: glyph
                                anchors.centerIn: parent
                                text: button.modelData.icon
                                color: Theme.text
                                font.family: Theme.fontIcons
                                font.pointSize: 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: menu.current = button.index
                                onClicked: button.modelData.run()
                            }
                        }
                    }
                }
            }
        }
    }
}
