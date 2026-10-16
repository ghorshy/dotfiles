import QtQuick
import Quickshell
import qs.popups

Module {
    id: root

    required property var barWindow

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    minWidth: 64
    weight: Font.DemiBold
    text: Qt.formatDateTime(clock.date, "HH:mm")
    tooltip: calendar.open ? "" : Qt.locale().toString(clock.date, "dddd, d MMMM yyyy")

    onClicked: calendar.toggle()

    CalendarPopup {
        id: calendar
        anchorItem: root
        barWindow: root.barWindow
    }
}
