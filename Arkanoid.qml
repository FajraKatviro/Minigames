import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"//Qt.rgba(0.8,0.8,0.8,1)

    property int ballSize: 20 * sizeSet
    property real garbageElementWidth: 100 * sizeSet
    property int frameDuration: 400
    property real speed: ballSize
    property int score
    property bool paused: pauseBtn.checked
    property bool running: true

    property real initialBallX: ballSize * 10
    property real initialBallY: ballSize * 0.5 + 1
    property real initialBallDirection: Math.PI * 0.75
    property var colorsPool:["green","yellow","red","pink","gold"]

    signal quitRequested

    function newGame(){
        running=false
        platform.opacity=1
        ball.posX=initialBallX
        ball.posY=initialBallY
        ball.direction=initialBallDirection
        garbageSource.clear()
        addRandom()
        running=true
    }

    function gameOver(){
        platform.opacity=0
        running=false
    }

    Timer{
        id:gameTimer
        interval: frameDuration
        running: !paused
        repeat: true
        onTriggered: ball.move()
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
            id:ball
            property real posX: initialBallX
            property real posY: initialBallY
            property real direction: initialBallDirection
            property var collisionPoints: []
            x: posX
            y: posY
            onXChanged: checkCollisions()
            onYChanged: checkCollisions()
            Rectangle{
                x:-ballSize*0.5
                y:-ballSize*0.5
                width: ballSize
                height: ballSize
                radius: ballSize*0.5
                color:"blue"
            }

            function move(elapsed){
                posX=x+speed*Math.sin(direction)*elapsed
                posY=y-speed*Math.cos(direction)*elapsed
            }

            function checkCollisions(){
                if(!running){
                    return
                }
                if(collide([bottomWall])){
                    gameOver()
                    return
                }
                var items=[leftWall,topWall,rightWall,platform]
                for(var i=0;i<garbage.count;++i)
                    items.push(garbage.itemAt(i))
                var collisionNormal=collide(items)
                if(collisionNormal!==undefined){
                    direction=2*(collisionNormal)+Math.PI-direction
                    move()
                }
            }

            function collide(items){
                var collisionCount=0
                var cumulativeNormal=0.0
                for(var i in items){
                    var item=items[i]
                    if(!item.collidable)
                        continue
                    var collided=false
                    for(var j in collisionPoints){
                        var collisionPoin=collisionPoints[j]
                        var point=ball.mapToItem(item,collisionPoin.x,collisionPoin.y)
                        if(item.contains(point)){
                            if(!item.justCollided){
                                ++collisionCount;
                                cumulativeNormal+=collisionPoin.normal
                            }
                            collided=true
                        }
                    }
                    if(collided && !item.justCollided){
                        item.collided()
                    }
                    item.justCollided=collided
                }
                if(collisionCount>0){
                    return cumulativeNormal/collisionCount
                }
            }

            Behavior on x{enabled: gameArea.running; NumberAnimation{duration: frameDuration}}
            Behavior on y{enabled: gameArea.running; NumberAnimation{duration: frameDuration}}
            Component.onCompleted: {
                var segmentCount=14
                var segmentAngle=Math.PI*2/segmentCount
                var r=ballSize*0.5
                for(var i=0;i<segmentCount;++i){
                    var angle=segmentAngle*i
                    var point={"x":r*Math.sin(angle),
                               "y":r*(-Math.cos(angle)),
                               "normal":angle+Math.PI,
                               "ind":i}
                    collisionPoints.push(point)
                }
            }
        }
        Obstacle{
            id:rightWall
            width:ballSize
            anchors{
                top:parent.top
                bottom:parent.bottom
                left:parent.right
            }
        }
        Obstacle{
            id:leftWall
            width:ballSize
            anchors{
                top:parent.top
                bottom:parent.bottom
                right:parent.left
            }
        }
        Obstacle{
            id:topWall
            height:ballSize
            anchors{
                bottom:parent.top
                left:parent.left
                right:parent.right
            }
        }
        Obstacle{
            id: platform
            x: xPos
            height: ballSize
            width: 100 * sizeSet
            anchors.top: bottomWall.top
            anchors.topMargin: -ballSize * 0.15
            property real xPos:0
            Rectangle{
                anchors.fill: parent
                color: "grey"
                SequentialAnimation on color{
                    id:colorAnimation
                    running: false
                    ColorAnimation{from:"grey"; to:"blue"; duration:100}
                    ColorAnimation{from:"blue"; to:"grey"; duration:900}
                }
            }
            Behavior on x{NumberAnimation{duration:500}}
            Behavior on opacity{NumberAnimation{duration:1000}}
            Connections{
                target:mainControl
                onRightMove: platform.move(1)
                onLeftMove: platform.move(-1)
            }


            function move(direction){
                xPos=Math.min(Math.max(xPos+speed*2*direction,0),activeArea.width-width)
            }

            function collided(){
                colorAnimation.start()
            }
        }

        Obstacle{
            id:bottomWall
            height:ballSize * 0.15
            anchors{
                bottom:parent.bottom
                left:parent.left
                right:parent.right
            }
            Rectangle{
                anchors.fill: parent
                color:"darkgrey"
            }
        }
        Repeater{
            id:garbage
            model:garbageSource
            delegate: Obstacle{
                id:garbageInstance
                height:ballSize
                width:garbageElementWidth
                x: mX
                y: mY
                property var color: mColor
                function collided(){
                    //speed*=1.5
                    frameDuration*=0.95
                    score+=1
                    collidable=false
                    colAnimation.start()
                }
                Rectangle{
                    id:garbageInstanceRect
                    anchors.fill: parent
                    color: "grey"
                    SequentialAnimation{
                        id:colAnimation
                        running: false
                        ColorAnimation{target:garbageInstanceRect;property:"color" ;from:"grey"; to:garbageInstance.color; duration:100}
                        ParallelAnimation{
                            ColorAnimation{target:garbageInstanceRect;property:"color";from:garbageInstance.color; to:"grey"; duration:500}
                            NumberAnimation{target:garbageInstance;property:"opacity";from:1;to:0;duration:900}
                        }
                        onStopped: garbageSource.remove(index)
                    }
                }
            }
        }
        ListModel{
            id:garbageSource
        }
    }

    function addRandom(){
        var offset=ballSize
        garbageSource.append({"mX":getRandomNumber(offset,activeArea.width-garbageElementWidth-offset),
                              "mY":getRandomNumber(offset,activeArea.height*0.5),
                              "mColor":colorsPool[getRandomNumber(0,colorsPool.length-1)]})
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
