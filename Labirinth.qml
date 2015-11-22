import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"

    property int quadSize: labirinthArea.height/areaSize
    property int areaSize: 20
    property real moveTime: 400
    property int score: 0
    property int timeCapacity: initialTimeCapacity
    property int initialTimeCapacity: 60
    property real timeLapsed: 0

    property var colorPool:["orange","black"]

    signal quitRequested

    function newGame(){
        loadLevel()
    }

    function gameOver(){
        mainTimer.stop()
    }

    function loadLevel(){
        mainTimer.stop()
        animationPlaceholder.source=""
        mainArea.grabToImage(function(result){animationPlaceholder.source=result.url})
        newLevelAnimation.start()
        mainTimer.start()
    }

    function move(hor,ver){

    }

    Timer{
        id:mainTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered:{
            if(timeLapsed>0){
                timeLapsed-=1
            }else{
                gameOver()
            }
        }
    }

    Connections{
        target: mainControl
        onRightSwipe: move(1,0)
    }

    ListModel{
        id:labirinthSource
        ListElement{
            row:2
            col:0
            objStatus:1
        }
    }

    Rectangle{
        id:activeArea
        anchors{
            left:menuLine.right
            right:parent.right
            top:parent.top
            bottom: parent.bottom
        }
        color: Qt.rgba(0.9,0.9,0.9,1)

        clip: true

        Rectangle{
            id:timeoutIndicator
            color:"white"
            height:30*sizeSet
            anchors{
                top:parent.top
                horizontalCenter: parent.horizontalCenter
            }
            Rectangle{
                color:"red"
                anchors{
                    top:parent.top
                    left:parent.left
                    bottom:parent.bottom
                }
                width: parent.width*(1-timeLapsed/timeCapacity)
            }
        }

        Item{
            id:labirinthArea
            anchors{
                bottom: parent.bottom
                top:timeoutIndicator.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: height

            Image{
                id:animationPlaceholder
                width: mainArea.width
                height: mainArea.height
            }

            Item{
                id:mainArea
                width: quadSize*areaSize
                height: quadSize*areaSize
                Repeater{
                    id: objects
                    model: labirinthSource
                    delegate: Rectangle{
                        property real objRow: row
                        property real objCol: col
                        property int objColor: objStatus
                        visible: objColor>0
                        color: colorPool[objColor]
                        width: quadSize
                        height: quadSize
                        x: col*quadSize
                        y: row*quadSize
                    }
                }
                Rectangle{
                    id:activeQuad
                    width:quadSize
                    height:quadSize
                    color:colorPool[0]
                    property var targetPoint:{"x":0,"y":0}
                    x:targetPoint.x
                    y:targetPoint.y
                    Behavior on x{NumberAnimation{duration:moveTime}}
                    Behavior on y{NumberAnimation{duration:moveTime}}
                }
                NumberAnimation on x{
                    id:newLevelAnimation
                    from:labirinthArea.width
                    to:0
                    duration:moveTime
                    running: false
                }
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
                color:"orange"
                text: "Menu"
                onClicked: gameArea.quitRequested()
            }
            MinigamesButton{
                color:"orange"
                text: "Restart"
                onClicked: newGame()
            }
        }
    }

    Component.onCompleted: {
        newGame()
    }
}
