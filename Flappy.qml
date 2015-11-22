import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"

    property int obstacleSize: 55 * sizeSet
    property int baseOffset: 5 * sizeSet
    property int frameDuration: initialFrameDuration
    property int initialFrameDuration: 8000
    property int score
    property bool paused: pauseBtn.checked

    property var colorPool:["red","blue","yellow","green","magenta"]

    signal quitRequested
    signal gameInited

    function newGame(){

    }

    function gameOver(){

    }

    function moveUp(){

    }

    Connections{
        target: mainControl
        onTaped: moveUp()
    }

    Rectangle{
        id:activeArea
        anchors{
            top:parent.top
            left:menuLine.right
            right:parent.right
            bottom:parent.bottom
        }
        color: Qt.rgba(0.9,0.9,0.9,1)

        clip: true

        Item{
            id:bg
            anchors.fill: parent
            Rectangle{
                id:leftBg
                anchors{
                    left:parent.left
                    bottom:parent.bottom
                }
                width: parent.width*0.28
                height: parent.height*0.09
                color:"lightgrey"
            }
            Rectangle{
                id:rightBg
                anchors{
                    right:parent.right
                    bottom:parent.bottom
                }
                width: parent.width*0.32
                height: parent.height*0.12
                color:"lightgrey"
            }
            Rectangle{
                id:centralBg
                anchors{
                    right:rightBg.left
                    left:leftBg.right
                    bottom:parent.bottom
                }
                height: parent.height*0.07
                color:"lightgrey"
            }
        }

        Item{
            id:parallax
            x:0
            width:parent.width*2
            anchors{
                top: parent.top
                bottom: parent.bottom
            }
            Row{
                anchors.centerIn: parent
                spacing:0
                Repeater{
                    model:2
                    delegate: Item{
                        width:activeArea.width
                        height: activeArea.height
                        Rectangle{
                            id:pFirst
                            color:"grey"
                            height:parent.height*0.2
                            width:parent.width*0.25
                            anchors{
                                left:parent.left
                                bottom:parent.bottom
                            }
                        }
                        Rectangle{
                            id:pSecond
                            color:"grey"
                            height:parent.height*0.1
                            width:parent.width*0.15
                            anchors{
                                left:pFirst.right
                                bottom:parent.bottom
                            }
                        }
                        Rectangle{
                            id:pThird
                            color:"grey"
                            height:parent.height*0.25
                            width:parent.width*0.17
                            anchors{
                                left:pSecond.right
                                bottom:parent.bottom
                            }
                        }
                        Rectangle{
                            id:pFourth
                            color:"grey"
                            height:parent.height*0.2
                            width:parent.width*0.22
                            anchors{
                                left:pThird.right
                                bottom:parent.bottom
                            }
                        }
                        Rectangle{
                            id:pFiveth
                            color:"grey"
                            height:parent.height*0.05
                            anchors{
                                left:pFourth.right
                                right:parent.right
                                bottom:parent.bottom
                            }
                        }
                    }
                }
            }
            NumberAnimation on x{
                from:0
                to:-activeArea.width
                duration: frameDuration*3
                running: true
                loops: Animation.Infinite
                paused: gameArea.paused
            }
        }

        Item{
            id:mainArea
            anchors.fill: parent
            Repeater{
                id: objects
                delegate: Rectangle{
                    property int objectIndex: index
                    property real objX: mainArea.width
                    property real objY: objectY*mainArea.height
                    property int objColor: objectColor
                    property bool passed: x<=mainArea.width*0.5
                    onPassedChanged:{
                        if(passed){
                            colorAnimation.start()
                        }else{
                            colorAnimation.stop()
                            color=colorPool[objColor]
                        }
                    }

                    width: obstacleSize
                    height: objectH*mainArea.height
                    color: colorPool[objColor]

                    x: objX
                    y: objY

                    SequentialAnimation on x{
                        id:moveAnimation
                        running: false
                        paused: gameArea.paused
                        PauseAnimation{duration:frameDuration*(1+objectX)}
                        NumberAnimation{
                            from:mainArea.width
                            to:-width
                            duration: frameDuration
                            loops: Animation.Infinite
                        }
                    }
                    ColorAnimation on color{
                        id:colorAnimation
                        from: colorPool[objColor]
                        to: "darkgrey"
                        duration: frameDuration*0.2
                        running: false
                    }
                    Connections{
                        target:gameArea
                        onGameInited: moveAnimation.start()
                    }
                }
                model: obstacleSource
            }
            Rectangle{
                id:activeQuad
                anchors.centerIn: parent
                width:80
                height:80
                color:"indigo"
            }
        }

        ListModel{
            id:obstacleSource
            ListElement{
                objectX:0
                objectY:0.0
                objectH:0.3
                objectColor:0
            }
            ListElement{
                objectX:0
                objectY:0.7
                objectH:0.3
                objectColor:0
            }
            ListElement{
                objectX:0.33
                objectY:0.0
                objectH:0.3
                objectColor:1
            }
            ListElement{
                objectX:0.33
                objectY:0.7
                objectH:0.3
                objectColor:1
            }
            ListElement{
                objectX:0.66
                objectY:0.0
                objectH:0.3
                objectColor:2
            }
            ListElement{
                objectX:0.66
                objectY:0.7
                objectH:0.3
                objectColor:2
            }
            ListElement{
                objectX:1
                objectY:0.0
                objectH:0.3
                objectColor:3
            }
            ListElement{
                objectX:1
                objectY:0.7
                objectH:0.3
                objectColor:3
            }
        }

    }

    Item{
        id: menuLine
        width: 200 * sizeSet
        anchors{
            left:parent.left
            top:parent.top
            bottom:parent.bottom
        }
        Column{
            anchors.centerIn: parent
            spacing: 20 * sizeSet
            Text{
                color:"darkgrey"
                font.pointSize: 20 * sizeSet
                text: "Score:" + score
            }
            MinigamesButton{
                color:"indigo"
                text: "Menu"
                onClicked: gameArea.quitRequested()
            }
            MinigamesButton{
                id:pauseBtn
                color:"indigo"
                text: "Pause"
                checkable: true
            }
            MinigamesButton{
                color:"indigo"
                text: "Restart"
                onClicked: newGame()
            }
        }
    }

    Component.onCompleted: {
        gameInited()
        newGame()
    }
}
