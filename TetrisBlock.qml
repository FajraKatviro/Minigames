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

    Behavior on y{
        NumberAnimation{duration: frameDuration}
    }

    onYChanged: {
        if(intersects())
            freeze()
    }
}

