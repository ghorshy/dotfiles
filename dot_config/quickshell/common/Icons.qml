pragma Singleton

import QtQuick
import Quickshell

// Nerd Font glyphs, same as the old waybar / rofi configs.
Singleton {
    readonly property var battery: [0xF008E, 0xF007A, 0xF007B, 0xF007C, 0xF007D, 0xF007E, 0xF007F, 0xF0080, 0xF0081, 0xF0082, 0xF0079].map(c => String.fromCodePoint(c))
    readonly property string plug: String.fromCodePoint(0xF1E6)

    readonly property var volume: [0xF026, 0xF027, 0xF028].map(c => String.fromCodePoint(c))
    readonly property string volumeMuted: String.fromCodePoint(0xF075F)
    readonly property string mic: String.fromCodePoint(0xF130)
    readonly property string micMuted: String.fromCodePoint(0xF131)
    readonly property string brightness: String.fromCodePoint(0xF00E0)

    readonly property var wifi: [0xF091F, 0xF0922, 0xF0925, 0xF0928].map(c => String.fromCodePoint(c))
    readonly property string wifiOff: String.fromCodePoint(0xF092F)
    readonly property string ethernet: String.fromCodePoint(0xF0200)
    readonly property string vpn: String.fromCodePoint(0xF033E)
    // Material Design set, like the Wi-Fi glyphs: the Font Awesome rune was much smaller
    readonly property string bluetooth: String.fromCodePoint(0xF00AF)
    readonly property string bluetoothOff: String.fromCodePoint(0xF00B2)
    readonly property string bluetoothConnected: String.fromCodePoint(0xF00B1)
    readonly property string batteryAlert: String.fromCodePoint(0xF0083)
    readonly property string chevronLeft: String.fromCodePoint(0xF0141)
    readonly property string chevronRight: String.fromCodePoint(0xF0142)
    readonly property string check: String.fromCodePoint(0xF012C)
    readonly property string refresh: String.fromCodePoint(0xF0450)
    readonly property string settings: String.fromCodePoint(0xF0493)

    readonly property string lock: String.fromCodePoint(0xF023)
    readonly property string suspend: String.fromCodePoint(0xF03E4)
    readonly property string logout: String.fromCodePoint(0xF05FD)
    readonly property string reboot: String.fromCodePoint(0xF01E)
    readonly property string shutdown: String.fromCodePoint(0xF011)
    readonly property string yes: String.fromCodePoint(0xF0E1E)
    readonly property string no: String.fromCodePoint(0xF00D)

    // Pick an icon from a list the same way waybar's format-icons does.
    function pick(list: var, fraction: real): string {
        const i = Math.floor(Math.max(0, Math.min(1, fraction)) * 100 * list.length / 101);
        return list[Math.min(list.length - 1, i)];
    }
}
