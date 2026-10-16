import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.common
import qs.popups

Module {
    id: root

    required property var barWindow
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connected: adapter?.devices.values.filter(d => d.connected) ?? []

    visible: adapter !== null
    padLeft: 6
    padRight: 8
    minWidth: 16
    dim: !(adapter?.enabled ?? false)
    text: !(adapter?.enabled ?? false) ? Icons.bluetoothOff : connected.length > 0 ? Icons.bluetoothConnected : Icons.bluetooth
    tooltip: {
        if (!(adapter?.enabled ?? false))
            return "Bluetooth off";
        if (connected.length === 0)
            return "Bluetooth on";
        return connected.map(d => [d.name, popup.battery(d)].filter(s => s).join(" ")).join("\n");
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["blueman-manager"]);
        else
            popup.toggle();
    }

    BluetoothPopup {
        id: popup
        anchorItem: root
        barWindow: root.barWindow
    }
}
