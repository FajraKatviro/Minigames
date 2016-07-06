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
    property bool happyMode:happyBtn.checked

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
                    samples: 2 * radius
                    radius: 4
                    color: "black"
                    visible: false
                }
                Desaturate {
                    //visible: !happyMode
                    anchors.fill: headerGlow
                    source: headerGlow
                    desaturation: happyMode ? 0.4 : 0.9
                    transform: Scale { origin.x:header.width*0.5 ; origin.y: 0; xScale: 4}
                    //SequentialAnimation on desaturation {
                    //    NumberAnimation{from:0.8;to:1.2;duration:5000}
                    //    NumberAnimation{from:1.2;to:0.8;duration:5000}
                    //    running: true
                    //    loops: Animation.Infinite
                    //}
                }

                Row{
                    id: moodSwitcher
                    anchors{
                        top:header.bottom
                        topMargin: 10 * sizeSet
                        horizontalCenter:parent.horizontalCenter
                    }
                    //spacing: 20 * sizeSet
                    /*MainMenuButton{
                        color:"white"
                        image: "images/menu_theme.png"
                        anchors.verticalCenter: parent.verticalCenter
                        //text: "Ashes"
                        onClicked: happyMode = false
                        buttonHeight: 30
                        buttonWidth: 80
                    }*/

                    MainMenuButton{
                        id:happyBtn
                        color:"yellow"
                        image: happyMode ? "images/switcher_happy.png" : "images/switcher_ashes.png"
                        anchors.verticalCenter: parent.verticalCenter
                        //text: "Happy"
                        //onClicked: happyMode = !happyMode
                        buttonHeight: 40
                        buttonWidth: 80
                        checkable: true
                        ignoreMoodSwap: true
                        checked: true
                    }
                }

                Item{
                    anchors{
                        top:moodSwitcher.bottom
                        //topMargin: 5 * sizeSet
                        left:parent.left
                        right: parent.right
                        //rightMargin: 10 * sizeSet
                        //leftMargin: 10 * sizeSet
                        bottom:footer.top
                    }
                    GridLayout{
                        anchors.centerIn: parent
                        columns: 4
                        columnSpacing: 4 * sizeSet
                        rowSpacing: 4 * sizeSet
                        MainMenuButton{
                            color: "green"
                            //text: "Caterpillar"
                            image: "images/menu_caterpillar.png"
                            onClicked: rootLoader.source = "Caterpillar.qml"
                        }
                        MainMenuButton{
                            color: "red"
                            //text: "Numbers"
                            image: "images/menu_numbers.png"
                            onClicked: rootLoader.source = "Numbers.qml"
                        }
                        MainMenuButton{
                            color: "yellow"
                            //text: "Block puzzle"
                            image: "images/menu_block.png"
                            onClicked: rootLoader.source = "BlockPuzzle.qml"
                        }
                        MainMenuButton{
                            color: "blue"
                            text: "Reflection"
                            image: "images/menu_quad.png"
                            onClicked: rootLoader.source = "Reflector.qml"
                        }
                        MainMenuButton{
                            color: "magenta"
                            //text: "Color lines"
                            image: "images/menu_lines.png"
                            onClicked: rootLoader.source = "ColorLines.qml"
                        }
                        MainMenuButton{
                            color: "indigo"
                            //text: "Flappy quad"
                            image: "images/menu_quad.png"
                            onClicked: rootLoader.source = "Flappy.qml"
                        }
                        MainMenuButton{
                            color: "orange"
                            text: "Path finder"
                            image: "images/menu_quad.png"
                            onClicked: rootLoader.source = "Labirinth.qml"
                        }
                        MainMenuButton{
                            color: "brown"
                            text: "Tap defence"
                            image: "images/menu_quad.png"
                            onClicked: rootLoader.source = "Defence.qml"
                        }
                        Item{
                            id:startAdBanner
                            Layout.columnSpan: 4
                            Layout.preferredHeight: 50 * sizeSet// quitBtn.height
                            Layout.preferredWidth: 400 * sizeSet + 4 * sizeSet * 3 //quitBtn.width
                            visible: !loaderArea.loaded
                        }
                        /*MainMenuButton{
                            id:quitBtn
                            buttonHeight: 48
                            text: "Quit"
                            onClicked: Qt.quit()
                        }*/
                        enabled: rootLoader.status === Loader.Null
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
                            color:happyMode ? "white" : Qt.rgba(1.0,1.0,0.8,1)
                            text: " "// "by Fajra Katviro"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.italic: true
                            font.pointSize: 12 * sizeSet
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        /*Text{
                            color:Qt.rgba(1.0,1.0,0.8,1)
                            text:"special thanks to Artist inkognita"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.italic: true
                            font.pointSize: 10 * sizeSet
                            anchors.horizontalCenter: parent.horizontalCenter
                        }*/
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

