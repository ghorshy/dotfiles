import QtQuick

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

    // Hyprland's shadow, pixel for pixel: one 1px ring per pixel of shadowRange,
    // alpha = shadow opacity * (1 - d / range) ^ render_power, with d the distance
    // from the outer edge. Hyprland samples d ~0.57px into each pixel (measured
    // on 0.56: 120/208/245 over white), hence the offset. Rings only cover the
    // outside, so nothing shows through the translucent surface itself.
    Repeater {
        model: root.shadow ? Theme.shadowRange : 0

        Rectangle {
            required property int index

            z: -1
            anchors.fill: parent
            anchors.margins: -(index + 1)
            radius: root.radius + index + 1
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.shadow, Theme.opacity.shadow * Math.pow(1 - (index + 0.57) / Theme.shadowRange, Theme.shadowPower))
        }
    }
}
