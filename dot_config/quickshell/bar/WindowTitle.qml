import QtQuick
import Quickshell.Hyprland
import qs.common

Text {
    id: root

    required property HyprlandMonitor monitor
    readonly property HyprlandToplevel window: Hyprland.activeToplevel

    text: window && window.workspace?.monitor === monitor ? window.title : ""
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignHCenter
    color: Theme.text
    font.family: Theme.fontUi
    font.pixelSize: 13
    font.weight: Font.DemiBold
}
