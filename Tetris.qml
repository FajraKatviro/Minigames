import QtQuick 2.5

Rectangle{

    color:"lightgray"
    signal quitRequested

    property int blockSize: mainArea.width / 10
    property int frameDuration: 500

    property int nextSource: 0
    property int currentSource: 0
    property var blockTemplates: [line,tBlock,leftLBlock,rightLBlock,rightSBlock,leftSBlock,block]

    MinigamesButton{
        text: "Back to menu"
        onClicked: quitRequested()
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Rectangle{
        id: mainArea
        property rect mainRect: Qt.rect(0,0,width,height)
        width: 200
        height: width*2
        border.width: 1
        anchors{
            top:parent.top
            right:parent.right
            bottom:parent.bottom
        }

        Loader{
            id: detail
            sourceComponent: blockTemplates[currentSource]
        }
        Repeater{
            id: durtyArea
            delegate: filledDot
            model: filledDots
        }
        MinigamesTouchArea{
            anchors.fill: parent
            onLeftRequested: leftShift()
            onUpRequested: rotateDetail()
            onRightRequested: rightShift()
            onDownRequested: dropDetail()
        }
    }

    ListModel{
        id:filledDots
        function addPoint(p){
            var x = Math.floor(p.x / blockSize) * blockSize
            var y = Math.floor(p.y / blockSize) * blockSize
            append({"dotX":x,"dotY":y})
        }
    }

    Connections{
        target: detail.item
        onFreeze: {
            var newDots = detail.item.getFreezePoints()
            for(var i=0;i<4;++i){
                filledDots.addPoint(newDots[i])
            }
            checkLines()
            currentSource=-1
            currentSource=nextSource
            nextSource=Math.floor(Math.random()*7)
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
        }
    }

    Timer{
        interval: frameDuration
        repeat: true
        running: true
        onTriggered: dropDetail(false)
    }

    function rightShift(){
        move(blockSize,0)
        if(detail.item.intersects()){
            move(-blockSize,0)
        }
    }

    function leftShift(){
        move(-blockSize,0)
        if(detail.item.intersects()){
            move(blockSize,0)
        }
    }

    function rotateDetail(){
        detail.item.rotate(1)
        if(detail.item.intersects())
            detail.item.rotate(-1)
    }

    function dropDetail(){
        move(0,blockSize)
    }

    function move(directionX,directionY){
        detail.item.xPos+=directionX
        detail.item.yPos+=directionY
    }

    function intersected(rect1,rect2){
        if(rect1.x+rect1.width<=rect2.x ||
           rect2.x+rect2.width<=rect1.x ||
           rect1.y+rect1.height<=rect2.y ||
           rect2.y+rect2.height<=rect1.y)
            return false
        return true
    }
    function contained(rect1,rect2){
        if(rect1.x<=rect2.x &&
           rect1.y<=rect2.y &&
           rect1.x+rect1.width>=rect2.x+rect2.width &&
           rect1.y+rect1.height>=rect2.y+rect2.height)
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
                color: "red"
            }
        }
    }

    Component{
        id: tBlock
        TetrisBlock{
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
                color: "yellow"
            }
            Rectangle{
                id: block2
                x: blockSize
                width: blockSize
                height: blockSize * 2
                color: "yellow"
            }
        }
    }

    Component{
        id: leftLBlock
        TetrisBlock{
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
                color: "lightgreen"
            }
            Rectangle{
                id:block2
                width: blockSize
                height: blockSize * 2
                color: "lightgreen"
            }
        }
    }

    Component{
        id: rightLBlock
        TetrisBlock{
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
                color: "pink"
            }
            Rectangle{
                id:block2
                x: blockSize * 2
                width: blockSize
                height: blockSize * 2
                color: "pink"
            }
        }
    }

    Component{
        id: rightSBlock
        TetrisBlock{
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
                color: "green"
            }
            Rectangle{
                id:block2
                x: blockSize
                y: blockSize
                width: blockSize
                height: blockSize * 2
                color: "green"
            }
        }
    }

    Component{
        id: leftSBlock
        TetrisBlock{
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
                color: "brown"
            }
            Rectangle{
                id:block2
                x: blockSize
                width: blockSize
                height: blockSize * 2
                color: "brown"
            }
        }
    }

    Component{
        id: block
        TetrisBlock{
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
                color: "blue"
            }
        }
    }

    Component{
        id:filledDot
        Rectangle{
            property real yPos:dotY
            x:dotX
            y:yPos
            color:"darkgrey"
            width:blockSize
            height:blockSize
            Behavior on y{
                NumberAnimation{duration: frameDuration}
            }
        }
    }
}
