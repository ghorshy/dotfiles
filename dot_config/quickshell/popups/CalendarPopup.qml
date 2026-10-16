import QtQuick
import Quickshell
import qs.common

// Month view, nothing else. Names and the first day of the week follow the system locale (LC_TIME).
BarPopup {
    id: popup

    readonly property var locale: Qt.locale()
    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    // 6 weeks starting on the locale's first day of the week
    readonly property var days: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() - locale.firstDayOfWeek + 7) % 7;
        return Array.from({ length: 42 }, (_, i) => new Date(year, month, 1 - offset + i));
    }

    function shift(months: int): void {
        const d = new Date(year, month + months, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    function showToday(): void {
        today = new Date();
        year = today.getFullYear();
        month = today.getMonth();
    }

    name: "calendar"
    contentWidth: 7 * 32 + 2 * padding

    onOpenChanged: if (open)
        showToday()

    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: 6
        text: popup.locale.toString(popup.today, "dddd, d MMMM yyyy")
        color: Theme.text
        font.family: Theme.fontUi
        font.pointSize: Theme.fontSize
        font.weight: Font.DemiBold
    }

    Separator {}

    // month header: arrows and month name (click returns to today)
    Item {
        width: parent.width
        height: 30

        PopupRow {
            width: 30
            glyph: Icons.chevronLeft
            onClicked: popup.shift(-1)
        }

        MouseArea {
            anchors.centerIn: parent
            width: monthName.implicitWidth + 16
            height: parent.height
            cursorShape: Qt.PointingHandCursor
            onClicked: popup.showToday()

            Text {
                id: monthName
                anchors.centerIn: parent
                text: `${popup.locale.standaloneMonthName(popup.month)} ${popup.year}`
                color: Theme.text
                font.family: Theme.fontUi
                font.weight: Theme.fontWeight
                font.pointSize: Theme.fontSize
                font.capitalization: Font.Capitalize
            }
        }

        PopupRow {
            x: parent.width - width
            width: 30
            glyph: Icons.chevronRight
            onClicked: popup.shift(1)
        }
    }

    Grid {
        id: grid
        columns: 7

        // weekday names
        Repeater {
            model: 7

            Text {
                required property int index
                width: 32
                height: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: popup.locale.dayName((popup.locale.firstDayOfWeek + index) % 7, Locale.ShortFormat).replace(".", "").slice(0, 3)
                color: Theme.textFaint
                font.family: Theme.fontUi
                font.weight: Theme.fontWeight
                font.pointSize: Theme.fontSize - 1
                font.capitalization: Font.Capitalize
            }
        }

        Repeater {
            model: popup.days

            Rectangle {
                required property date modelData
                readonly property bool isToday: modelData.toDateString() === popup.today.toDateString()
                readonly property bool inMonth: modelData.getMonth() === popup.month

                width: 32
                height: 28
                radius: Theme.radius
                color: "transparent"
                border.width: isToday ? Theme.borderWidth : 0
                border.color: Theme.borderActive

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.getDate()
                    color: parent.inMonth ? Theme.text : Theme.textFaint
                    font.family: Theme.fontUi
                    font.pointSize: Theme.fontSize
                    font.weight: parent.isToday ? Font.DemiBold : Theme.fontWeight
                }
            }
        }
    }

    // scroll anywhere over the calendar to change the month
    WheelHandler {
        target: null
        onWheel: event => popup.shift(event.angleDelta.y > 0 ? -1 : 1)
    }
}
