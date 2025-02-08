import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Styles

TextField {
    placeholderTextColor: config.color
    palette.text: config.color
    font.pointSize: config.fontSize
    font.family: config.font
    background: Rectangle {
        color: "#2e3440"
        radius: parent.width / 2
        height: 30
        width: parent.width
        opacity: 0.7
        anchors.centerIn: parent
    }
}