import QtQuick 2.5


Item{
    property real xPos: 0
    property real yPos: 0
    x: xPos
    y: yPos
    width:childrenRect.width
    height:childrenRect.height

    signal freeze

    property var color: "white"
    property var colorValue: color
    property real rotationAngle: 0

    function rotate(direction){
        rotationAngle+=90*direction
    }

    //SequentialAnimation on colorValue{
        //running: true
        //loops: Animation.Infinite
        //ColorAnimation { from: Qt.rgba(0.25,0.26,0.25,1); to: color; easing.type: Easing.OutQuad; duration: 1500 }
        //ColorAnimation { from: color; to: Qt.rgba(0.25,0.26,0.25,1); easing.type: Easing.InQuad; duration: 8000 }
    //}

    Behavior on y{
        NumberAnimation{duration: frameDuration}
    }

    onYChanged: {
        if(intersects())
            freeze()
    }
}

