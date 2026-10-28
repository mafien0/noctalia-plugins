import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Widgets

Item {
  id: emptyState

  property var pluginApi: null

  ColumnLayout {
    anchors.centerIn: parent
    spacing: Style.marginM

    NIcon {
      Layout.alignment: Qt.AlignHCenter
      icon: "note"
      pointSize: Style.fontSizeXXL * 2
      color: Commons.Color.mOnSurfaceVariant
    }

    NText {
      Layout.alignment: Qt.AlignHCenter
      text: emptyState.pluginApi?.tr("notes.empty")
      font.pointSize: Style.fontSizeM * Style.uiScaleRatio
      color: Commons.Color.mOnSurfaceVariant
    }

    NText {
      Layout.alignment: Qt.AlignHCenter
      text: emptyState.pluginApi?.tr("notes.create-first")
      font.pointSize: Style.fontSizeS * Style.uiScaleRatio
      color: Commons.Color.mOutline
    }
  }
}
