import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core

RowLayout {
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    Label {
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleLongDate)
        color: config.color
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent"
        font.pointSize: 11
        Layout.alignment: Qt.AlignHCenter
        font.family: config.font

    }
    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
        color: config.color
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent"
        font.pointSize: 11
        Layout.alignment: Qt.AlignHCenter
        font.family: config.font

    }
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
