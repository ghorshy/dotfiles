# Desktop shell

The Hyprland desktop built from these dotfiles: the Quickshell shell (bar, popups,
notifications) and the background helpers it relies on.

## Language

**Bar**:
The strip along the top edge of every monitor with workspaces, window title and status icons.
_Avoid_: Panel, waybar

**Popup**:
A small window that opens under a bar icon and belongs to it (network, Bluetooth, calendar).
Only one is open at a time.
_Avoid_: Panel, dropdown, quick settings

**Agent**:
A background helper with no visible tray icon that a system service calls when it needs the
user: NetworkManager for passwords and VPN logins, BlueZ for pairing codes.
_Avoid_: Applet, tray app

**OSD**:
The short-lived indicator at the bottom of the screen shown when volume, microphone or
brightness changes.
_Avoid_: Popup, overlay
