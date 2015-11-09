import QtQuick 2.5


Item{
    property real xPos: 0
    property real yPos: 0
    x: xPos
    y: yPos

    signal freeze

    property real rotationAngle: 0

    function rotate(direction){
        rotationAngle+=90*direction
    }
    function isInEmptyArea(rX,rY,rWidth,rHeight){
        rX = Math.floor(rX / blockSize) * blockSize
        rY = Math.floor(rY / blockSize) * blockSize
        var myRect = mapToItem(mainArea, rX, rY, rWidth, rHeight)
        if(!contained(mainArea.mainRect,myRect))
            return false
        for(var i=0;i<filledDots.count;++i){
            var dot = durtyArea.itemAt(i)
            if(intersected(Qt.rect(dot.x,dot.y,dot.width,dot.height),myRect)){
                return false
            }
        }
        return true
    }

    Behavior on y{
        NumberAnimation{duration: frameDuration}
    }

    onYChanged: {
        if(intersects())
            freeze()
    }
}

