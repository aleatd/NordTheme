import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import QtQuick.Controls as QQC

PlasmaComponents.ToolButton {
    id: keyboardButton

    property int currentIndex: -1

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Keyboard Layout: %1", instantiator.objectAt(currentIndex).shortName)
    implicitWidth: minimumWidth
    font.pointSize: config.fontSize

    visible: menu.items.length > 1

    Component.onCompleted: currentIndex = Qt.binding(function () {
        return keyboard.currentLayout
    })

    menu: QQC.Menu
    {
        id: keyboardMenu
        style: DropdownMenuStyle {
        }
        Instantiator {
            id: instantiator
            model: keyboard.layouts
            onObjectAdded: keyboardMenu.insertItem(index, object)
            onObjectRemoved: keyboardMenu.removeItem(object)
            delegate: QQC.MenuItem
            {
                text: modelData.longName
                property string shortName: modelData.shortName
                onTriggered: {
                    keyboard.currentLayout = model.index
                }
            }
        }
    }
}
