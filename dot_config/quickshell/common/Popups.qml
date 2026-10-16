pragma Singleton

import QtQuick
import Quickshell

// Which bar popup is open. Keys are "<name>@<screen>", so every monitor's bar has its own popups.
Singleton {
    property string current: ""

    function toggle(key: string): void {
        current = current === key ? "" : key;
    }

    function close(): void {
        current = "";
    }
}
