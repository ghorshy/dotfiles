import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.common

BarPopup {
    id: popup

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter?.devices.values ?? []
    readonly property var known: devices.filter(d => d.paired || d.bonded)
    readonly property var found: devices.filter(d => !d.paired && !d.bonded && d.name && d.name !== d.address)

    function battery(device: var): string {
        if (!device.batteryAvailable)
            return "";
        const b = device.battery > 1 ? device.battery : device.battery * 100;
        return `${Math.round(b)}%`;
    }

    function status(device: var): string {
        switch (device.state) {
        case BluetoothDeviceState.Connecting:
            return "Connecting…";
        case BluetoothDeviceState.Disconnecting:
            return "Disconnecting…";
        case BluetoothDeviceState.Connected:
            return [battery(device), Icons.check].filter(s => s).join(" ");
        default:
            return device.pairing ? "Pairing…" : "";
        }
    }

    name: "bluetooth"

    // stop scanning once the popup is closed
    onOpenChanged: if (!open && adapter?.discovering)
        adapter.discovering = false

    PopupRow {
        interactive: false
        glyph: popup.adapter?.enabled ? Icons.bluetooth : Icons.bluetoothOff
        label: "Bluetooth"
        active: true

        Toggle {
            checked: popup.adapter?.enabled ?? false
            onToggled: popup.adapter.enabled = !popup.adapter.enabled
        }
    }

    Separator {
        visible: popup.adapter?.enabled ?? false
    }

    SectionLabel {
        visible: (popup.adapter?.enabled ?? false) && popup.known.length > 0
        text: "Devices"
    }

    Repeater {
        model: (popup.adapter?.enabled ?? false) ? popup.known : []

        delegate: PopupRow {
            required property var modelData

            iconSource: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
            glyph: Icons.bluetooth
            label: modelData.name
            active: modelData.connected
            detail: popup.status(modelData)
            onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
        }
    }

    PopupRow {
        visible: popup.adapter?.enabled ?? false
        glyph: Icons.refresh
        label: popup.adapter?.discovering ? "Scanning…" : "Scan for devices"
        dim: popup.adapter?.discovering ?? false
        onClicked: popup.adapter.discovering = !popup.adapter.discovering
    }

    Repeater {
        model: (popup.adapter?.discovering ?? false) ? popup.found : []

        // pairing codes, if a device asks for one, come from blueman running as a hidden agent
        delegate: PopupRow {
            required property var modelData

            iconSource: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
            glyph: Icons.bluetooth
            label: modelData.name
            detail: popup.status(modelData)
            dim: true
            onClicked: {
                modelData.trusted = true;
                modelData.pair();
            }
        }
    }
}
