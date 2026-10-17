import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

// App launcher and calculator, toggled with `qs ipc call launcher toggle`.
// A query starting with "=" (or plain arithmetic like 2+2*3) is evaluated with qalc
// instead of searching apps, and Enter copies the result.
Scope {
    id: root

    readonly property int rowHeight: 36
    readonly property int maxRows: 10
    // Terminal=true apps run in the terminal from hypr/programs.lua
    readonly property list<string> terminal: ["kitty", "-e"]

    property bool open: false
    property string query: ""

    readonly property bool calcMode: query.trim().startsWith("=") || /^[\d\s.,()]*\d[\d\s.,()]*[+\-*\/^%][\d\s.,+\-*\/^%()]*$/.test(query.trim())
    readonly property string expression: calcMode ? query.trim().replace(/^=/, "").trim() : ""
    property string calcResult: ""
    // expression of the last qalc run, to rerun once it exits when the query moved on
    property string calcRan: ""

    // Filtered and ranked entries: every search word has to match somewhere, matches
    // in the name beat matches in the description, then the most launched apps win.
    readonly property var results: {
        if (calcMode)
            return [];
        const words = query.toLowerCase().split(/\s+/).filter(w => w !== "");
        const launches = usage.launches;
        const scored = [];
        for (const entry of DesktopEntries.applications.values) {
            if (entry.noDisplay)
                continue;
            let score = 0;
            for (const word of words) {
                const s = matchScore(entry, word);
                if (s === 0) {
                    score = -1;
                    break;
                }
                score += s;
            }
            if (score >= 0)
                scored.push({ entry, score, launches: launches[entry.id] ?? 0 });
        }
        scored.sort((a, b) => b.score - a.score || b.launches - a.launches || a.entry.name.localeCompare(b.entry.name));
        return scored.map(s => s.entry);
    }

    function matchScore(entry: DesktopEntry, word: string): int {
        const name = entry.name.toLowerCase();
        if (name.startsWith(word))
            return 4;
        if (name.split(/[\s\-_.]+/).some(part => part.startsWith(word)))
            return 3;
        if (name.includes(word))
            return 2;
        const extra = [entry.genericName, entry.id, ...entry.keywords, ...entry.categories].join(" ").toLowerCase();
        return extra.includes(word) ? 1 : 0;
    }

    function close(): void {
        open = false;
    }

    function quote(arg: string): string {
        return `'${arg.replace(/'/g, "'\\''")}'`;
    }

    function launch(entry: DesktopEntry): void {
        close();
        usage.launches = Object.assign({}, usage.launches, { [entry.id]: (usage.launches[entry.id] ?? 0) + 1 });
        usageFile.writeAdapter();

        const args = entry.runInTerminal ? [...terminal, ...entry.command] : entry.command;
        let command = args.map(quote).join(" ");
        if (entry.workingDirectory !== "")
            command = `cd ${quote(entry.workingDirectory)} && ${command}`;
        // Run through Hyprland like the power menu, so apps land in the logind session
        // and don't inherit Quickshell's environment when it was started from a terminal.
        Hyprland.dispatch(`hl.dsp.exec_cmd(${JSON.stringify(command)})`);
    }

    function copyResult(): void {
        if (calcResult === "")
            return;
        close();
        Quickshell.execDetached(["wl-copy", "--", calcResult]);
    }

    function calculate(): void {
        if (expression === "") {
            calcResult = "";
            return;
        }
        if (qalc.running)
            return;
        calcRan = expression;
        qalc.command = ["qalc", "-t", expression];
        qalc.running = true;
    }

    onExpressionChanged: {
        if (expression === "")
            calculate();
        else
            calcDelay.restart();
    }

    Timer {
        id: calcDelay
        interval: 50
        onTriggered: root.calculate()
    }

    Process {
        id: qalc
        stdout: StdioCollector {
            onStreamFinished: root.calcResult = root.expression === "" ? "" : text.trim()
        }
        onExited: if (root.calcRan !== root.expression) root.calculate()
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            if (root.open)
                root.close();
            else
                root.open = true;
        }
    }

    // launch counts per desktop entry id, so the most used apps come first
    FileView {
        id: usageFile
        path: Quickshell.statePath("launcher.json")
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: usage
            property var launches: ({})
        }
    }

    // Created once at startup and only shown/hidden, so opening is instant.
    PanelWindow {
        visible: root.open
        screen: Screens.focused
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell:launcher"

        // click outside closes
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Surface {
            id: menu

            anchors.horizontalCenter: parent.horizontalCenter
            // centered at its full size, so the search field stays put while the list shrinks
            y: (parent.height - search.height - root.maxRows * root.rowHeight) / 2
            width: 640
            height: search.height + (root.calcMode ? calc.height + Theme.borderWidth : list.count > 0 ? list.height + Theme.borderWidth : 0)

            // swallow clicks so they don't reach the close-on-click-outside area
            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: search
                width: parent.width
                height: 52

                Text {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: Icons.search
                    color: Theme.textDim
                    font.family: Theme.fontIcons
                    font.weight: Theme.fontWeight
                    font.styleName: "Medium"
                    font.pointSize: Theme.fontSizeLarge + 2
                }

                TextInput {
                    id: input
                    anchors.left: searchIcon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.text
                    selectionColor: Theme.overlay
                    font.family: Theme.fontUi
                    font.weight: Theme.fontWeight
                    font.pointSize: Theme.fontSizeLarge
                    focus: true

                    onTextChanged: {
                        root.query = text;
                        list.currentIndex = 0;
                    }
                    onAccepted: {
                        if (root.calcMode) {
                            root.copyResult();
                            return;
                        }
                        const entry = root.results[list.currentIndex];
                        if (entry)
                            root.launch(entry);
                    }

                    Keys.onPressed: event => {
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        switch (event.key) {
                        case Qt.Key_Escape:
                            root.close();
                            break;
                        case Qt.Key_Up:
                        case Qt.Key_Backtab:
                            list.move(-1);
                            break;
                        case Qt.Key_Down:
                        case Qt.Key_Tab:
                            list.move(1);
                            break;
                        case Qt.Key_PageUp:
                            list.move(-root.maxRows);
                            break;
                        case Qt.Key_PageDown:
                            list.move(root.maxRows);
                            break;
                        case Qt.Key_K:
                        case Qt.Key_P:
                            if (!ctrl)
                                return;
                            list.move(-1);
                            break;
                        case Qt.Key_J:
                        case Qt.Key_N:
                            if (!ctrl)
                                return;
                            list.move(1);
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }

                    Text {
                        visible: input.text === ""
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Search"
                        color: Theme.textFaint
                        font: input.font
                    }

                    Connections {
                        target: root
                        function onOpenChanged() {
                            if (root.open) {
                                input.text = "";
                                list.currentIndex = 0;
                                list.positionViewAtBeginning();
                                input.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: search.bottom
                width: parent.width
                height: Theme.borderWidth
                visible: root.calcMode || list.count > 0
                color: Theme.alpha(Theme.border, Theme.opacity.popup)
            }

            MouseArea {
                id: calc
                anchors.top: search.bottom
                anchors.topMargin: Theme.borderWidth
                width: parent.width
                height: 48
                visible: root.calcMode
                cursorShape: root.calcResult !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.copyResult()

                Rectangle {
                    anchors.fill: parent
                    color: root.calcResult !== "" ? Theme.alpha(Theme.overlay, Theme.opacity.popup) : "transparent"
                }

                Text {
                    id: calcIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    horizontalAlignment: Text.AlignHCenter
                    text: Icons.calculator
                    color: Theme.textDim
                    font.family: Theme.fontIcons
                    font.weight: Theme.fontWeight
                    font.styleName: "Medium"
                    font.pointSize: Theme.fontSizeLarge
                }

                Text {
                    anchors.left: calcIcon.right
                    anchors.leftMargin: 16
                    anchors.right: hint.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.calcResult !== "" ? root.calcResult : "Type an expression, e.g. 10 usd to pln"
                    elide: Text.ElideRight
                    color: root.calcResult !== "" ? Theme.text : Theme.textFaint
                    font.family: Theme.fontUi
                    font.weight: root.calcResult !== "" ? Font.DemiBold : Theme.fontWeight
                    font.pointSize: root.calcResult !== "" ? Theme.fontSizeLarge : Theme.fontSize
                }

                Text {
                    id: hint
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.calcResult !== ""
                    text: "Enter to copy"
                    color: Theme.textFaint
                    font.family: Theme.fontUi
                    font.weight: Theme.fontWeight
                    font.pointSize: Theme.fontSize
                }
            }

            ListView {
                id: list

                function move(step: int): void {
                    if (count > 0)
                        currentIndex = Math.max(0, Math.min(count - 1, currentIndex + step));
                }

                anchors.top: search.bottom
                anchors.topMargin: Theme.borderWidth
                width: parent.width
                height: Math.min(count, root.maxRows) * root.rowHeight
                model: root.results
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0
                clip: true

                delegate: MouseArea {
                    id: row

                    required property DesktopEntry modelData
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem

                    width: ListView.view.width
                    height: root.rowHeight
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    // only follow the mouse when it actually moves, not when the list scrolls under it
                    onPositionChanged: list.currentIndex = index
                    onClicked: root.launch(modelData)

                    Rectangle {
                        anchors.fill: parent
                        color: row.selected ? Theme.alpha(Theme.overlay, Theme.opacity.popup) : "transparent"
                    }

                    IconImage {
                        id: icon
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 20
                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                    }

                    Text {
                        anchors.left: icon.right
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.name
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.weight: row.selected ? Font.DemiBold : Theme.fontWeight
                        font.pointSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
