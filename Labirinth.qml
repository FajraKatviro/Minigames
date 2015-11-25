import QtQuick 2.5

Rectangle{
    id: gameArea
    color: "lightgrey"

    property real quadSize: labirinthArea.height/areaSize
    property int areaSize: 40
    property real zoomFactor: 2
    property int moveTime: 400
    property int slideTime: moveTime*4
    property int score: 0
    property int timeCapacity: initialTimeCapacity
    property int initialTimeCapacity: 60
    property int timeLapsed: 0

    property var colorPool:["orange",Qt.rgba(0,0,0,0),"black","green"]

    signal quitRequested

    function completeLoading(){
        newGame()
    }

    function newGame(){
        timeCapacity=initialTimeCapacity
        score=0
        loadLevel()
    }

    function gameOver(){
        mainTimer.stop()
    }

    function nextLevel(){
        loadLevel()
        ++score
        --timeCapacity
    }

    function loadLevel(){
        mainTimer.stop()
        activeQuad.direction=undefined
        animationPlaceholder.source=""
        labirinthArea.grabToImage(function(result){
            animationPlaceholder.source=result.url
            activeQuad.resetCol()
            generateLabirinth(activeQuad.row,activeQuad.col,getRandomNumber(0,areaSize-1),areaSize-1)
            newLevelAnimation.start()
            placeholderMove.start()
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
        console.log("labirinth generated")
        var factor=0.04
        var directionFactor=0.5
        var curRow=fromRow
        var curCol=fromCol
        var targetRow=toRow
        var targetCol=toCol
        var lastDirection=1

        var quads=[]
        for(var y=0;y<areaSize;++y){
            var row=[]
            for(var x=0;x<areaSize;++x){
                row.push({"visited":false,"filled":true})
            }
            quads.push(row)
        }

        function visitQuad(row,col){
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
            var randIndex=lastDirection
            while(directions.length>0){
                var d=directions[randIndex]
                directions.splice(randIndex,1)
                lastDirection=randIndex
                randIndex=getRandomNumber(0,directions.length-1)
                result=visitQuad(row+d.y,col+d.x) || result
            }
            return result
        }

        if(!visitQuad(curRow,curCol)){
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
        //console.log(f)
    }

    Timer{
        id:mainTimer
        interval: 1000
        repeat: true
        onTriggered:{
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

        Rectangle{
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
                    Rectangle{
                        id:activeQuad
                        width:quadSize*zoomFactor
                        height:quadSize*zoomFactor
                        visible: false
                        color:colorPool[0]
                        property int row:0
                        property int col:0
                        property var direction
                        onDirectionChanged: moveTimer.restart()
                        x:col*width
                        y:row*height
                        Behavior on x{id:xb; NumberAnimation{duration:moveTime;alwaysRunToEnd:true}}
                        Behavior on y{id:yb; NumberAnimation{duration:moveTime;alwaysRunToEnd:true}}
                        function resetCol(){
                            xb.enabled=false
                            col=0
                            xb.enabled=true
                        }
                        function move(dx,dy){
                            if(labirinthSource.getQuadInfo(row,col).objStatus===3){
                                nextLevel()
                                return true
                            }
                            var newRow=row+dy
                            var newCol=col+dx
                            var quadInfo=labirinthSource.getQuadInfo(newRow,newCol)
                            if(quadInfo!==undefined&&quadInfo.objStatus!==2){
                                col=newCol
                                row=newRow
                                return true
                            }
                            return false
                        }
                        Timer{
                            id:moveTimer
                            interval: moveTime
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered:{
                                if(parent.direction!==undefined){
                                    activeQuad.move(parent.direction.x,parent.direction.y)
                                }
                            }
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
        buildEmptyModel()
        //newGame()
    }
}
