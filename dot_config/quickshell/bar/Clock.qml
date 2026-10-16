import QtQuick
import Quickshell

Module {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    minWidth: 64
    weight: Font.DemiBold
    text: Qt.formatDateTime(clock.date, "HH:mm")
    tooltip: Qt.locale().toString(clock.date, "dddd, d MMMM yyyy")

    onClicked: Quickshell.execDetached(["gnome-calendar"])
}
