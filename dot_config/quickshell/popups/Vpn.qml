pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// NetworkManager VPN connections through nmcli (Quickshell's Networking has no VPN support).
// Logins (e.g. openconnect) are handled by nm-applet running as a hidden agent.
Singleton {
    id: root

    // [{ name, uuid, state }], state is "", "activating", "activated" or "deactivating"
    property var connections: []
    readonly property var active: connections.find(c => c.state === "activated") ?? null

    function toggle(connection: var): void {
        const action = connection.state === "" ? "up" : "down";
        Quickshell.execDetached(["nmcli", "connection", action, "uuid", connection.uuid]);
    }

    // nmcli -t escapes ':' inside values as '\:'
    function fields(line: string): list<string> {
        return line.replace(/\\:/g, "\u0000").split(":").map(f => f.replace(/\u0000/g, ":"));
    }

    Process {
        id: list
        command: ["sh", "-c", "nmcli -t -f NAME,UUID,TYPE connection show; echo ---; nmcli -t -f UUID,STATE connection show --active"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [all, active] = text.split("---\n");
                const states = {};
                for (const line of (active ?? "").split("\n").filter(l => l)) {
                    const [uuid, state] = root.fields(line);
                    states[uuid] = state;
                }
                root.connections = all.split("\n").filter(l => l).map(root.fields)
                    .filter(([, , type]) => type === "vpn" || type === "wireguard")
                    .map(([name, uuid]) => ({ name, uuid, state: states[uuid] ?? "" }));
            }
        }
    }

    // any NetworkManager change -> refresh (debounced)
    Process {
        id: monitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: refresh.restart()
        }
        onExited: restartMonitor.start()
    }

    Timer {
        id: restartMonitor
        interval: 2000
        onTriggered: monitor.running = true
    }

    Timer {
        id: refresh
        interval: 300
        onTriggered: list.running = true
    }

    Component.onCompleted: list.running = true
}
