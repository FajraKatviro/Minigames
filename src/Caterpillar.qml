import QtQuick 2.5
import Qt.labs.settings 1.0

Rectangle{
    id: gameArea
    color: "lightgrey"//Qt.rgba(0.8,0.8,0.8,1)

    property int pointSize: 20 * sizeSet
    property int baseOffset: 5 * sizeSet
    property int frameDuration: initialFrameDuration
    property int initialFrameDuration: 400
    property var pointColors: ["yellow","green","grey"]
    property int directionX
    property int directionY
    property int speed: pointSize
    property var head
    property int tailIndex
    property int score
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    Settings{
        category: "Caterpillar"
        property alias highScore:gameArea.highScore
    }
    property bool strictMode: true
    property bool paused: menuLine.paused

    signal quitRequested
    signal requestCollect
    property bool isGameOver:false

    function completeLoading(){
    }

    function newGame(longMode){
        isGameOver=false
        strictMode = longMode
        frameDuration = initialFrameDuration
        score = 0
        directionX=1
        directionY=0
        objectModel.clear()
        objectModel.initHead(baseOffset,pointSize+baseOffset)
        tailIndex = 3
        for(var i=1;i<=tailIndex;++i)
            objectModel.initBody(baseOffset,i,pointSize+baseOffset)
        objectModel.addRandom()
        objectModel.addRandom()
        objectModel.addRandom()
        score = 0
        gameTimer.start()
    }

    function gameOver(){
        isGameOver=true
        gameTimer.stop()
    }

    function swapDirection(ver,hor){
        if((directionX*ver !== 0) ||
           (directionY*hor !== 0)){
                directionX = hor
                directionY = ver
        }
    }

    Connections{
        target: mainControl
        onLeftSwipe: swapDirection(0,-1)
        onRightSwipe: swapDirection(0,1)
        onUpSwipe: swapDirection(-1,0)
        onDownSwipe: swapDirection(1,0)
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

        Timer{
            id: gameTimer
            interval: frameDuration
            repeat: true
            running: true
            onTriggered: {
                if(!gameArea.paused){
                    objects.itemAt(tailIndex).recalculate()
                    gameArea.requestCollect()
                }
            }
        }

        Repeater{
            id: objects
            delegate: Rectangle{
                property int rank: objectRank
                property int objectIndex: index
                property int prevSegment: previousSegment
                property real objX: objectX
                property real objY: objectY

                onRankChanged: {
                    if(rank==1)head=this
                    else if(rank==2)greyAnimation.start()
                }

                width: pointSize
                height: pointSize
                //border.width: 1
                radius: strictMode ? 0 : pointSize/2

                x: objX
                y: objY
                color: pointColors[rank]

                Behavior on x{
                    NumberAnimation{ duration: frameDuration }
                }
                Behavior on y{
                    NumberAnimation{ duration: frameDuration }
                }
                ColorAnimation on color{
                    id: greyAnimation
                    running: false
                    to: "grey"
                    duration: 1000
                }

                function recalculate(){
                    if(rank==1){
                        objX+=speed*directionX
                        objY+=speed*directionY
                        if(objX<=0 || objY<=0 ||
                           objX>=activeArea.width-pointSize ||
                           objY>=activeArea.height-pointSize)
                                gameOver()
                    }else if(rank==2){
                        var prev = objects.itemAt(prevSegment)
                        if(!strictMode){
                            prev.recalculate()
                            var prevX = prev.objX
                            var prevY = prev.objY
                            var deltaX = prevX - objX
                            var deltaY = prevY - objY
                            var k = 1 - pointSize / (Math.abs(deltaX) + Math.abs(deltaY))
                            if(k>0){
                                objX += deltaX*k
                                objY += deltaY*k
                            }
                        }else{
                            objX = prev.objX
                            objY = prev.objY
                            prev.recalculate()
                        }

                        deltaX = head.objX - objX
                        deltaY = head.objY - objY
                        k = pointSize / (Math.abs(deltaX) + Math.abs(deltaY))
                        if(k>=1.1){
                            gameOver()
                        }
                    }
                }

                function updateDots(){
                    if(rank==0){
                        var deltaX = head.objX - objX
                        var deltaY = head.objY - objY
                        var k = pointSize / (Math.abs(deltaX) + Math.abs(deltaY))
                        if(k>=1.1){
                            var prev = objects.itemAt(prevSegment)
                            prevSegment = tailIndex
                            objX = prev.objX
                            objY = prev.objY
                            tailIndex = objectIndex
                            rank = 2
                            ++score
                            if(!strictMode)
                                frameDuration*=0.99
                            objectModel.addRandom()
                        }
                    }
                }

                Connections{
                    target: gameArea
                    onRequestCollect:updateDots()
                }
            }
            model: objectModel
        }

        ListModel{
            id:objectModel

            function addRandom(){
                var offsetX = baseOffset + pointSize
                var offsetY = baseOffset + pointSize
                append({"objectX": offsetX + speed * getRandomNumber(0,Math.floor((activeArea.width-pointSize*2-offsetX)/speed)),
                        "objectY": offsetY + speed * getRandomNumber(0,Math.floor((activeArea.height-pointSize*2-offsetY)/speed)),
                        "objectRank":0,
                        "previousSegment":0})
            }
            function initHead(baseX,y){
                append({"objectX": baseX,
                        "objectY": y,
                        "objectRank":1,
                        "previousSegment":0})
            }
            function initBody(baseX,idx,y){
                append({"objectX": baseX - idx * pointSize,
                        "objectY": y,
                        "objectRank":2,
                        "previousSegment":idx-1})
                ++score
            }
        }

    }

    IngameMenu{
        id:menuLine
        showExtraButton: true
        showPauseButton: true

        score: gameArea.score
        highScore: gameArea.highScore
        hint:"Tip: use swipe to turn"

        onMenuButtonPressed: gameArea.quitRequested()
       //onPauseButtonPressed: paused=!paused
        onRestartButtonPressed: newGame(true)
        onOptionButtonPressed: newGame(false)
    }

/*    Item{
        id: menuLine
        width: 200 * sizeSet
        anchors{
            left:parent.left
            top:parent.top
            bottom:parent.bottom
        }
        Column{
            anchors.centerIn: parent
            spacing: 10 * sizeSet
            MinigamesButton{
                color:"green"
                text: "Menu"
                onClicked: gameArea.quitRequested()
            }
            MinigamesButton{
                id:pauseBtn
                color:"green"
                text: "Pause"
                checkable: true
            }
            Text{
                color:"darkgrey"
                font.pointSize: 14 * sizeSet
                text: "Highscore:" + highScore
            }
            Text{
                color:"darkgrey"
                font.pointSize: 14 * sizeSet
                text: "Score:" + score
            }
            MinigamesButton{
                color:"green"
                text: "Restart"
                onClicked: newGame(true)
            }
            MinigamesButton{
                color:"green"
                text: "Another restart"
                onClicked: newGame(false)
            }
            Text{
                color:Qt.hsla(0.0,0.0,0.4,1.0)
                font.pointSize: 14 * sizeSet
                text: "Tip: use swipe to turn"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                width:pauseBtn.width
            }
        }
    }
*/
    Component.onCompleted: {
        newGame(true)
    }
}
