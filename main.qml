import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import "adctl/qml"

Window {
    id:rootWindow
    visible: true
   // flags: Qt.Window | Qt.WindowTitleHint | Qt.CustomizeWindowHint | Qt.WindowCloseButtonHint
    width: 600
    height: 400
    property real sizeSet: 2

    AdCtlLayer{
    }

    function getRandomNumber(from,upTo){
        var result = from + Math.floor(Math.random() * (upTo - from + 1) )
        return result>upTo ? upTo : result<from ? from : result
    }
    function getRandomFloat(from,upTo){
        return Math.random() * (upTo - from) + from
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

                Text{
                    id:headerText
                    text:"Colors"
                    font.pointSize: 28 * sizeSet
                    //font.letterSpacing: 8*sizeSet
                    horizontalAlignment: Text.AlignHCenter
                    visible:false
                }

                LinearGradient{
                    id:header
                    anchors{
                        top:parent.top
                        topMargin: 5*sizeSet
                        horizontalCenter: parent.horizontalCenter
                    }
                    height: headerText.implicitHeight
                    width:headerText.implicitWidth
                    start:Qt.point(width*0.1,height*0.2)
                    end:Qt.point(width*0.9,height*0.8)
                    source:headerText
                    gradient: Gradient {
                        GradientStop {
                            position: 0.000
                            color: Qt.rgba(1, 0, 0, 1)
                        }
                        GradientStop {
                            position: 0.167
                            color: Qt.rgba(1, 1, 0, 1)
                        }
                        GradientStop {
                            position: 0.333
                            color: Qt.rgba(0, 1, 0, 1)
                        }
                        GradientStop {
                            position: 0.500
                            color: Qt.rgba(0, 1, 1, 1)
                        }
                        GradientStop {
                            position: 0.667
                            color: Qt.rgba(0, 0, 1, 1)
                        }
                        GradientStop {
                            position: 0.833
                            color: Qt.rgba(1, 0, 1, 1)
                        }
                        GradientStop {
                            position: 1.000
                            color: Qt.rgba(1, 0, 0, 1)
                        }
                    }
                    visible:false
                }
                Glow {
                    id:headerGlow
                    anchors.fill: header
                    source: header
                    //desaturation: 1.0
                    samples: 2 * radius
                    radius: 4
                    color: "black"
                    visible: false
                }
                Desaturate {
                    anchors.fill: headerGlow
                    source: headerGlow
                    desaturation: 1.0
                    transform: Scale { origin.x:header.width*0.5 ; origin.y: 0; xScale: 4}
                    SequentialAnimation on desaturation {
                        NumberAnimation{from:-0.2;to:2.2;duration:5000}
                        NumberAnimation{from:2.2;to:-0.2;duration:5000}
                        running: true
                        loops: Animation.Infinite
                    }
                }
                Text{
                    id:footer
                    anchors{
                        bottom:parent.bottom
                        bottomMargin: 5*sizeSet
                        left:parent.left
                        right:parent.right
                    }
                    color:Qt.rgba(0.3,0.3,0.3,1)
                    text:"by Fajra Katviro"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.italic: true
                    font.pointSize: 10 * sizeSet
                }

                GridLayout{
                    anchors{
                        top:header.bottom
                        left:parent.left
                        right:parent.right
                        bottom:footer.top
                        rightMargin: 20 * sizeSet
                        leftMargin: 20 * sizeSet
                    }
                    columns: 2
                    columnSpacing: 20 * sizeSet
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "green"
                        text: "Caterpillar"
                        onClicked: rootLoader.source = "Caterpillar.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "red"
                        text: "Numbers"
                        onClicked: rootLoader.source = "Numbers.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "yellow"
                        text: "Block puzzle"
                        onClicked: rootLoader.source = "BlockPuzzle.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "blue"
                        text: "Reflection"
                        onClicked: rootLoader.source = "Reflector.qml"
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
                        color: "orange"
                        text: "Path finder"
                        onClicked: rootLoader.source = "Labirinth.qml"
                    }
                    MinigamesButton{
                        Layout.fillWidth: true
                        color: "brown"
                        text: "Tap defence"
                        onClicked: rootLoader.source = "Defence.qml"
                    }
                    MinigamesButton{
                        id:quitBtn
                        Layout.fillWidth: true
                        //Layout.columnSpan: 2
                        text: "Quit"
                        onClicked: Qt.quit()
                    }
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.preferredHeight: quitBtn.height
                        color:"yellow"
                        Text{
                            anchors.fill: parent
                            text:"Banner here"
                        }
                    }
                    enabled: rootLoader.status === Loader.Null
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
                    asynchronous: true
                    onLoaded: item.completeLoading()
                }
                Connections{
                    target: rootLoader.item
                    onQuitRequested: rootLoader.source = ""
                }
            }
            Text{
                anchors.fill: parent
                visible:rootLoader.status === Loader.Loading
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Loading..."
                color:"darkgrey"
                style: Text.Outline
                font.italic: true
                font.pointSize: 40 * sizeSet
            }
            Text{
                id:gameOverLabel
                anchors.fill: parent
                visible:false
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Game over"
                color:"darkgrey"
                style: Text.Outline
                font.italic: true
                font.pointSize: 40 * sizeSet
                opacity: 0
                states:State{
                    name: "active"
                    when:rootLoader.status===Loader.Ready && rootLoader.item.isGameOver
                    PropertyChanges {target:gameOverLabel; visible:true; opacity:1}
                }
                transitions:Transition{
                    to:"active"
                    NumberAnimation{property:"opacity";duration:2000}
                }
            }
        }
    }
    Component.onCompleted: showFullScreen()
}

