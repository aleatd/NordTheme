import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtGraphicalEffects
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "components"

PlasmaCore.ColorScope {
    id: root

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property string notificationMessage

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    width: 1600
    height: 900
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start()
        }
    }

    PlasmaCore.DataSource {
        id: keystateSource

        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Image {
        id: wallpaper

        height: parent.height
        width: parent.width
        source: config.background || config.Background
        asynchronous: true
        cache: true
        clip: true
    }

    MouseArea {
        id: loginScreenRoot

        property bool uiVisible: true
        property bool blockUI: mainStack.depth > 1 || userListComponent.mainPasswordBox.text.length > 0 || inputPanel.keyboardActive || config.type != "image"

        anchors.fill: parent
        hoverEnabled: true
        drag.filterChildren: true
        onPressed: uiVisible = true
        onPositionChanged: uiVisible = true
        onUiVisibleChanged: {
            if (blockUI)
                fadeoutTimer.running = false
            else if (uiVisible)
                fadeoutTimer.restart()
        }
        onBlockUIChanged: {
            if (blockUI) {
                fadeoutTimer.running = false
                uiVisible = true
            } else {
                fadeoutTimer.restart()
            }
        }
        Keys.onPressed: {
            uiVisible = true
            event.accepted = false
        }

        Timer {
            id: fadeoutTimer

            running: true
            interval: 60000
            onTriggered: {
                if (!loginScreenRoot.blockUI)
                    loginScreenRoot.uiVisible = false

            }
        }

        StackView {
            id: mainStack

            anchors.centerIn: parent
            height: root.height / 2
            width: parent.width / 3
            focus: true

            Timer {
                running: true
                repeat: false
                interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }

            initialItem: Login {
                id: userListComponent

                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                showUserList: {
                    if (!userListModel.hasOwnProperty("count") || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + mainStack.y) > 0

                    if (userListModel.count == 0)
                        return false

                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
                }
                notificationMessage: {
                    let text = ""
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on")
                        if (root.notificationMessage)
                            text += " • "

                    }
                    text += root.notificationMessage
                    return text
                }
                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }
                actionItems: [
                    ActionButton {
                        iconSource: "system-suspend"
                        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: "system-reboot"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: "system-shutdown"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        visible: !inputPanel.keyboardActive
                    }
                ]
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration
                }

            }

        }

        Loader {
            id: inputPanel

            property bool keyboardActive: item ? item.active : false

            function showHide() {
                state = state == "hidden" ? "visible" : "hidden"
            }

            state: "hidden"
            onKeyboardActiveChanged: {
                if (keyboardActive)
                    state = "visible"
                else
                    state = "hidden"
            }
            source: "components/VirtualKeyboard.qml"
            states: [
                State {
                    name: "visible"

                    PropertyChanges {
                        target: mainStack
                        y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                    }

                    PropertyChanges {
                        target: inputPanel
                        y: root.height - inputPanel.height
                        opacity: 1
                    }

                },
                State {
                    name: "hidden"

                    PropertyChanges {
                        target: mainStack
                        y: 0
                    }

                    PropertyChanges {
                        target: inputPanel
                        y: root.height - root.height / 4
                        opacity: 0
                    }

                }
            ]
            transitions: [
                Transition {
                    "hidden"
                    to: "visible"

                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true
                                Qt.inputMethod.show()
                            }
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                target: inputPanel
                                "y"
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }

                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }

                        }

                    }

                },
                Transition {
                    "visible"
                    to: "hidden"

                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                target: inputPanel
                                "y"
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }

                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }

                        }

                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide()
                            }
                        }

                    }

                }
            ]

            anchors {
                left: parent.left
                right: parent.right
            }

        }

        Component {
            id: userPromptComponent

            Login {
                showUsernamePrompt: true
                notificationMessage: root.notificationMessage
                loginScreenUiVisible: loginScreenRoot.uiVisible
                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }
                actionItems: [
                    ActionButton {
                        iconSource: "system-suspend"
                        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: "system-reboot"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: "system-shutdown"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: "go-previous"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "List Users")
                        onClicked: mainStack.pop()
                        visible: !inputPanel.keyboardActive
                    }
                ]

                userListModel: ListModel {
                    Component.onCompleted: {
                        setProperty(0, "name", i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Type in Username and Password"))
                    }

                    ListElement {
                        name: ""
                        iconSource: ""
                    }

                }

            }

        }

        Rectangle {
            id: blurBg

            anchors.fill: parent
            anchors.centerIn: parent
            color: "#4C566A"
            opacity: 0
            z: -1
        }

        Rectangle {
            id: formBg

            width: mainStack.width
            height: mainStack.height
            x: root.width / 2 - width / 2
            y: root.height / 2 - height / 3
            radius: 10
            color: "#2e3440"
            opacity: 1
            z: -1

            DropShadow {
                anchors.fill: formBg
                cached: true
                horizontalOffset: 3
                verticalOffset: 3
                radius: 10
                samples: 50
                color: "#aa000000"
                source: formBg
            }

        }

        ShaderEffectSource {
            id: blurArea

            sourceItem: wallpaper
            width: blurBg.width
            height: blurBg.height
            anchors.centerIn: blurBg
            sourceRect: Qt.rect(x, y, width, height)
            visible: true
            z: -2
        }

        GaussianBlur {
            id: blur

            height: blurBg.height
            width: blurBg.width
            source: blurArea
            radius: 0
            samples: 0
            cached: true
            anchors.centerIn: blurBg
            visible: true
            z: -2
        }

        RowLayout {
            id: footer

            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: units.smallSpacing
            }

            PlasmaComponents.ToolButton {
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
                iconName: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                onClicked: inputPanel.showHide()
                visible: inputPanel.status == Loader.Ready
            }

            KeyboardButton {
            }

            SessionButton {
                id: sessionButton
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration
                }

            }

        }

        RowLayout {
            id: footerRight

            spacing: 10

            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 10
            }

            Clock {
                id: clock

                visible: true
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration
                }

            }

        }

    }

    Connections {
        target: sddm
        onLoginFailed: {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
        onLoginSucceeded: {
            mainStack.opacity = 0
            footer.opacity = 0
            footerRight.opacity = 0
        }
    }

    Timer {
        id: notificationResetTimer

        interval: 3000
        onTriggered: notificationMessage = ""
    }

}
