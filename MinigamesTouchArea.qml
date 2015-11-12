import QtQuick 2.5

MouseArea{
    property int swipeLen: 20 * sizeSet
    property int moveLen: 30 * sizeSet

    signal leftMove
    signal upMove
    signal rightMove
    signal downMove

    signal leftSwipe
    signal upSwipe
    signal rightSwipe
    signal downSwipe

    signal taped

    property int oldX
    property int oldY
    property int oldHoverX
    property int oldHoverY

    onPressed:{
        oldX=mouse.x
        oldY=mouse.y
        oldHoverX=mouse.x
        oldHoverY=mouse.y
    }
    onMouseXChanged:{
        var dist=mouseX-oldHoverX
        if(dist>=moveLen){
            oldHoverX=mouseX
            rightMove()
        }else if(-dist>=moveLen){
            oldHoverX=mouseX
            leftMove()
        }
    }
    onMouseYChanged:{
        var dist=mouseY-oldHoverY
        if(dist>=moveLen){
            oldHoverY=mouseY
            downMove()
        }else if(-dist>=moveLen){
            oldHoverY=mouseY
            upMove()
        }
    }

    onReleased:{
        var deltaX=mouse.x-oldX
        var deltaY=mouse.y-oldY
        if(Math.abs(deltaX)<swipeLen)deltaX=0
        if(Math.abs(deltaY)<swipeLen)deltaY=0
        if(Math.abs(deltaY)>=Math.abs(deltaX))
            deltaX=0
        else
            deltaY=0

        if(deltaX>0)
            rightSwipe()
        else if(deltaX<0)
            leftSwipe()
        else if(deltaY<0)
            upSwipe()
        else if(deltaY>0)
            downSwipe()

        if(deltaX===0 && deltaY===0)
            taped()
    }
    focus: true
    Keys.onLeftPressed: leftSwipe()
    Keys.onRightPressed: rightSwipe()
    Keys.onUpPressed: upSwipe()
    Keys.onDownPressed: downSwipe()
}
