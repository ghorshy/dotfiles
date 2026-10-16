import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Low battery notifications: once at 15%, critical (stays until plugged in) at 5%.
// Both reset when the charger is connected. Nothing happens without a laptop battery.
Scope {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property int percent: Math.round(device.percentage * 100)
    readonly property bool onAc: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.FullyCharged || device.state === UPowerDeviceState.PendingCharge
    property int level: 0 // 0 none, 1 low sent, 2 critical sent
    property string criticalId: ""

    function check(): void {
        if (!device.ready || !device.isLaptopBattery)
            return;
        if (onAc) {
            level = 0;
            if (criticalId !== "") {
                Quickshell.execDetached(["gdbus", "call", "--session", "--dest", "org.freedesktop.Notifications", "--object-path", "/org/freedesktop/Notifications", "--method", "org.freedesktop.Notifications.CloseNotification", criticalId]);
                criticalId = "";
            }
        } else if (percent <= 5 && level < 2) {
            level = 2;
            critical.running = true;
        } else if (percent <= 15 && level < 1) {
            level = 1;
            Quickshell.execDetached(["notify-send", "-a", "Battery", "-i", "battery-low", "Battery low", `${percent}% left`]);
        }
    }

    onPercentChanged: check()
    onOnAcChanged: check()
    Component.onCompleted: check()

    Process {
        id: critical
        command: ["notify-send", "-p", "-a", "Battery", "-u", "critical", "-i", "battery-caution", "Battery critical", `${root.percent}% left, plug in the charger`]
        stdout: StdioCollector {
            onStreamFinished: root.criticalId = text.trim()
        }
    }
}
