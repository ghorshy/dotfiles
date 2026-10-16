import QtQuick
import Quickshell
import qs.common
import qs.popups

Module {
    id: root

    required property var barWindow
    readonly property bool online: NetState.wired || NetState.wifiNetwork !== null

    padLeft: 6
    padRight: 8
    minWidth: 16
    dim: !online
    text: {
        const icon = NetState.wired ? Icons.ethernet : NetState.wifiNetwork ? Icons.pick(Icons.wifi, NetState.strength(NetState.wifiNetwork)) : Icons.wifiOff;
        return Vpn.active ? `${icon} ${Icons.vpn}` : icon;
    }
    tooltip: {
        const net = NetState.wired ? "Wired" : NetState.wifiNetwork?.name ?? "Not connected";
        return Vpn.active ? `${net}\nVPN: ${Vpn.active.name}` : net;
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["nm-connection-editor"]);
        else
            popup.toggle();
    }

    NetworkPopup {
        id: popup
        anchorItem: root
        barWindow: root.barWindow
    }
}
