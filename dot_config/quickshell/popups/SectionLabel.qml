import QtQuick
import qs.common

Text {
    width: parent?.width ?? 0
    topPadding: 6
    leftPadding: 6
    bottomPadding: 2
    color: Theme.textFaint
    font.family: Theme.fontUi
    font.pointSize: Theme.fontSize - 1
    font.weight: Font.DemiBold
}
