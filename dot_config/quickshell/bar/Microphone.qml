import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.common

Module {
    id: root

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: source?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.source]
    }

    padLeft: 6
    padRight: 8
    minWidth: 16
    text: muted ? Icons.micMuted : Icons.mic
    tooltip: `${Math.round((source?.audio?.volume ?? 0) * 100)}%`

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["pavucontrol"]);
        else if (source?.audio)
            source.audio.muted = !muted;
    }
}
