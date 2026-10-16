import QtQuick
import Quickshell.Services.UPower
import qs.common

Module {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property int percent: Math.round(device.percentage * 100)
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool plugged: device.state === UPowerDeviceState.FullyCharged || device.state === UPowerDeviceState.PendingCharge
    readonly property real secondsLeft: charging ? device.timeToFull : device.timeToEmpty
    property bool showTime: false

    function formatTime(seconds: real): string {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor(seconds % 3600 / 60);
        return `${h} h ${m} min`;
    }

    visible: device.ready && device.isLaptopBattery
    clickable: false
    padRight: 12
    weight: Font.Medium

    text: {
        const icon = Icons.pick(Icons.battery, device.percentage);
        if (charging || plugged)
            return `${Icons.plug} ${percent}%`;
        if (showTime && secondsLeft > 0)
            return `${formatTime(secondsLeft)} ${icon} `;
        return `${percent}%  ${icon} `;
    }
    tooltip: secondsLeft > 0 ? `${formatTime(secondsLeft)} ${charging ? "do pełna" : "pozostało"}` : ""

    onClicked: showTime = !showTime
}
