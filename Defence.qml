import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"

    property int obstacleSize: 55 * sizeSet
    property int frameDuration: initialFrameDuration
    property int initialFrameDuration: 8000
    property int score: 0
    property bool paused: pauseBtn.checked
    property bool started: false
    property bool inProgress: started && !paused

    property var colorPool:["red","blue","yellow","green","magenta"]

    signal quitRequested

    function newGame(){
        started=true
    }

    function gameOver(){
        if(!started)
            return
        started=false
    }

    function createCripper(){

    }

    function completeLoading(){
    }

    ListModel{
        id:cripperSource
    }

    Timer{
        interval: frameDuration
        onTriggered: createCripper()
        repeat: true
        running: inProgress
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
