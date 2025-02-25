import QtQuick

ListView {
    id: view
    readonly property string selectedUser: currentItem ? currentItem.userName : ""
    readonly property int userItemWidth: units.gridUnit * 8
    readonly property int userItemHeight: units.gridUnit * 8

    implicitHeight: userItemHeight

    activeFocusOnTab: true

        signal
    userSelected

    orientation: ListView.Horizontal
    highlightRangeMode: ListView.StrictlyEnforceRange

    preferredHighlightBegin: width / 2 - userItemWidth / 2
    preferredHighlightEnd: preferredHighlightBegin

    delegate: UserDelegate {
        avatarPath: model.icon || ""
        iconSource: model.iconName || "user-identity"

        name: {
            let displayName = model.realName || model.name

            if (model.vtNumber === undefined || model.vtNumber < 0) {
                return displayName
            }

            if (!model.session) {
                return i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Nobody logged in on that session", "Unused")
            }


            var location = ""
            if (model.isTty) {
                location = i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "User logged in on console number", "TTY %1", model.vtNumber)
            } else if (model.displayNumber) {
                location = i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "User logged in on console (X display number)", "on TTY %1 (Display %2)", model.vtNumber, model.displayNumber)
            }

            if (location) {
                return i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Username (location)", "%1 (%2)", displayName, location)
            }

            return displayName
        }

        userName: model.name

        width: userItemWidth
        height: userItemHeight

        constrainText: ListView.view.count > 1

        isCurrent: ListView.isCurrentItem

        onClicked: {
            ListView.view.currentIndex = index
            ListView.view.userSelected()
        }
    }

    Keys.onEscapePressed: view.userSelected()
    Keys.onEnterPressed: view.userSelected()
    Keys.onReturnPressed: view.userSelected()
}
