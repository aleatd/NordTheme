import QtQuick
import QtQuick.VirtualKeyboard

InputPanel {
    id: inputPanel
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
    width: parent.width
}
