import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.common

Module {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.sink]
    }

    padLeft: 6
    padRight: 8
    minWidth: 16
    text: muted ? Icons.volumeMuted : Icons.pick(Icons.volume, volume)
    tooltip: `${Math.round(volume * 100)}%`

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["pavucontrol"]);
        else if (sink?.audio)
            sink.audio.muted = !muted;
    }
    onWheel: wheel => {
        if (!sink?.audio)
            return;
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1, Math.round((volume + step) * 100) / 100));
    }
}
