import QtQuick 2.5

Rectangle{
    id: rootComponent
    color: "lightgreen"

    property int pointSize: 20
    property int frameDuration
    property var pointColors: ["yellow","red","grey"]
    property int directionX
    property int directionY
    property int speed: 20
    property var head
    property int tailIndex
    property int score
    property bool strictMode: true
    clip: true

    signal quitRequested
    signal requestCollect

    function getRandomNumber(from,upTo){
        return from + Math.floor(Math.random() * (upTo - from + 1) )
    }

    function newGame(longMode){
        strictMode = longMode
        frameDuration = 250
        gameOverPopup.visible = false
        score = 0
        directionX=1
        directionY=0
        objectModel.clear()
        objectModel.initHead(5,25)
        tailIndex = 3
        for(var i=1;i<=tailIndex;++i)
            objectModel.initBody(5,i,25)
        objectModel.addRandom()
        objectModel.addRandom()
        objectModel.addRandom()
        gameTimer.start()
    }

    function gameOver(){
        gameOverPopup.visible = true
        gameTimer.stop()
    }

    Timer{
        id: gameTimer
        interval: frameDuration
        repeat: true
        running: true
        onTriggered: {
            objects.itemAt(tailIndex).recalculate()
            rootComponent.requestCollect()
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

            onRankChanged: if(rank==1)head=this

            width: pointSize
            height: pointSize
            border.width: 1
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

            function recalculate(){
                if(rank==1){
                    objX+=speed*directionX
                    objY+=speed*directionY
                    if(objX<=0 || objY<=0 ||
                       objX>=rootComponent.width-pointSize ||
                       objY>=rootComponent.height-pointSize)
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
                            frameDuration*=0.95
                        objectModel.addRandom()
                    }
                }
            }

            Connections{
                target: rootComponent
                onRequestCollect:updateDots()
            }
        }
        model: objectModel
    }

    ListModel{
        id:objectModel

        function addRandom(){
            var offsetX = 5 + pointSize
            var offsetY = 5 + pointSize
            append({"objectX": offsetX + speed * getRandomNumber(0,Math.floor((rootComponent.width-pointSize*2)/speed)),
                    "objectY": offsetY + speed * getRandomNumber(0,Math.floor((rootComponent.height-pointSize*2)/speed)),
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

    Rectangle{
        anchors.right: parent.right
        anchors.top: parent.top
        border.width: 1
        width: 100
        height: 30
        Text{
            anchors.fill: parent
            anchors.margins: 3
            color: "red"
            font.pointSize: 16
            text: "Score:" + score
        }
    }

    function swapDirection(ver,hor){
        if((directionX*ver !== 0) ||
           (directionY*hor !== 0)){
                directionX = hor
                directionY = ver
        }
    }

    MinigamesTouchArea{
        anchors.fill: parent

        onLeftRequested: swapDirection(0,-1)
        onRightRequested: swapDirection(0,1)
        onUpRequested: swapDirection(-1,0)
        onDownRequested: swapDirection(1,0)
    }

    Rectangle{
        id: gameOverPopup
        anchors.centerIn: parent
        height: 300
        width: 400
        border.width: 1
        Text{
            id:gameOverText
            anchors{
                top:parent.top
                left:parent.left
                right:parent.right
            }
            height: 200
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Snake"
            font.pointSize: 40
            color: "red"
            style: Text.Outline
        }
        Item{
            anchors{
                top:gameOverText.bottom
                left:parent.left
                right:parent.right
                bottom:parent.bottom
                bottomMargin: 80
            }
            Row{
                anchors.centerIn: parent
                spacing: 25
                MinigamesButton{
                    text: "Long mode"
                    onClicked: newGame(true)
                }
                MinigamesButton{
                    text: "Fast mode"
                    onClicked: newGame(false)
                }
                MinigamesButton{
                    text: "Back to menu"
                    onClicked: rootComponent.quitRequested()
                }
            }
        }
    }

    Component.onCompleted: {
        //newGame()
    }
}
