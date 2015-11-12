import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"//Qt.rgba(0.8,0.8,0.8,1)

    property int ballSize: 20 * sizeSet
    property int frameDuration: 400
    property real speed: ballSize
    property int score
    property bool paused: pauseBtn.checked

    signal quitRequested

    function newGame(){

    }

    Timer{
        id:gameTimer
        interval: frameDuration
        running: !paused
        repeat: true
        onTriggered: ball.move()
    }

//    Connections{
//        target: mainControl
//        onLeftSwipe: swapDirection(0,-1)
//        onRightSwipe: swapDirection(0,1)
//        onUpSwipe: swapDirection(-1,0)
//        onDownSwipe: swapDirection(1,0)
//    }

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
            id:ball
            property real posX: ballSize * 2
            property real posY: ballSize * 0.5
            property real direction: Math.PI * 0.75
            property var collisionPoints: []
            x: posX
            y: posY
            Rectangle{
                x:-ballSize*0.5
                y:-ballSize*0.5
                width: ballSize
                height: ballSize
                radius: ballSize*0.5
            }

            function move(){
                posX+=speed*Math.sin(direction)
                posY-=speed*Math.cos(direction)
                var items=[leftWall,topWall,rightWall]
                collide(items)
            }

            function collide(items){
                var collisionCount=0
                var cumulativeNormal=0.0
                for(var i in items){
                    for(var j in collisionPoints){
                        var collisionPoin=collisionPoints[j]
                        var point=ball.mapToItem(items[i],collisionPoin.x,collisionPoin.y)
                        if(items[i].contains(point)){
                            ++collisionCount;
                            cumulativeNormal+=collisionPoin.normal
                        }
                    }
                }
                if(collisionCount>0){
                    direction=2*(cumulativeNormal/collisionCount)+Math.PI-direction
                }
            }

            Behavior on x{NumberAnimation{duration: frameDuration}}
            Behavior on y{NumberAnimation{duration: frameDuration}}
            Component.onCompleted: {
                var segmentCount=16
                var segmentAngle=Math.PI*2/segmentCount
                var r=ballSize*0.5
                for(var i=0;i<segmentCount;++i){
                    var angle=segmentAngle*i
                    var point={"x":r*Math.sin(angle),
                               "y":r*(-Math.cos(angle)),
                               "normal":angle+Math.PI}
                    collisionPoints.push(point)
                }
            }
        }
        Item{
            id:rightWall
            width:ballSize
            anchors{
                top:parent.top
                bottom:parent.bottom
                left:parent.right
            }
        }
        Item{
            id:leftWall
            width:ballSize
            anchors{
                top:parent.top
                bottom:parent.bottom
                left:parent.right
            }
        }
        Item{
            id:topWall
            height:ballSize
            anchors{
                bottom:parent.top
                left:parent.left
                right:parent.right
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
                color:"blue"
                text: "Menu"
                onClicked: gameArea.quitRequested()
            }
            MinigamesButton{
                id:pauseBtn
                color:"blue"
                text: "Pause"
                checkable: true
            }
            MinigamesButton{
                color:"blue"
                text: "Restart"
                onClicked: newGame()
            }
        }
    }

    Component.onCompleted: {
        newGame()
    }
}
