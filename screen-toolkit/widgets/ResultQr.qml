import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Widgets
import qs.Services.UI
import "../utils/utils.js" as U
Item {
    id: root
    property var pluginApi: null
    property var mainInstance: null
    implicitWidth: parent?.width ?? 0
    implicitHeight: contentCol.implicitHeight
    readonly property string qrResult: mainInstance?.qrResult ?? ""
    readonly property string qrCapturePath: mainInstance?.qrCapturePath ?? ""
    readonly property string qrType: {
        var r = root.qrResult
        if (r.startsWith("http://") || r.startsWith("https://")) return "url"
        if (r.startsWith("WIFI:")) return "wifi"
        if (r.startsWith("BEGIN:VCARD")) return "contact"
        if (r.startsWith("mailto:")) return "email"
        if (r.startsWith("otpauth://")) return "otp"
        return "text"
    }
    readonly property string qrWifiName: {
        if (root.qrType !== "wifi") return ""
        var m = root.qrResult.match(/S:([^;]+)/)
        return m ? m[1] : ""
    }
    readonly property string qrWifiPass: {
        if (root.qrType !== "wifi") return ""
        var m = root.qrResult.match(/P:([^;]+)/)
        return m ? m[1] : ""
    }
    Process { id: clipProc }
    function _copy(text) {
        if (!text || text === "") return
        clipProc.exec({
            command: ["bash", "-c", "printf '%s' " + U.shellEscape(text) + " | wl-copy 2>/dev/null"]
        })
    }
    function clear() {
        if (mainInstance) {
            mainInstance.clearQrResult()
            mainInstance.activeTool = ""
        }
    }
    Column {
        id: contentCol
        width: parent.width
        spacing: Style.marginM
        Row {
            width: parent.width
            spacing: Style.marginS
            NIcon {
                icon: "qrcode"
                color: Commons.Color.mPrimary
                anchors.verticalCenter: parent.verticalCenter
            }
            NText {
                text: pluginApi?.tr("tools.qr")
                color: Commons.Color.mPrimary
                font.weight: Font.Bold
                pointSize: Style.fontSizeS
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Rectangle {
            width: parent.width
            height: Math.min(
                qrThumb.implicitHeight * (parent.width / Math.max(qrThumb.implicitWidth, 1)),
                160 * Style.uiScaleRatio
            )
            radius: Style.radiusM
            color: "transparent"
            clip: true
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth
            visible: root.qrCapturePath !== "" && root.qrResult !== "" && qrThumb.status === Image.Ready
            Image {
                id: qrThumb
                anchors.fill: parent
                source: (root.qrCapturePath !== "" && root.qrResult !== "")
                    ? ("file://" + root.qrCapturePath)
                    : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                cache: false
            }
        }
        Rectangle {
            height: 26
            width: qrBadge.implicitWidth + Style.marginM * 2
            radius: Style.radiusS
            color: Qt.alpha(Commons.Color.mPrimary, 0.15)
            NText {
                id: qrBadge
                anchors.centerIn: parent
                font.weight: Font.Bold
                pointSize: Style.fontSizeXS
                color: Commons.Color.mPrimary
                text: root.qrType === "url" ? "🔗 URL"
                    : root.qrType === "wifi" ? "📶 WiFi"
                    : root.qrType === "contact" ? "👤 Contact"
                    : root.qrType === "email" ? "✉️ Email"
                    : root.qrType === "otp" ? "🔐 OTP"
                    : "📄 Text"
            }
        }
        Column {
            width: parent.width
            spacing: Style.marginS
            visible: root.qrType === "wifi"
            Rectangle {
                width: parent.width
                height: 38
                radius: Style.radiusM
                color: Commons.Color.mSurface
                border.color: Style.capsuleBorderColor
                border.width: Style.capsuleBorderWidth
                Row {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: Style.marginS
                    NIcon {
                        icon: "wifi"
                        color: Commons.Color.mPrimary
                    }
                    NText {
                        text: root.qrWifiName || "Unknown"
                        color: Commons.Color.mOnSurface
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeS
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 38
                radius: Style.radiusM
                color: wph.containsMouse ? Commons.Color.mHover : Commons.Color.mSurface
                border.color: Style.capsuleBorderColor
                border.width: Style.capsuleBorderWidth
                Row {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: Style.marginS
                    NIcon {
                        icon: "key"
                        color: Commons.Color.mOnSurfaceVariant
                    }
                    NText {
                        text: root.qrWifiPass ? "••••••••" : pluginApi?.tr("panel.noPassword")
                        color: Commons.Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                    }
                    NIcon {
                        icon: "copy"
                        color: Commons.Color.mOnSurfaceVariant
                    }
                }
                MouseArea {
                    id: wph
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.qrWifiPass !== ""
                    onClicked: {
                        root._copy(root.qrWifiPass)
                        ToastService.showNotice(pluginApi?.tr("panel.passwordCopied"))
                    }
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 120 * Style.uiScaleRatio
            radius: Style.radiusM
            color: Commons.Color.mSurface
            clip: true
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth
            visible: root.qrType !== "wifi"
            Flickable {
                id: qrFlick
                anchors.fill: parent
                anchors.margins: Style.marginS
                contentHeight: qrText.implicitHeight
                clip: true
                interactive: qrText.implicitHeight > qrFlick.height
                TextEdit {
                    id: qrText
                    width: qrFlick.width
                    text: root.qrResult
                    wrapMode: TextEdit.WordWrap
                    color: Commons.Color.mOnSurface
                    font.pointSize: Style.fontSizeS
                    selectByMouse: true
                    selectionColor: Commons.Color.mPrimary
                    selectedTextColor: Commons.Color.mOnPrimary
                    WheelHandler {
                        onWheel: event => {
                            qrFlick.flick(0, event.angleDelta.y * 5)
                            event.accepted = false
                        }
                    }
                }
            }
        }
        Row {
            width: parent.width
            spacing: Style.marginS
            Rectangle {
                width: parent.width - 46
                height: 38
                radius: Style.radiusM
                color: qah.containsMouse ? Commons.Color.mPrimary : Commons.Color.mSurface
                border.color: Commons.Color.mPrimary
                border.width: Style.capsuleBorderWidth
                Row {
                    anchors.centerIn: parent
                    spacing: Style.marginS
                    NIcon {
                        icon: root.qrType === "url" ? "external-link"
                            : root.qrType === "email" ? "mail"
                            : "copy"
                        color: qah.containsMouse ? Commons.Color.mOnPrimary : Commons.Color.mPrimary
                    }
                    NText {
                        text: root.qrType === "url" ? pluginApi?.tr("panel.openUrl")
                            : root.qrType === "email" ? pluginApi?.tr("panel.composeEmail")
                            : pluginApi?.tr("panel.copy")
                        color: qah.containsMouse ? Commons.Color.mOnPrimary : Commons.Color.mPrimary
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeS
                    }
                }
                MouseArea {
                    id: qah
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.qrType === "url" || root.qrType === "email") {
                            Qt.openUrlExternally(root.qrResult)
                        } else {
                            root._copy(root.qrResult)
                            ToastService.showNotice(pluginApi?.tr("panel.copied"))
                        }
                    }
                }
            }
            Rectangle {
                width: 38
                height: 38
                radius: Style.radiusM
                color: qch.containsMouse ? Qt.alpha(Commons.Color.mError, 0.15) : Commons.Color.mSurface
                border.color: qch.containsMouse ? Commons.Color.mError : Style.capsuleBorderColor
                border.width: Style.capsuleBorderWidth
                NIcon {
                    anchors.centerIn: parent
                    icon: "trash"
                    color: qch.containsMouse ? (Commons.Color.mError || "#f44336") : Commons.Color.mOnSurfaceVariant
                }
                MouseArea {
                    id: qch
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clear()
                }
            }
        }
    }
}
