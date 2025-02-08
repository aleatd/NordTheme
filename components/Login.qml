import "components"

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Styles

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    function startLogin() {
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        const password = passwordBox.text

        loginButton.forceActiveFocus()
        loginRequest(username, password)
    }

    Input {
        id: userNameInput
        Layout.fillWidth: true
        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        onAccepted:
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
    }

    Input {
        id: passwordBox
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password
        color: "#4C566A"

        Layout.fillWidth: true

        onAccepted: {
            if (root.loginScreenUiVisible) {
                startLogin()
            }
        }

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus()
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Left && !text) {
                userList.decrementCurrentIndex()
                event.accepted = true
            }
            if (event.key === Qt.Key_Right && !text) {
                userList.incrementCurrentIndex()
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }
    Button {
        id: loginButton
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
        enabled: passwordBox.text != ""

        Layout.topMargin: 10
        Layout.bottomMargin: 10
        Layout.fillWidth: true

        font.pointSize: config.fontSize
        font.family: config.font

        contentItem: Text {
            text: loginButton.text
            font: loginButton.font
            opacity: enabled ? 1.0 : 1.0
            color: config.highlight_color
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            id: buttonBackground
            width: parent.width
            height: 30
            radius: width / 2
            color: "#82ABAA"
            opacity: enabled ? 1.0 : 1.0
        }

        onClicked: startLogin()
    }
}
