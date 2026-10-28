
import QtQuick
import Quickshell
import qs.Widgets
import qs.Commons

import qs.Commons as Commons
NIconButton {
    property ShellScreen screen
    property var pluginApi: null
    readonly property var mainInstance: pluginApi?.mainInstance

    enabled: mainInstance?.isAvailable ?? false
    icon: "camera-video"
    tooltipText: mainInstance?.buildTooltip()
    colorFg: mainInstance?.isRecording ? Commons.Color.mOnPrimary : (mainInstance?.isReplaying ? Commons.Color.mSecondary : Commons.Color.mPrimary)
    colorBg: mainInstance?.isRecording ? Commons.Color.mPrimary : (mainInstance?.isReplaying ? Qt.alpha(Commons.Color.mSecondary, 0.25) : Style.capsuleColor)
    onClicked: {
        if (pluginApi && pluginApi.mainInstance) {
            pluginApi.mainInstance.toggleRecording();
        }
    }
}
