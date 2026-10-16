import QtQuick
import QtQuick.Effects

// Background shared by every popup: translucent base, border, radius and the
// same shadow Hyprland draws around windows. Windows hosting a Surface with a
// shadow need Theme.shadowRange px of free space around it.
Rectangle {
    id: root

    property color tint: Theme.base
    property color borderTint: Theme.border
    property real level: Theme.opacity.popup
    property bool shadow: true

    radius: Theme.radius
    color: Theme.alpha(tint, level)
    border.width: Theme.borderWidth
    border.color: Theme.alpha(borderTint, level)

    // The blur is centered on the shape's edge, so grow the shape by half of it:
    // the shadow then fades over shadowRange px outside the surface and none of
    // it shows through the translucent surface itself.
    RectangularShadow {
        visible: root.shadow
        z: -1
        anchors.fill: parent
        anchors.margins: -Theme.shadowRange / 2
        radius: parent.radius + Theme.shadowRange / 2
        blur: Theme.shadowRange / 2
        color: Theme.alpha(Theme.shadow, Theme.opacity.shadow)
    }
}
