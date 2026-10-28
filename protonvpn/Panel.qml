import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen

    readonly property var geometryPlaceholder: container
    readonly property bool allowAttach: true

    readonly property var main: pluginApi?.mainInstance ?? null
    readonly property string vpnStatus: main?.vpnStatus ?? "unknown"
    readonly property bool connected: vpnStatus === "connected"
    readonly property bool acting: main?.isActing ?? false

    property real contentPreferredWidth:  Math.round(360 * Style.uiScaleRatio)
    property real contentPreferredHeight: Math.round(mainCol.implicitHeight + Style.marginL * 2)

    Component.onCompleted: { if (main) main.refresh(); }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: mainCol
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginM

            // ── Header ───────────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(headerRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: root.connected ? "shield-lock" : "shield"
                        pointSize: Style.fontSizeXL
                        color: root.connected ? Commons.Color.mPrimary : Commons.Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.title")
                        Layout.fillWidth: true
                    }

                    NIconButton {
                        icon: "refresh"
                        tooltipText: pluginApi?.tr("panel.refresh")
                        baseSize: Style.baseWidgetSize * 0.8
                        enabled: !root.acting
                        onClicked: main?.refresh()
                    }

                    NIconButton {
                        icon: "close"
                        tooltipText: pluginApi?.tr("panel.close")
                        baseSize: Style.baseWidgetSize * 0.8
                        onClicked: pluginApi.closePanel(pluginApi.panelOpenScreen)
                    }
                }
            }

            // ── Status card ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(statusCol.implicitHeight + Style.marginM * 2)

                ColumnLayout {
                    id: statusCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    RowLayout {
                        spacing: Style.marginS

                        Rectangle {
                            width: Math.round(8 * Style.uiScaleRatio)
                            height: width
                            radius: width / 2
                            color: {
                                if (root.acting)    return Commons.Color.mTertiary;
                                if (root.connected) return Commons.Color.mPrimary;
                                if (root.vpnStatus === "disconnected") return Commons.Color.mError;
                                return Commons.Color.mOnSurfaceVariant;
                            }
                        }

                        NLabel {
                            label: {
                                if (root.acting)    return pluginApi?.tr("panel.status-working");
                                if (root.connected) return pluginApi?.tr("panel.status-connected");
                                if (root.vpnStatus === "disconnected") return pluginApi?.tr("panel.status-disconnected");
                                return pluginApi?.tr("panel.status-unknown");
                            }
                            labelColor: {
                                if (root.acting)    return Commons.Color.mTertiary;
                                if (root.connected) return Commons.Color.mPrimary;
                                if (root.vpnStatus === "disconnected") return Commons.Color.mError;
                                return Commons.Color.mOnSurfaceVariant;
                            }
                        }

                        NLabel {
                            visible: root.connected && (main?.protocol ?? "") !== ""
                            label: (main?.protocol ?? "").toUpperCase()
                            labelColor: Commons.Color.mOnSurfaceVariant
                            Layout.fillWidth: true
                        }
                    }

                    // Server name + location
                    NLabel {
                        visible: root.connected && (main?.serverName ?? "") !== ""
                        label: (main?.serverName ?? "") +
                               ((main?.serverLocation ?? "") !== "" ? "  ·  " + main.serverLocation : "")
                        labelColor: Commons.Color.mOnSurface
                        Layout.fillWidth: true
                    }

                    // Load bar
                    RowLayout {
                        visible: root.connected && (main?.serverLoad ?? -1) >= 0
                        spacing: Style.marginS

                        NLabel {
                            label: pluginApi?.tr("panel.load")
                            labelColor: Commons.Color.mOnSurfaceVariant
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: Math.round(4 * Style.uiScaleRatio)
                            radius: height / 2
                            color: Commons.Color.mSurfaceVariant

                            Rectangle {
                                width: parent.width * Math.min(1, Math.max(0, (main?.serverLoad ?? 0) / 100))
                                height: parent.height
                                radius: parent.radius
                                color: (main?.serverLoad ?? 0) > 80 ? Commons.Color.mError
                                     : (main?.serverLoad ?? 0) > 50 ? Commons.Color.mTertiary
                                     : Commons.Color.mPrimary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }

                        NLabel {
                            label: (main?.serverLoad ?? 0) + "%"
                            labelColor: Commons.Color.mOnSurfaceVariant
                        }
                    }

                    // Error message
                    NLabel {
                        visible: (main?.lastError ?? "") !== ""
                        label: main?.lastError ?? ""
                        labelColor: Commons.Color.mError
                        Layout.fillWidth: true
                    }
                }
            }

            // ── Primary action ───────────────────────────────────────────────
            NButton {
                Layout.fillWidth: true
                text: root.connected ? pluginApi?.tr("panel.disconnect") : pluginApi?.tr("panel.connect-fastest")
                enabled: !root.acting && root.vpnStatus !== "unknown"
                onClicked: root.connected ? main?.disconnect() : main?.connectFastest()
            }

            // ── Kill switch ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(ksRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: ksRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: "shield-bolt"
                        pointSize: Style.fontSizeL
                        color: (main?.killSwitch ?? "off") === "standard"
                               ? Commons.Color.mPrimary : Commons.Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.kill-switch")
                        description: {
                            const ks = main?.killSwitch ?? "unknown";
                            if (ks === "standard") return pluginApi?.tr("panel.kill-switch-desc");
                            if (ks === "off")      return pluginApi?.tr("panel.kill-switch-disabled");
                            return pluginApi?.tr("panel.loading");
                        }
                        Layout.fillWidth: true
                    }

                    NToggle {
                        checked: (main?.killSwitch ?? "off") === "standard"
                        enabled: !root.acting && (main?.killSwitch ?? "unknown") !== "unknown"
                        onToggled: (isChecked) => main?.setKillSwitch(isChecked ? "standard" : "off")
                    }
                }
            }

            // ── Quick connect options (disconnected only) ────────────────────
            NBox {
                Layout.fillWidth: true
                visible: !root.connected
                Layout.preferredHeight: Math.round(quickCol.implicitHeight + Style.marginM * 2)

                ColumnLayout {
                    id: quickCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    NLabel {
                        label: pluginApi?.tr("panel.quick-connect")
                        labelColor: Commons.Color.mOnSurfaceVariant
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: Style.marginS
                        rowSpacing: Style.marginS

                        NButton {
                            Layout.fillWidth: true
                            text: pluginApi?.tr("panel.secure-core")
                            enabled: !root.acting
                            onClicked: main?.connectSecureCore()
                        }

                        NButton {
                            Layout.fillWidth: true
                            text: pluginApi?.tr("panel.p2p")
                            enabled: !root.acting
                            onClicked: main?.connectP2P()
                        }
                    }
                }
            }
        }
    }
}
