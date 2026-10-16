pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    // Screen of the monitor Hyprland currently has focused.
    readonly property ShellScreen focused: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0] ?? null
}
