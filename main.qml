import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Window {
    visible: true
   // flags: Qt.Window | Qt.WindowTitleHint | Qt.CustomizeWindowHint | Qt.WindowCloseButtonHint
    width: 600
    height: 400

    Rectangle{
        anchors.fill: parent
        color: "darkgreen"
        Rectangle{
            id: activeArea
            anchors.centerIn: parent
            width: 600
            height: 400
            border.width: 1

            Rectangle{
                id: mainMenu
                enabled: !loaderArea.visible
                anchors.fill: parent
                Grid{
                    anchors.fill: parent
                    MinigamesButton{
                        text: "Snake"
                        onClicked: rootLoader.source = "Snake.qml"
                    }
                    MinigamesButton{
                        text: "2048"
                        onClicked: rootLoader.source = "Numbers.qml"
                    }
                    MinigamesButton{
                        text: "Tetris"
                        onClicked: rootLoader.source = "Tetris.qml"
                    }
                    MinigamesButton{
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
}

