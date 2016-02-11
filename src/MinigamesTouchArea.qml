import QtQuick 2.5

MouseArea{
    property int swipeLen: 20 * sizeSet
    property int longSwipe: swipeLen
    property int gestureTime: 400
    property int moveFrequency: 400
    //property int moveLen: 30 * sizeSet

    signal leftMove
    signal upMove
    signal rightMove
    signal downMove

    signal leftSwipe
    signal upSwipe
    signal rightSwipe
    signal downSwipe

    signal leftTick
    signal upTick
    signal rightTick
    signal downTick

//    onLeftMove: leftGesture()
//    onLeftSwipe: leftGesture()
//    onRightMove: rightGesture()
//    onRightSwipe: rightGesture()
//    onUpMove: upGesture()
//    onUpSwipe: upGesture()
//    onDownMove: downGesture()
//    onDownSwipe: downGesture()

//    signal leftGesture
//    signal upGesture
//    signal rightGesture
//    signal downGesture

    signal taped

    property int oldX
    property int oldY
    property int oldHoverX
    property int oldHoverY
    property var touchTime
    property var direction:{"x":0,"y":0}
    property var lastMove:Date.now()
    Timer{
        id:moveTimer
        interval: moveFrequency
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered:{
            if(direction.x>0)
                rightTick()
            else if(direction.x<0)
                leftTick()
            else if(direction.y>0)
                downTick()
            else if(direction.y<0)
                upTick()
        }
    }
    onPressed:{
        direction={"x":0,"y":0}
        oldX=mouse.x
        oldY=mouse.y
        oldHoverX=mouse.x
        oldHoverY=mouse.y
        touchTime=Date.now()
    }
    onPositionChanged:{
        var dt=Date.now()-touchTime
        if(dt<gestureTime)
            return
        dt=Date.now()-lastMove
        if(dt<moveFrequency)
            return
        var deltaX=mouse.x-oldHoverX
        var deltaY=mouse.y-oldHoverY
        if(Math.abs(deltaX)<swipeLen)deltaX=0
        if(Math.abs(deltaY)<swipeLen)deltaY=0
        if(Math.abs(deltaY)>=Math.abs(deltaX)){
            deltaX=0
        }else{
            deltaY=0
        }

        if(deltaX!==0||deltaY!==0){
            oldHoverX=mouse.x
            oldHoverY=mouse.y
            lastMove=Date.now()
            if(deltaX>0)
                rightMove()
            else if(deltaX<0)
                leftMove()
            else if(deltaY<0)
                upMove()
            else if(deltaY>0)
                downMove()
        }
    }
    onReleased:{
//        var dt=Date.now()-touchTime
//        if(dt>gestureTime)
//            return
        var deltaX=mouse.x-oldX
        var deltaY=mouse.y-oldY
        if(Math.abs(deltaX)<longSwipe)deltaX=0
        if(Math.abs(deltaY)<longSwipe)deltaY=0
        if(Math.abs(deltaY)>=Math.abs(deltaX)){
            deltaX=0
            deltaY=deltaY>0?1:deltaY<0?-1:0
        }else{
            deltaY=0
            deltaX=deltaX>0?1:deltaX<0?-1:0
        }

        if(deltaX!==0||deltaY!==0){
            if(direction.x!==deltaX||direction.y!==deltaY){
                if(deltaX>0)
                    rightSwipe()
                else if(deltaX<0)
                    leftSwipe()
                else if(deltaY<0)
                    upSwipe()
                else if(deltaY>0)
                    downSwipe()
                direction={"x":deltaX,"y":deltaY}
                moveTimer.restart()
            }
        }else{
            taped()
        }
    }
    focus: true
    Keys.onLeftPressed: leftSwipe()
    Keys.onRightPressed: rightSwipe()
    Keys.onUpPressed: upSwipe()
    Keys.onDownPressed: downSwipe()
}
