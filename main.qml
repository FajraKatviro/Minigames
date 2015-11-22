import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Window {
    id:rootWindow
    visible: true
   // flags: Qt.Window | Qt.WindowTitleHint | Qt.CustomizeWindowHint | Qt.WindowCloseButtonHint
    width: 600
    height: 400
    property real sizeSet: 2

    function getRandomNumber(from,upTo){
        return from + Math.floor(Math.random() * (upTo - from + 1) )
    }

    Rectangle{
        anchors.fill: parent
        color: "black"
        //color: "darkgreen"
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: Qt.rgba(0.2,0.21,0.21,1) }
//            GradientStop { position: 1.0; color: Qt.rgba(0.8,0.81,0.81,1) }
//        }

        MinigamesTouchArea{
            id:mainControl
            anchors.fill: parent
        }

        Rectangle{
            id: activeArea
            anchors.centerIn: parent
            width: 600*sizeSet
            height: 400*sizeSet
            scale: Math.min(rootWindow.width/width,rootWindow.height/height)
            border.width: 1

            Rectangle{
                id: mainMenu
                enabled: !loaderArea.visible
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "grey" }
                    GradientStop { position: 1.0; color: Qt.rgba(1,1,0.9,1) }
                }
                GridLayout{
                    anchors.fill: parent
                    anchors.margins: 20 * sizeSet
                    columns: 2
                    columnSpacing: 20 * sizeSet
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "green"
                        text: "Snake"
                        onClicked: rootLoader.source = "Snake.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "red"
                        text: "2048"
                        onClicked: rootLoader.source = "Numbers.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "yellow"
                        text: "Tetris"
                        onClicked: rootLoader.source = "Tetris.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "blue"
                        text: "Arkanoid"
                        onClicked: rootLoader.source = "Arkanoid.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "pink"
                        text: "Color lines"
                        onClicked: rootLoader.source = "ColorLines.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "indigo"
                        text: "Flappy quad"
                        onClicked: rootLoader.source = "Flappy.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        text: "Quit"
                        onClicked: Qt.quit()
                    }
                }
            }

            Rectangle{
                id:loaderArea
                visible: rootLoader.status === Loader.Ready
                anchors.fill: parent
                border.width: 1
                Loader{
                    id: rootLoader
                    anchors.fill: parent
                    anchors.margins: 2
                    focus: true
                }
                Connections{
                    target: rootLoader.item
                    onQuitRequested: rootLoader.source = ""
                }
            }
        }
    }
    Component.onCompleted: showFullScreen()
}

