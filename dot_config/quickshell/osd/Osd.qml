import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import qs.common

// Volume / microphone / brightness indicator.
// Volume and mic react to PipeWire directly, brightness is pushed with `qs ipc call osd brightness`.
Scope {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    property string icon
    property real value
    property bool showBar: true
    property bool dimmed: false
    property bool shown: false

    function show(icon: string, value: real, showBar: bool, dimmed = false): void {
        if (startup.running)
            return;
        root.icon = icon;
        root.value = value;
        root.showBar = showBar;
        root.dimmed = dimmed;
        root.shown = true;
        hide.restart();
    }

    function showVolume(): void {
        const audio = sink?.audio;
        if (audio)
            show(audio.muted ? Icons.volumeMuted : Icons.pick(Icons.volume, audio.volume), audio.volume, true, audio.muted);
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { root.showVolume(); }
        function onMutedChanged() { root.showVolume(); }
    }

    Connections {
        target: root.source?.audio ?? null
        function onMutedChanged() {
            root.show(root.source.audio.muted ? Icons.micMuted : Icons.mic, 0, false);
        }
    }

    IpcHandler {
        target: "osd"

        function brightness(): void {
            brightnessctl.running = true;
        }
    }

    Process {
        id: brightnessctl
        command: ["brightnessctl", "-m"]
        // device,class,current,percent,max
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                const current = Number(fields[2]);
                const max = Number(fields[4]);
                if (max > 0)
                    root.show(Icons.brightness, current / max, true);
            }
        }
    }

    // ignore the burst of change signals while PipeWire objects bind at startup
    Timer {
        id: startup
        interval: 1500
        running: true
    }

    Timer {
        id: hide
        interval: 1500
        onTriggered: root.shown = false
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            screen: Screens.focused
            anchors.bottom: true
            margins.bottom: 80
            exclusiveZone: 0
            implicitWidth: root.showBar ? 260 : 56
            implicitHeight: 48
            color: "transparent"
            mask: Region {}

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:osd"

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius
                color: Theme.alpha(Theme.base, 0.9)
                border.width: Theme.borderWidth
                border.color: Theme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: !root.showBar
                        horizontalAlignment: Text.AlignHCenter
                        text: root.icon
                        color: Theme.text
                        font.family: Theme.fontIcons
                        font.pixelSize: 18
                    }

                    Rectangle {
                        visible: root.showBar
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.surface

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, root.value))
                            height: parent.height
                            radius: parent.radius
                            color: root.dimmed ? Theme.muted : Theme.text

                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.showBar
                        Layout.preferredWidth: 32
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(root.value * 100)
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
