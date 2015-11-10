import QtQuick 2.5

MouseArea{
    property int swipeLen: 20

    signal leftRequested
    signal upRequested
    signal rightRequested
    signal downRequested
    signal taped

    property int oldX
    property int oldY

    onPressed:{
        oldX=mouse.x
        oldY=mouse.y
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
            rightRequested()
        else if(deltaX<0)
            leftRequested()
        else if(deltaY<0)
            upRequested()
        else if(deltaY>0)
            downRequested()

        if(deltaX===0 && deltaY===0)
            taped()
    }
    focus: true
    Keys.onLeftPressed: leftRequested()
    Keys.onRightPressed: rightRequested()
    Keys.onUpPressed: upRequested()
    Keys.onDownPressed: downRequested()
}
