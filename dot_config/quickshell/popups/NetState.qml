pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// Shared view of the network devices for the bar icon and the network popup.
Singleton {
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    readonly property bool wired: wiredDevice?.connected ?? false
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null

    // 0..1 whatever range the backend reports
    function strength(network: var): real {
        const s = network?.signalStrength ?? 0;
        return s > 1 ? s / 100 : s;
    }
}
