import QtQuick 2.5

Rectangle{
    clip:true
    color: "lightgrey"

    property int score:0

    signal quitRequested

    property int blockSize: 20 * sizeSet
    property int frameDuration: 500

    property int nextSource: 0
    property int currentSource: 0
    property var blockTemplates: [line,tBlock,leftLBlock,rightLBlock,rightSBlock,leftSBlock,block]

    property bool paused: pauseBtn.checked

    function completeLoading(){
    }

    Binding{
        target:mainControl
        property:"moveFrequency"
        value:16
    }
    Binding{
        target:mainControl
        property:"gestureTime"
        value:16
    }

    Item{
        anchors{
            top:parent.top
            left:parent.left
            bottom:parent.bottom
            right:mainArea.left
        }
        Column{
            anchors.centerIn: parent
            spacing: 40 * sizeSet
            MinigamesButton{
                text: "Menu"
                color: "yellow"
                onClicked: quitRequested()
            }
            MinigamesButton{
                text: "Restart"
                color: "yellow"
                onClicked: newGame()
            }
            MinigamesButton{
                id:pauseBtn
                text: "Pause"
                color: "yellow"
                checkable: true
            }
            Text{
                color:Qt.hsla(0.0,0.0,0.4,1.0)
                font.pointSize: 14 * sizeSet
                text: "Tip: use tap to rotate block"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                width:pauseBtn.width
            }
        }
    }

    Text{
        anchors{
            top:parent.top
            left:mainArea.right
            bottom:parent.verticalCenter
            right:parent.right
        }
        color:"darkgrey"
        text:"Score: " + score
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 20 * sizeSet
    }
    Rectangle{
        anchors{
            bottom:parent.bottom
            left:mainArea.right
            top:parent.verticalCenter
            right:parent.right
            margins:25 * sizeSet
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "grey" }
            GradientStop { position: 1.0; color: Qt.rgba(1,1,1,1) }
        }
        Loader{
            id:blockLoader
            anchors.centerIn: parent
            sourceComponent: blockTemplates[nextSource]
        }
    }

    Rectangle{
        id: mainArea
        //color: "lightgrey"
        gradient: Gradient {
            GradientStop { position: 0.0; color: "grey" }
            GradientStop { position: 1.0; color: Qt.rgba(1,1,1,1) }
        }
        property rect mainRect: Qt.rect(0,0,width,height)
        width: blockSize*10
        height: width*2
        anchors{
            //top:parent.top
            horizontalCenter: parent.horizontalCenter
            bottom:parent.bottom
        }

        Loader{
            id: detail
            x: blockSize*4
            sourceComponent: blockTemplates[currentSource]
        }
        Repeater{
            id: durtyArea
            delegate: filledDot
            model: filledDots
        }
    }

    Connections{
        target: mainControl
        onLeftMove: leftShift()
        onUpSwipe: rotateDetail()
        onRightMove: rightShift()
        onDownSwipe: {
            for(var i=0;i<10;++i)
                dropDetail()
        }
        onTaped: rotateDetail()
    }

    ListModel{
        id:filledDots
        function addPoint(p,color){
            var x = Math.floor(p.x / blockSize) * blockSize
            var y = Math.floor(p.y / blockSize) * blockSize
            append({"dotX":x,"dotY":y,"dotColor":color})
        }
    }

    Connections{
        target: detail.item
        onFreeze: {
            freezeBlock()
            checkLines()
            currentSource=-1
            currentSource=nextSource
            nextSource=Math.floor(Math.random()*7)
            if(detail.item.intersects()){
                freezeBlock()
                gameOver()
            }
        }
    }

    function freezeBlock(){
        var newDots = detail.item.getFreezePoints()
        for(var i=0;i<4;++i){
            filledDots.addPoint(newDots[i],detail.item.color)
        }
    }

    function checkLines(){
        var linesMap = {}
        for(var i=0;i<filledDots.count;++i){
            var dot=durtyArea.itemAt(i)
            if(linesMap[dot.yPos]===undefined)
                linesMap[dot.yPos]=[]
            linesMap[dot.yPos].push(i)
        }
        var deleteList = []
        var deletedRows = []
        for(i in linesMap){
            var row=linesMap[i]
            if(row.length===10){
                deletedRows.push(i)
                deleteList=deleteList.concat(row)
            }
        }
        if(deleteList.length){
            deleteList.sort(function(a,b){return a-b})
            for(i=deleteList.length-1;i>=0;--i){
                filledDots.remove(deleteList[i])
            }
            for(var d=0;d<filledDots.count;++d){
                dot=durtyArea.itemAt(d)
                for(i=0;i<deletedRows.length;++i){
                    if(dot.yPos<deletedRows[i])
                        dot.yPos+=blockSize
                }
            }
            var bonusScore = [10,22,38,80]
            score+=bonusScore[deletedRows.length-1]
        }
    }

    function newGame(){
        score=0
        filledDots.clear()
        currentSource=-1
        nextSource=Math.floor(Math.random()*7)
        currentSource=Math.floor(Math.random()*7)
        gameTimer.start()
    }

    function gameOver(){
        gameTimer.stop()
    }

    Timer{
        id:gameTimer
        interval: frameDuration
        repeat: true
        running: true
        onTriggered: dropDetail()
    }

    function rightShift(){
        if(paused)
            return
        move(blockSize,0)
        if(detail.item.intersects()){
            move(-blockSize,0)
        }
    }

    function leftShift(){
        if(paused)
            return
        move(-blockSize,0)
        if(detail.item.intersects()){
            move(blockSize,0)
        }
    }

    function rotateDetail(){
        if(paused)
            return
        detail.item.rotate(1)
        if(detail.item.intersects())
            detail.item.rotate(-1)
    }

    function dropDetail(){
        if(paused)
            return
        move(0,blockSize)
    }

    function move(directionX,directionY){
        detail.item.xPos+=directionX
        detail.item.yPos+=directionY
    }

    function intersected(rect1,rect2){
        if(rect1.x+rect1.width-rect2.x<0.1 ||
           rect2.x+rect2.width-rect1.x<0.1 ||
           rect1.y+rect1.height-rect2.y<0.1 ||
           rect2.y+rect2.height-rect1.y<0.1){
            return false
        }
        return true
    }
    function contained(rect1,rect2){
        if(rect1.x-rect2.x<0.1 &&
           rect1.y-rect2.y<0.1 &&
           rect1.x+rect1.width-(rect2.x+rect2.width)>-0.1 &&
           rect1.y+rect1.height-(rect2.y+rect2.height)>-0.1)
            return true
        return false
    }
    function isInEmptyArea(rX,rY,rWidth,rHeight){
        rX = Math.floor(rX / blockSize) * blockSize
        rY = Math.floor(rY / blockSize) * blockSize
        var myRect = detail.item.mapToItem(mainArea, rX, rY, rWidth, rHeight)
        if(!contained(mainArea.mainRect,myRect)){
            return false
        }
        for(var i=0;i<filledDots.count;++i){
            var dot = durtyArea.itemAt(i)
            if(intersected(Qt.rect(dot.x,dot.y,dot.width,dot.height),myRect)){
                return false
            }
        }
        return true
    }

    Component{
        id: line
        TetrisBlock{
            color: "red"
            transform: [
                Rotation{ origin.x: blockSize * 0.5; origin.y: blockSize * 1.5; angle: rotationAngle }
            ]
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                return false
            }
            function rotate(){
                rotationAngle = rotationAngle === 0 ? 270 : 0
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2 + blockSize),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2 + blockSize * 2),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2 + blockSize * 3)]
            }
            Rectangle{
                id:block1
                width: blockSize
                height: blockSize * 4
                color: colorValue
            }
        }
    }
    Component{
        id: tBlock
        TetrisBlock{
            color: "yellow"
            transform: [
                Rotation{ origin.x: blockSize * 1.5; origin.y: blockSize * 0.5; angle: rotationAngle }
            ]
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                if(!isInEmptyArea(block2.x,block2.y,block2.width,block2.height))
                    return true
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize*2,block1.y+blockSize/2)]
            }
            Rectangle{
                id: block1
                width: blockSize * 3
                height: blockSize
                color: colorValue
            }
            Rectangle{
                id: block2
                x: blockSize
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id: leftLBlock
        TetrisBlock{
            color: "lightgreen"
            transform: [
                Rotation{ origin.x: blockSize * 1.5; origin.y: blockSize * 1.5; angle: rotationAngle }
            ]
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                if(!isInEmptyArea(block2.x,block2.y,block2.width,block2.height))
                    return true
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize*2,block1.y+blockSize/2)]
            }
            Rectangle{
                id:block1
                width: blockSize * 3
                height: blockSize
                color: colorValue
            }
            Rectangle{
                id:block2
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id: rightLBlock
        TetrisBlock{
            color: "pink"
            transform: [
                Rotation{ origin.x: blockSize * 1.5; origin.y: blockSize * 1.5; angle: rotationAngle }
            ]
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                if(!isInEmptyArea(block2.x,block2.y,block2.width,block2.height))
                    return true
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize*2,block1.y+blockSize/2)]
            }
            Rectangle{
                id:block1
                width: blockSize * 3
                height: blockSize
                color: colorValue
            }
            Rectangle{
                id:block2
                x: blockSize * 2
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id: rightSBlock
        TetrisBlock{
            color: "green"
            transform: [
                Rotation{ origin.x: blockSize * 0.5; origin.y: blockSize * 1.5; angle: rotationAngle }
            ]
            function rotate(){
                rotationAngle = rotationAngle === 0 ? 270 : 0
            }
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height)){
                    return true
                }
                if(!isInEmptyArea(block2.x,block2.y,block2.width,block2.height)){
                    return true
                }
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2),
                        mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2+blockSize)]
            }
            Rectangle{
                id:block1
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
            Rectangle{
                id:block2
                x: blockSize
                y: blockSize
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id: leftSBlock
        TetrisBlock{
            color: "brown"
            transform: [
                Rotation{ origin.x: blockSize * 0.5; origin.y: blockSize * 1.5; angle: rotationAngle }
            ]
            function rotate(){
                rotationAngle = rotationAngle === 0 ? 270 : 0
            }
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                if(!isInEmptyArea(block2.x,block2.y,block2.width,block2.height))
                    return true
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2),
                        mapToItem(mainArea,block2.x+blockSize/2,block2.y+blockSize/2+blockSize)]
            }
            Rectangle{
                id:block1
                y: blockSize
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
            Rectangle{
                id:block2
                x: blockSize
                width: blockSize
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id: block
        TetrisBlock{
            color: "blue"
            transform: []
            function rotate(){ }
            function intersects(){
                if(!isInEmptyArea(block1.x,block1.y,block1.width,block1.height))
                    return true
                return false
            }
            function getFreezePoints(){
                return [mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize,block1.y+blockSize/2),
                        mapToItem(mainArea,block1.x+blockSize/2,block1.y+blockSize/2+blockSize),
                        mapToItem(mainArea,block1.x+blockSize/2+blockSize,block1.y+blockSize/2+blockSize)]
            }
            Rectangle{
                id:block1
                width: blockSize * 2
                height: blockSize * 2
                color: colorValue
            }
        }
    }

    Component{
        id:filledDot
        Rectangle{
            property var initialColor:dotColor
            property real yPos:dotY
            x:dotX
            y:yPos
            ColorAnimation on color{
                running: true
                from:initialColor
                to:Qt.rgba(0.25,0.26,0.25,1)
                duration: 2000
            }
            width:blockSize
            height:blockSize
            Behavior on y{
                NumberAnimation{duration: frameDuration}
            }
        }
    }

    Component.onCompleted: newGame()
}
