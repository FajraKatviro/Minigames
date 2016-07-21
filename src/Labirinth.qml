import QtQuick 2.5
import Qt.labs.settings 1.0

Rectangle{
    id: gameArea
    color: "lightgrey"

    property real quadSize: labirinthArea.height/areaSize
    property int areaSize: 40
    property real zoomFactor: 2
    property int moveTime: 400
    property int slideTime: moveTime*4
    property int score: 0
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    Settings{
        category: "Labirinth"
        property alias highScore:gameArea.highScore
    }
    property int timeCapacity: initialTimeCapacity
    property int initialTimeCapacity: 120
    property int timeLapsed: 0
    property bool gameStarted:true
    property bool paused:menuLine.paused

    property var colorPool:["orange",Qt.rgba(0,0,0,0),"black","green"]

    signal quitRequested
    property bool isGameOver:false

    function completeLoading(){
        //newGame()
    }

    Binding{
        target:mainControl
        property:"moveFrequency"
        value:moveTime
    }
    Binding{
        target:mainControl
        property:"gestureTime"
        value:moveTime
    }

    function newGame(){
        isGameOver=false
        timeCapacity=initialTimeCapacity
        score=0
        loadLevel()
        gameStarted=true
    }

    function gameOver(){
        isGameOver=true
        mainTimer.stop()
        gameStarted=false
        timeOutAnimation.start()
    }

    function nextLevel(){
        loadLevel()
        ++score
        --timeCapacity
    }

    function loadLevel(){
        mainTimer.stop()
        animationPlaceholder.source=""
        labirinthArea.grabToImage(function(result){
            animationPlaceholder.source=result.url
            activeQuad.resetCol()
            generateLabirinth(activeQuad.row,activeQuad.col,getRandomNumber(0,areaSize-1),areaSize-1)
            newLevelAnimation.start()
            placeholderMove.start()
            timeAnimation.stop()
            timeAnimation.start()
            timeLapsed=0
            mainTimer.start()
            activeQuad.visible=true
        })
    }

    function buildEmptyModel(){
        for(var y=0;y<areaSize;++y){
            for(var x=0;x<areaSize;++x){
                labirinthSource.append({"row":y,"col":x,"objStatus":1})
            }
        }
    }

    function generateLabirinth(fromRow,fromCol,toRow,toCol){
        var factor=0.04
        var directionFactor=0.5
        var curRow=fromRow
        var curCol=fromCol
        var targetRow=toRow
        var targetCol=toCol

        var quads=[]
        for(var y=0;y<areaSize;++y){
            var row=[]
            for(var x=0;x<areaSize;++x){
                row.push({"visited":false,"filled":true})
            }
            quads.push(row)
        }

        var pendingChecks = []

        function visitQuad(row,col,lastDirection){
            if(row===targetRow && col===targetCol){
                quads[row][col].filled=false
                return true
            }
            if(row<0 || col<0 || row>=areaSize || col>=areaSize)
                return false
            var curQuad=quads[row][col]
            if(curQuad.visited)
                return false
            curQuad.visited=true
            var directions=[{"x":0,"y":-1},
                            {"x":1,"y":0},
                            {"x":0,"y":1},
                            {"x":-1,"y":0}]
            var directionIndexes=[0,1,2,3]
            var neibourSpace=0
            for(var n in directions){
                var neibourRow=row+directions[n].y
                var neibourCol=col+directions[n].x
                if( neibourCol>=0 &&
                    neibourRow>=0 &&
                    neibourCol<areaSize &&
                    neibourRow<areaSize &&
                    !quads[neibourRow][neibourCol].filled){
                        ++neibourSpace
                }
            }
            if(neibourSpace>1){
                if(Math.random()<factor){
                    curQuad.filled=false
                }
                return false
            }
            curQuad.filled=false
            var result=false
            if(Math.random()<directionFactor){
                lastDirection=getRandomNumber(0,directions.length-1)
            }
            var randIndex=directionIndexes.indexOf(lastDirection)
            var revArray = []
            while(directionIndexes.length>0){
                lastDirection=directionIndexes[randIndex]
                var d=directions[lastDirection]
                directionIndexes.splice(randIndex,1)
                randIndex=getRandomNumber(0,directionIndexes.length-1)
                //result=visitQuad(row+d.y,col+d.x,lastDirection) || result
                //avoid recursion:
                revArray.push({"row":row+d.y,"col":col+d.x,"dir":lastDirection})
            }
            revArray.reverse()
            pendingChecks = pendingChecks.concat(revArray)

            return result
        }

        /*if(!visitQuad(curRow,curCol,1)){
            console.log("Unable build labirinth")
            return
        }*/ //avoid recursion

        var finalResult = visitQuad(curRow,curCol,1)
        while(pendingChecks.length>0){
            var nextCheck=pendingChecks.pop()
            finalResult = visitQuad(nextCheck.row,nextCheck.col,nextCheck.dir) || finalResult
        }

        if(!finalResult){
            console.log("Unable build labirinth")
            return
        }

        var i=0
        //var f=0
        for(y=0;y<areaSize;++y){
            for(x=0;x<areaSize;++x){
                labirinthSource.get(i).objStatus=quads[y][x].filled?2:1
                ++i
                //if(quads[y][x].filled)
                //    ++f
            }
        }
        labirinthSource.getQuadInfo(toRow,toCol).objStatus=3
    }

    Timer{
        id:mainTimer
        interval: 1000
        repeat: true
        onTriggered:{
            if(gameArea.paused)
                return

            if(timeLapsed<timeCapacity){
                timeLapsed+=1
            }else{
                gameOver()
            }
        }
    }

    ListModel{
        id:labirinthSource
        function getQuadInfo(row,col){
            if(row<0||col<0||row>=areaSize||col>=areaSize)
                return undefined
            return get(row*areaSize+col)
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
        color: "slategrey"

        clip: true

        Item{
            id:timeoutIndicator
            //color:Qt.rgba(0.3,0.3,0.3,1)
            height:30*sizeSet
            width:labirinthArea.width
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
                Behavior on width{NumberAnimation{duration:1000}}
            }
        }

        Item{
            id:labirinthArea
            anchors{
                top:timeoutIndicator.bottom
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: height
            clip:true

            Image{
                id:animationPlaceholder
                anchors{
                    top:parent.top
                    bottom:parent.bottom
                }
                width:parent.width
                NumberAnimation on x{
                    id:placeholderMove
                    from:0
                    to:-labirinthArea.width
                    duration: slideTime
                }
            }
            Item{
                anchors{
                    top:parent.top
                    bottom:parent.bottom
                }
                width:parent.width
                NumberAnimation on x{
                    id:newLevelAnimation
                    from:labirinthArea.width
                    to:0
                    duration:slideTime
                    running: false
                }
                Rectangle{
                    id:mainArea
                    width: quadSize*areaSize*zoomFactor
                    height: quadSize*areaSize*zoomFactor
                    x: Math.max(labirinthArea.width-width,Math.min(0,-activeQuad.x+labirinthArea.width*0.5))
                    y: Math.max(labirinthArea.height-height,Math.min(0,-activeQuad.y+labirinthArea.height*0.5))
                    ColorAnimation on color{
                        id:timeAnimation
                        from:"white"
                        to:"#555"
                        duration:timeCapacity*1000
                        running: false
                    }
                    ColorAnimation on color{
                        id:timeOutAnimation
                        from:"#555"
                        to:"black"
                        duration:1000
                        running:false
                    }
                    Rectangle{
                        id:activeQuad
                        width:quadSize*zoomFactor
                        height:quadSize*zoomFactor
                        visible: false
                        color:colorPool[0]
                        property int row:0
                        property int col:0
                        property var direction:{"x":1,"y":0}
                        property var prevDirection:{"x":1,"y":0}
                        //onDirectionChanged: moveTimer.restart()
                        x:col*width
                        y:row*height
                        Behavior on x{id:xb; NumberAnimation{duration:moveTime;alwaysRunToEnd:true}}
                        Behavior on y{id:yb; NumberAnimation{duration:moveTime;alwaysRunToEnd:true}}
                        function resetCol(){
                            xb.enabled=false
                            col=0
                            xb.enabled=true
                        }
                        function turn(dx,dy){
                            direction={"x":dx,"y":dy}
                        }
                        function move(){
                            if(!gameStarted || paused)
                                return
                            if(labirinthSource.getQuadInfo(row,col).objStatus===3){
                                nextLevel()
                                return true
                            }
                            var dx=direction.x
                            var dy=direction.y
                            var newRow=row+dy
                            var newCol=col+dx
                            var quadInfo=labirinthSource.getQuadInfo(newRow,newCol)
                            if(quadInfo!==undefined&&quadInfo.objStatus!==2){
                                col=newCol
                                row=newRow
                                prevDirection={"x":dx,"y":dy}
                                return true
                            }
                            newRow=row+prevDirection.y
                            newCol=col+prevDirection.x
                            quadInfo=labirinthSource.getQuadInfo(newRow,newCol)
                            if(quadInfo!==undefined&&quadInfo.objStatus!==2){
                                col=newCol
                                row=newRow
                                return true
                            }
                            var suggestedDirections=[]
                            if(dx===0){
                                suggestedDirections.push({"x":1,"y":0})
                                suggestedDirections.push({"x":-1,"y":0})
                            }else{
                                suggestedDirections.push({"x":0,"y":-1})
                                suggestedDirections.push({"x":0,"y":1})
                            }
                            var autoDirection
                            for(var i=0;i<2;++i){
                                newRow=row+suggestedDirections[i].y
                                newCol=col+suggestedDirections[i].x
                                quadInfo=labirinthSource.getQuadInfo(newRow,newCol)
                                if(quadInfo!==undefined&&quadInfo.objStatus!==2){
                                    if(autoDirection!==undefined)
                                        return false
                                    autoDirection={"x":suggestedDirections[i].x,"y":suggestedDirections[i].y}
                                }
                            }
                            if(autoDirection!==undefined){
                                col+=autoDirection.x
                                row+=autoDirection.y
                                direction=autoDirection
                                prevDirection=autoDirection
                                return true
                            }
                            return false
                        }
//                        function swapDirection(ver,hor){
//                            if(direction===undefined||hor!==direction.x||ver!==direction.y){
//                                direction={"x":hor,"y":ver}
//                            }
//                        }
//                        Timer{
//                            id:moveTimer
//                            interval: moveTime
//                            running: true
//                            repeat: true
//                            triggeredOnStart: true
//                            onTriggered:{
//                                if(parent.direction!==undefined){
//                                    activeQuad.move(parent.direction.x,parent.direction.y)
//                                }
//                            }
//                        }
                        Connections{
                            target:mainControl
                            onLeftSwipe: activeQuad.turn(-1,0)
                            onRightSwipe: activeQuad.turn(1,0)
                            onUpSwipe: activeQuad.turn(0,-1)
                            onDownSwipe: activeQuad.turn(0,1)
                            onLeftTick: activeQuad.move()
                            onRightTick: activeQuad.move()
                            onUpTick: activeQuad.move()
                            onDownTick: activeQuad.move()
                        }
                    }
                    Repeater{
                        id: objects
                        model: labirinthSource
                        delegate: Rectangle{
                            property real objRow: row
                            property real objCol: col
                            property int objColor: objStatus
                            visible: objColor>0
                            color: colorPool[objColor]
                            width: quadSize*zoomFactor
                            height: quadSize*zoomFactor
                            x: col*width
                            y: row*height
                        }
                    }
                }
            }
        }

        StartPoint{
            id:tapToStartText
            onStartRequested: goPlay()
        }
    }

    IngameMenu{
        id:menuLine

        caption: "Path finder"
        color: "orange"

        score: gameArea.score
        highScore: gameArea.highScore
        hint: "Tip: go to East. Use swipe to turn and tap to stop"

        showPauseButton: true

        onMenuButtonPressed: gameArea.quitRequested()
        onRestartButtonPressed: newGame()

    }

    Component.onCompleted: {
        buildEmptyModel()
        //newGame()
    }

    //enabled: false
    function goPlay(){
        tapToStartText.visible=false
        //enabled=true
        menuLine.started=true
        newGame()
    }
}
