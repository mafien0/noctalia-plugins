import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Widgets
import qs.Services.UI

NBox {
    id: root

    property string name: ""
    property string type: ""
    property bool isConnected: false
    property bool isLoading: false

    signal buttonClicked

    Layout.fillWidth: true
    Layout.leftMargin: Style.marginXS
    Layout.rightMargin: Style.marginXS
    implicitHeight: Math.round(netColumn.implicitHeight + (Style.marginXL))

    color: root.isConnected ? Qt.alpha(Commons.Color.mPrimary, 0.15) : Commons.Color.mSurface

    ColumnLayout {
        id: netColumn
        width: parent.width - (Style.marginXL)
        x: Style.marginM
        y: Style.marginM
        spacing: Style.marginS

        // Main row
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
                icon: "router"
                pointSize: Style.fontSizeXXL
                color: root.isConnected ? Commons.Color.mPrimary : Commons.Color.mOnSurface
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                NText {
                    text: root.name
                    pointSize: Style.fontSizeM
                    font.weight: Style.fontWeightMedium
                    color: Commons.Color.mOnSurface
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: Style.marginXS

                    NText {
                        text: root.type
                        pointSize: Style.fontSizeXXS
                        color: Commons.Color.mOnSurfaceVariant
                    }

                    Item {
                        Layout.preferredWidth: Style.marginXXS
                    }

                    
                    Rectangle {
                        visible: root.isConnected
                        color: Commons.Color.mPrimary
                        radius: height * 0.5
                        width: Math.round(connectedText.implicitWidth + (Style.marginS * 2))
                        height: Math.round(connectedText.implicitHeight + (Style.marginXS))

                        NText {
                            id: connectedText
                            anchors.centerIn: parent
                            text: pluginApi?.tr("common.connected")
                            pointSize: Style.fontSizeXXS
                            color: Commons.Color.mOnPrimary
                        }
                    }
                }
            }

            // Action area
            RowLayout {
                spacing: Style.marginS

                NBusyIndicator {
                    visible: root.isLoading
                    running: visible
                    color: Commons.Color.mPrimary
                    size: Style.baseWidgetSize * 0.5
                }

                NButton {
                    visible: root.isConnected
                    text: pluginApi?.tr("common.disconnect")
                    outlined: !hovered
                    fontSize: Style.fontSizeS
                    backgroundColor: Commons.Color.mError
                    enabled: !root.isLoading
                    onClicked: {
                        root.buttonClicked()
                    }
                }

                NButton {
                    visible: !root.isConnected
                    text: pluginApi?.tr("common.connect")
                    outlined: !hovered
                    fontSize: Style.fontSizeS
                    enabled: !root.isLoading
                    onClicked: {
                        root.buttonClicked()
                    }
                }
            }
        }
    }
}