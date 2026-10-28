import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var output
  property var pluginApi
  property bool expanded: false

  signal modeSelected(string modeLabel)

  spacing: Style.marginXS

  readonly property string currentModeText: {
    var idx = output.currentModeIndex
    var modes = output.modes || []
    if (idx >= 0 && idx < modes.length) {
      var m = modes[idx]
      return m.width + "x" + m.height + " @ " + parseFloat(m.refreshRate).toFixed(1) + " Hz"
    }
    return "-"
  }

  Rectangle {
    id: header
    property bool hovered: false
    Layout.fillWidth: true
    height: 34 * Style.uiScaleRatio
    radius: Style.radiusS
    color: hovered ? Commons.Color.mSurface : "transparent"
    border.color: Commons.Color.mOutline
    border.width: Style.borderS

    RowLayout {
      anchors { fill: parent; leftMargin: Style.marginS; rightMargin: Style.marginS }
      spacing: Style.marginS

      NText {
        text: root.pluginApi?.tr("panel.mode")
        pointSize: Style.fontSizeS; font.weight: Font.DemiBold; color: Commons.Color.mOnSurfaceVariant
      }
      NText {
        text: root.currentModeText
        pointSize: Style.fontSizeS; color: Commons.Color.mOnSurface
        Layout.fillWidth: true
        elide: Text.ElideRight
      }
      NIcon {
        icon: root.expanded ? "chevron-up" : "chevron-down"
        pointSize: Style.fontSizeXS; color: Commons.Color.mOnSurfaceVariant
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: header.hovered = true
      onExited: header.hovered = false
      onClicked: root.expanded = !root.expanded
    }
  }

  ColumnLayout {
    visible: root.expanded
    Layout.fillWidth: true
    spacing: 0

    Repeater {
      model: root.output.modes || []

      delegate: Rectangle {
        id: row
        property var mode: modelData
        property bool isCurrent: index === root.output.currentModeIndex
        property bool hovered: false

        Layout.fillWidth: true
        height: 34 * Style.uiScaleRatio
        radius: Style.radiusS
        color: isCurrent
          ? Qt.rgba(Commons.Color.mPrimary.r, Commons.Color.mPrimary.g, Commons.Color.mPrimary.b, 0.18)
          : hovered ? Commons.Color.mSurface : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        RowLayout {
          anchors { fill: parent; leftMargin: Style.marginM; rightMargin: Style.marginS }
          spacing: Style.marginS

          NText {
            text: row.mode.width + "x" + row.mode.height
            pointSize: Style.fontSizeS
            color: row.isCurrent ? Commons.Color.mPrimary : Commons.Color.mOnSurface
            font.weight: row.isCurrent ? 600 : 400
          }
          NText {
            text: root.pluginApi?.tr("panel.refreshRateSuffix").arg(parseFloat(row.mode.refreshRate).toFixed(1))
            pointSize: Style.fontSizeXS
            color: Commons.Color.mOnSurfaceVariant
          }
          NText {
            visible: row.mode.isPreferred
            text: root.pluginApi?.tr("panel.preferred")
            pointSize: Style.fontSizeXS
            color: Commons.Color.mPrimary
          }
          Item { Layout.fillWidth: true }
          NIcon {
            icon: "check"
            color: Commons.Color.mPrimary
            pointSize: Style.fontSizeS
            visible: row.isCurrent
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: root.enabled
          onEntered: row.hovered = true
          onExited: row.hovered = false
          onClicked: {
            if (!row.isCurrent) {
              root.modeSelected(row.mode.label)
              root.expanded = false
            }
          }
        }
      }
    }
  }
}
