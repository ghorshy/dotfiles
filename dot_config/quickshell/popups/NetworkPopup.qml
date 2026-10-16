import QtQuick
import Quickshell
import Quickshell.Networking
import qs.common

BarPopup {
    id: popup

    name: "network"

    // network waiting for a password typed in the popup
    property var passwordFor: null

    onOpenChanged: {
        passwordFor = null;
        if (NetState.wifiDevice)
            NetState.wifiDevice.scannerEnabled = open;
    }

    PopupRow {
        interactive: false
        active: true
        glyph: NetState.wired ? Icons.ethernet : NetState.wifiNetwork ? Icons.pick(Icons.wifi, NetState.strength(NetState.wifiNetwork)) : Icons.wifiOff
        dim: !NetState.wired && !NetState.wifiNetwork
        label: NetState.wired ? "Wired" : NetState.wifiNetwork?.name ?? "Not connected"
        detail: NetState.wired || NetState.wifiNetwork ? "Connected" : ""
    }

    Separator {}

    // Wi-Fi
    PopupRow {
        visible: NetState.wifiDevice !== null
        interactive: false
        glyph: Icons.wifi[3]
        label: "Wi-Fi"

        Toggle {
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Flickable {
        visible: NetState.wifiDevice !== null && Networking.wifiEnabled
        width: parent.width
        height: Math.min(contentHeight, 260)
        contentHeight: networks.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: networks
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: [...(NetState.wifiDevice?.networks.values ?? [])].filter(n => n.name).sort((a, b) => (b.connected - a.connected) || (NetState.strength(b) - NetState.strength(a)))
                }

                delegate: Column {
                    id: entry

                    required property var modelData
                    readonly property bool secured: modelData.security !== WifiSecurityType.Open

                    width: networks.width

                    Connections {
                        target: entry.modelData
                        function onConnectionFailed(reason) {
                            if (reason === ConnectionFailReason.NoSecrets)
                                popup.passwordFor = entry.modelData;
                        }
                    }

                    PopupRow {
                        glyph: Icons.pick(Icons.wifi, NetState.strength(entry.modelData))
                        label: entry.modelData.name
                        active: entry.modelData.connected
                        detail: {
                            if (entry.modelData.stateChanging)
                                return "…";
                            return (entry.modelData.connected ? Icons.check + " " : "") + (entry.secured ? Icons.vpn : "");
                        }

                        onClicked: mouse => {
                            const network = entry.modelData;
                            if (mouse.button === Qt.RightButton) {
                                if (network.known)
                                    network.forget();
                            } else if (network.connected) {
                                network.disconnect();
                            } else if (network.known || !entry.secured) {
                                network.connect();
                            } else {
                                popup.passwordFor = network;
                            }
                        }
                    }

                    // password for a new secured network
                    Rectangle {
                        visible: popup.passwordFor === entry.modelData
                        width: parent.width
                        height: visible ? 30 : 0
                        radius: Theme.radius
                        color: Theme.alpha(Theme.surface, Theme.opacity.muted)
                        border.width: Theme.borderWidth
                        border.color: Theme.border

                        onVisibleChanged: if (visible) {
                            password.text = "";
                            password.forceActiveFocus();
                        }

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: Theme.text
                            selectionColor: Theme.overlay
                            font.family: Theme.fontUi
                            font.weight: Theme.fontWeight
                            font.pointSize: Theme.fontSize
                            onAccepted: {
                                entry.modelData.connectWithPsk(text);
                                popup.passwordFor = null;
                            }
                            Keys.onEscapePressed: popup.passwordFor = null

                            Text {
                                visible: password.text === ""
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Password"
                                color: Theme.textFaint
                                font: password.font
                            }
                        }
                    }
                }
            }
        }
    }

    // VPN
    SectionLabel {
        visible: Vpn.connections.length > 0
        text: "VPN"
    }

    Repeater {
        model: Vpn.connections

        delegate: PopupRow {
            id: vpnRow

            required property var modelData

            glyph: Icons.vpn
            label: modelData.name
            active: modelData.state === "activated"
            detail: modelData.state === "activating" ? "Connecting…" : modelData.state === "deactivating" ? "Disconnecting…" : ""
            onClicked: Vpn.toggle(modelData)

            Toggle {
                checked: vpnRow.modelData.state !== ""
                onToggled: Vpn.toggle(vpnRow.modelData)
            }
        }
    }

    Separator {}

    PopupRow {
        glyph: Icons.settings
        label: "Advanced…"
        onClicked: {
            Popups.close();
            Quickshell.execDetached(["nm-connection-editor"]);
        }
    }
}
