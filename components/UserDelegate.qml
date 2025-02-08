import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
    id: wrapper

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrent: true
    readonly property var mod: model
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool constrainText: true
    property alias nameFontSize: usernameDelegate.font.pointSize
    property int fontSize: config.fontSize - 1

    signal clicked()

    property real faceSize: Math.min(width, height - usernameDelegate.height - units.smallSpacing)

    opacity: isCurrent ? 1.0 : 0.5

    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration
        }
    }

    Rectangle {
        anchors.centerIn: imageSource
        width: imageSource.width + 2
        height: width
        radius: width / 2
        color: "#232831"
    }

    Item {
        id: imageSource
        anchors {
            bottom: usernameDelegate.top
            bottomMargin: units.largeSpacing
            horizontalCenter: parent.horizontalCenter
        }
        Behavior on width {
            PropertyAnimation {
                from: faceSize
                duration: units.longDuration * 2
            }
        }
        width: isCurrent ? faceSize : faceSize - units.largeSpacing
        height: width

        Image {
            id: face
            source: wrapper.avatarPath
            sourceSize: Qt.size(faceSize, faceSize)
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }

        PlasmaCore.IconItem {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            anchors.margins: units.gridUnit * 0.5
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
    }

    ShaderEffect {
        anchors {
            bottom: usernameDelegate.top
            bottomMargin: units.largeSpacing
            horizontalCenter: parent.horizontalCenter
        }

        width: imageSource.width
        height: imageSource.height

        supportsAtlasTextures: true

        property var source: ShaderEffectSource
        {
            sourceItem: imageSource
            hideSource: wrapper.GraphicsInfo.api !== GraphicsInfo.Software
            live: true
        }

        property var colorBorder: "#00000000"

        fragmentShader: "
                        varying highp vec2 qt_TexCoord0
                        uniform highp float qt_Opacity
                        uniform lowp sampler2D source

                        uniform lowp vec4 colorBorder
                        highp float blend = 0.01
                        highp float innerRadius = 0.47
                        highp float outerRadius = 0.49
                        lowp vec4 colorEmpty = vec4(0.0, 0.0, 0.0, 0.0)

                        void main() {
                            lowp vec4 colorSource = texture2D(source, qt_TexCoord0.st)

                            highp vec2 m = qt_TexCoord0 - vec2(0.5, 0.5)
                            highp float dist = sqrt(m.x * m.x + m.y * m.y)

                            if (dist < innerRadius)
                                gl_FragColor = colorSource
                            else if (dist < innerRadius + blend)
                                gl_FragColor = mix(colorSource, colorBorder, ((dist - innerRadius) / blend))
                            else if (dist < outerRadius)
                                gl_FragColor = colorBorder
                            else if (dist < outerRadius + blend)
                                gl_FragColor = mix(colorBorder, colorEmpty, ((dist - outerRadius) / blend))
                            else
                                gl_FragColor = colorEmpty 

                            gl_FragColor = gl_FragColor * qt_Opacity
                    }
        "
    }

    PlasmaComponents.Label {
        id: usernameDelegate
        font.pointSize: Math.max(fontSize + 2, theme.defaultFont.pointSize + 2)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        height: implicitHeight
        width: constrainText ? parent.width : implicitWidth
        text: wrapper.name
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        color: config.color
        font.underline: wrapper.activeFocus
        font.family: config.font
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked()
    }

    Accessible.name: name
    Accessible.role: Accessible.Button

    function accessiblePressAction() {
        wrapper.clicked()
    }
}
