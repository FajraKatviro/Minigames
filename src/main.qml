import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import "adctl/qml"

Window {
    id:rootWindow
    visible: true
   // flags: Qt.Window | Qt.WindowTitleHint | Qt.CustomizeWindowHint | Qt.WindowCloseButtonHint
    width: baseWidth
    height: baseHeight
    //property real sizeSet: 2
    property bool happyMode:false

    AdCtlLayer{
        startAdIOSId:"56d36d4a744b8a59008b456b"
        startAdAndroidId:"566c750ca114525a008b4569"
        startAdBanner:AdCtlBanner{
            item:startAdBanner
        }
    }

    function getRandomNumber(from,upTo){
        var result = from + Math.floor(Math.random() * (upTo - from + 1) )
        return result>upTo ? upTo : result<from ? from : result
    }
    function getRandomFloat(from,upTo){
        return Math.random() * (upTo - from) + from
    }


    Item{
        anchors.fill: parent
        Image {
            id: bg
            anchors.fill: parent
            source: happyMode ? "images/main_bg_happy.png" : "images/main_bg.png"
            fillMode: Image.PreserveAspectCrop
        }

        MinigamesTouchArea{
            id:mainControl
            anchors.fill: parent
        }

        Item{
            id: activeArea
            anchors.centerIn: parent
            width: baseWidth*sizeSet
            height: baseHeight*sizeSet
            scale: Math.min(rootWindow.width/width,rootWindow.height/height)

            Item{
                id: mainMenu
                enabled: !loaderArea.visible
                anchors.fill: parent

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
                Item{
                    id:footer
                    anchors{
                        bottom:parent.bottom
                        bottomMargin: 5*sizeSet
                        left:parent.left
                        right:parent.right
                    }
                    height:footerContent.implicitHeight
                    Column{
                        id:footerContent
                        anchors.centerIn: parent
                        Text{
                            color:Qt.rgba(0.2,0.2,0.2,1)
                            text:"by Fajra Katviro"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.italic: true
                            font.pointSize: 10 * sizeSet
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text{
                            color:Qt.rgba(0.2,0.2,0.2,1)
                            text:"special thanks to Artist inkognita"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.italic: true
                            font.pointSize: 6 * sizeSet
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Row{
                    anchors{
                        top:header.bottom
                        horizontalCenter:parent.horizontalCenter
                    }
                    spacing: 20 * sizeSet
                    MainMenuButton{
                        color:"white"
                        image: "images/menu_theme.png"
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Ashes"
                        onClicked: happyMode = false
                        buttonHeight: 75
                        buttonWidth: 75
                    }

                    GridLayout{
                        //anchors{
                            //top:header.bottom
                            //horizontalCenter:parent.horizontalCenter
                            //rightMargin: 20 * sizeSet
                            //leftMargin: 20 * sizeSet
                        //}
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 4 * sizeSet
                        rowSpacing: 4 * sizeSet
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "green"
                            //text: "Caterpillar"
                            image: "images/menu_caterpillar.png"
                            onClicked: rootLoader.source = "Caterpillar.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "red"
                            //text: "Numbers"
                            image: "images/menu_numbers.png"
                            onClicked: rootLoader.source = "Numbers.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "yellow"
                            //text: "Block puzzle"
                            image: "images/menu_block.png"
                            onClicked: rootLoader.source = "BlockPuzzle.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "blue"
                            text: "Reflection"
                            onClicked: rootLoader.source = "Reflector.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "pink"
                            //text: "Color lines"
                            image: "images/menu_lines.png"
                            onClicked: rootLoader.source = "ColorLines.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "indigo"
                            //text: "Flappy quad"
                            image: "images/menu_quad.png"
                            onClicked: rootLoader.source = "Flappy.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "orange"
                            text: "Path finder"
                            onClicked: rootLoader.source = "Labirinth.qml"
                        }
                        MainMenuButton{
                            Layout.rowSpan: 2
                            color: "brown"
                            text: "Tap defence"
                            onClicked: rootLoader.source = "Defence.qml"
                        }
                        Rectangle{
                            id:startAdBanner
                            Layout.preferredHeight: quitBtn.height
                            Layout.preferredWidth: quitBtn.width
                            color:"yellow"
                            Text{
                                anchors.fill: parent
                                text:"Banner here"
                            }
                        }
                        MainMenuButton{
                            id:quitBtn
                            buttonHeight: 48
                            text: "Quit"
                            onClicked: Qt.quit()
                        }
                        enabled: rootLoader.status === Loader.Null
                    }
                    MainMenuButton{
                        color:"orange"
                        image: "images/menu_theme.png"
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Happy"
                        onClicked: happyMode = true
                        buttonHeight: 75
                        buttonWidth: 75
                    }
                }
            }

            Rectangle{
                id:loaderArea
                property bool loaded:false
                visible: loaderArea.loaded
                anchors.fill: parent
                border.width: 1
                Loader{
                    id: rootLoader
                    anchors.fill: parent
                    anchors.margins: 2
                    focus: true
                    asynchronous: true
                    onLoaded: {
                        tt.start()
                    }
                }
                Timer{
                    id:tt
                    repeat: false
                    interval: 100
                    triggeredOnStart: false
                    onTriggered: {
                        loaderArea.loaded = true
                        rootLoader.item.completeLoading()
                    }
                }
                Connections{
                    target: rootLoader.item
                    onQuitRequested: {
                        loaderArea.loaded = false
                        rootLoader.source = ""
                    }
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

