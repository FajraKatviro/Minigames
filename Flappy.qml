import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"

    property int obstacleSize: 55 * sizeSet
    property int baseOffset: 5 * sizeSet
    property real moveBoost: 200 * sizeSet
    property real dropBoost: 5 * sizeSet
    property int frameDuration: initialFrameDuration
    property int initialFrameDuration: 8000
    property int subFrameDuration: 16
    property real quadSize: 40 * sizeSet
    property int score: 0
    property bool paused: pauseBtn.checked
    property bool started: false
    onPausedChanged: if(paused)activeQuad.targetY=activeQuad.y

    property var colorPool:["red","blue","yellow","green","magenta"]

    signal quitRequested

    function newGame(){
        activeQuad.resetPosition()
        objects.model=undefined
        objects.model=obstacleSource
        score=0
        gameOverPlaceholder.visible=false
        started=true
    }

    function gameOver(){
        if(!started)
            return
        started=false
        gameOverPlaceholder.source=""
        activeArea.grabToImage(function(result){gameOverPlaceholder.source=result.url;});
        gameOverPlaceholder.visible=true
    }

    function moveUp(){
        if(paused || !started)
            return
        activeQuad.targetY=activeQuad.y-moveBoost
    }

    function moveDown(){
        activeQuad.targetY+=dropBoost
    }

    Connections{
        target: mainControl
        onTaped: moveUp()
    }

    Timer{
        interval: subFrameDuration
        onTriggered: moveDown()
        repeat: true
        running: !paused && started
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
                paused: gameArea.paused || !gameArea.started
            }
        }

        Item{
            id:mainArea
            anchors.fill: parent
            Rectangle{
                id:activeQuad
                anchors.horizontalCenter: parent.horizontalCenter
                width:quadSize
                height:quadSize
                color:"indigo"
                antialiasing:true
                property real targetY:(parent.height-height)*0.5
                y:targetY
                onYChanged: if(mainArea.height-y<height*0.6)gameOver()
                function resetPosition(){
                    moveBahavior.enabled=false
                    targetY=(parent.height-height)*0.5
                    rotation=0
                    moveBahavior.enabled=true
                }
                RotationAnimation on rotation {
                    from: 0;
                    to: 360;
                    duration: frameDuration*0.1
                    loops: Animator.Infinite
                    paused: gameArea.paused || !gameArea.started
                }
                Behavior on y{id:moveBahavior;NumberAnimation{duration: frameDuration*0.15}}
            }
            Repeater{
                id: objects
                delegate: Item{
                    property int objectIndex: index
                    property real objY: objectY
                    property real objH: objectH
                    property int objColor: objectColor
                    property bool passed: x<=mainArea.width*0.5
                    onPassedChanged:{
                        if(passed){
                            score+=1
                            colorAnimation.start()
                        }else{
                            colorAnimation.stop()
                            color=colorPool[objColor]
                        }
                    }

                    property color color: colorPool[objColor]

                    width: obstacleSize
                    height: mainArea.height

                    x: mainArea.width
                    y: 0

                    onXChanged: collide()

                    Rectangle{
                        id:topRect
                        height: objY * parent.height
                        anchors{
                            top:parent.top
                            left:parent.left
                            right:parent.right
                        }
                        color: parent.color
                    }
                    Rectangle{
                        id:bottomRect
                        height: objH * parent.height
                        anchors{
                            bottom:parent.bottom
                            left:parent.left
                            right:parent.right
                        }
                        color: parent.color
                    }

                    function collide(){
                        var halfSize=quadSize*0.5
                        var point=mapFromItem(mainArea,activeQuad.x+halfSize,activeQuad.y+halfSize)
                        if(point.x<0 || point.x>width)
                            return
                        if(point.y-topRect.height<halfSize ||
                           bottomRect.y-point.y<halfSize)
                                gameOver()
                    }

                    SequentialAnimation on x{
                        id:moveAnimation
                        running: true
                        paused: gameArea.paused || !gameArea.started
                        PauseAnimation{duration:frameDuration*(0.15+objectX)}
                        SequentialAnimation{
                            loops: Animation.Infinite
                            NumberAnimation{
                                from:mainArea.width
                                to:-width
                                duration: frameDuration
                            }
                            ScriptAction{
                                script: {
                                    var gate=getRandomFloat(0.3,0.4)
                                    objY=getRandomFloat(0.1,0.9-gate)
                                    objH=1-objY-gate
                                    objColor=getRandomNumber(0,colorPool.length-1)
                                }
                            }
                        }
                    }
                    ColorAnimation on color{
                        id:colorAnimation
                        from: colorPool[objColor]
                        to: "darkgrey"
                        duration: frameDuration*0.2
                        running: false
                    }
                }
                model: obstacleSource
            }
        }

        ListModel{
            id:obstacleSource
            ListElement{
                objectX:0
                objectY:0.3
                objectH:0.3
                objectColor:0
            }
            ListElement{
                objectX:0.33
                objectY:0.3
                objectH:0.3
                objectColor:1
            }
            ListElement{
                objectX:0.66
                objectY:0.3
                objectH:0.3
                objectColor:2
            }
        }

        Image{
            id:gameOverPlaceholder
            anchors.fill: parent
            visible:false
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
        newGame()
    }
}
