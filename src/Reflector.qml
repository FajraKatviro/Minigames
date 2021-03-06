import QtQuick 2.5
import Qt.labs.settings 1.0

Rectangle{
    id: gameArea
    color: "lightgrey"//Qt.rgba(0.8,0.8,0.8,1)

    property int ballSize: 20 * sizeSet
    property real garbageElementWidth: 100 * sizeSet
    property int frameDuration: 16
    property real speed: initialSpeed
    property int score
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    Settings{
        category: "Reflector"
        property alias highScore:gameArea.highScore
    }
    property bool paused: menuLine.paused
    property bool running: false
    property real lastTime: Date.now()

    property real initialBallX: ballSize * 10
    property real initialBallY: ballSize * 0.5 + 1
    property real initialBallDirection: Math.PI * 0.75
    property real initialSpeed: 5
    property var colorsPool:["green","yellow","red","pink","gold"]

    signal quitRequested
    property bool isGameOver:false

    function completeLoading(){
    }

    function newGame(){
        isGameOver=false
        score=0
        running=false
        speed=initialSpeed
        platform.opacity=1
        platform.collidable=true
        ball.x=initialBallX
        ball.y=initialBallY
        ball.direction=initialBallDirection
        garbageSource.clear()
        addRandom()
        running=true
    }

    function gameOver(){
        isGameOver=true
        platform.opacity=0
        platform.collidable=false
        //running=false
    }

    Timer{
        id:gameTimer
        interval: frameDuration
        running: !paused
        repeat: true
        onTriggered: ball.move()
    }

    Binding{
        target:mainControl
        property:"moveFrequency"
        value:400
    }
    Binding{
        target:mainControl
        property:"gestureTime"
        value:400
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
            property real direction: initialBallDirection
            x: initialBallX
            y: initialBallY
            Rectangle{
                x:-ballSize*0.5
                y:-ballSize*0.5
                width: ballSize
                height: ballSize
                radius: ballSize*0.5
                color:"blue"
            }

            function move(){
                var time=Date.now()
                var dt=time-lastTime
                lastTime=time
                if(!running){
                    return
                }

                var k=1.0
                var distance=speed*dt/frameDuration

                if(collide([bottomWall],distance,k,true)===-1){
                    gameOver()
                    return
                }

                var items=[leftWall,topWall,rightWall,platform]
                for(var i=0;i<garbage.count;++i)
                    items.push(garbage.itemAt(i))

                while(true){
                    k=collide(items,distance,k,false)
                    if(k<0.01){
                        return
                    }
                }
            }

            function collide(items,distance,k,interrupt){
                var x2=x+distance*Math.sin(direction)*k
                var y2=y-distance*Math.cos(direction)*k

                var nearestCollision
                for(var i in items){
                    var item=items[i]
                    if(!item.collidable)
                        continue
                    nearestCollision=item.checkCollision({"x1":x,"y1":y,"x2":x2,"y2":y2},nearestCollision)
                }
                if(nearestCollision===undefined){
                    if(interrupt){
                        return 1
                    }
                    x=x2
                    y=y2
                    return 0
                }else{
                    if(interrupt){
                        x=x2
                        y=y2
                        return -1
                    }
                    x+=distance*Math.sin(direction)*nearestCollision.k
                    y-=distance*Math.cos(direction)*nearestCollision.k
                    direction=2*(nearestCollision.d*Math.PI/180)+Math.PI-direction
                    nearestCollision.item.collided()
                    return k-nearestCollision.k
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
                onRightTick: platform.move(2*sizeSet)
                onLeftTick: platform.move(-2*sizeSet)
            }


            function move(direction){
                if(started && !paused)
                    xPos=Math.min(Math.max(xPos+10*2*direction,0),activeArea.width-width)
            }

            function collided(){
                colorAnimation.start()
            }
        }

        Obstacle{
            id:bottomWall
            height:ballSize * 0.15
            anchors{
                top:parent.bottom
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
                    speed+=initialSpeed*0.01
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

        StartPoint{
            id:tapToStartText
            onStartRequested: goPlay()
        }
    }

    function addRandom(){
        var offset=ballSize
        garbageSource.append({"mX":getRandomNumber(offset,activeArea.width-garbageElementWidth-offset),
                              "mY":getRandomNumber(offset,activeArea.height*0.5),
                              "mColor":colorsPool[getRandomNumber(0,colorsPool.length-1)]})
    }

    IngameMenu{
        id:menuLine

        caption: "Reflector"
        color: "blue"

        score: gameArea.score
        highScore: gameArea.highScore
        hint: "Tip: use swipe to move platform"

        showPauseButton: true

        onMenuButtonPressed: quitRequested()
        onRestartButtonPressed: newGame()

        onPausedChanged: lastTime=Date.now()
    }

    Component.onCompleted: {
        //newGame()
    }

    //enabled: false
    property bool started: false
    function goPlay(){
        tapToStartText.visible=false
        //enabled=true
        started=true
        menuLine.started=true
        newGame()
    }
}
