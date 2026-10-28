import QtQuick
import Quickshell
import qs.Widgets
import qs.Commons

import qs.Commons as Commons
NIconButton {
    property ShellScreen screen
    property var pluginApi: null
    readonly property var mainInstance: pluginApi?.mainInstance

    icon: {
        if (mainInstance && mainInstance.timerSoundPlaying) return "bell-ringing"
        if (mainInstance && mainInstance.timerStopwatchMode) return "stopwatch"
        return "hourglass"
    }

    tooltipText: {
        if (!mainInstance) return "Timer"
        if (mainInstance.timerSoundPlaying) return "Timer Finished!"
        if (mainInstance.timerStopwatchMode) {
            return mainInstance.timerRunning ? "Stopwatch Running" : "Stopwatch"
        }
        return mainInstance.timerRunning ? "Timer Running" : "Timer"
    }

    colorFg: {
        if (mainInstance && (mainInstance.cdRunning || mainInstance.swRunning || mainInstance.cdSoundPlaying)) {
            return Commons.Color.mOnPrimary
        }
        return Commons.Color.mPrimary
    }

    colorBg: {
        if (mainInstance && (mainInstance.cdRunning || mainInstance.swRunning || mainInstance.cdSoundPlaying)) {
            return Commons.Color.mPrimary
        }
        return Style.capsuleColor
    }

    onClicked: {
        if (pluginApi) {
            pluginApi.togglePanel(screen);
        }
    }
}
