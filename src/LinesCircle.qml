import QtQuick 2.5

Item{
    id:circle
    property int quadColor:mColor
    property int oldColor
    property Item quad:quadSource.itemAt(row*quadCount+col)
    property bool active:activeCircle===this
    onActiveChanged: activeAnimation.complete()

    property int col:mCol
    property int row:mRow

    property int newCol
    property int newRow
    property real tempScale

    function move(toRow,toCol){
        var data=activeModel.get(index)
        if(!pathExists({"row":data.mRow,"col":data.mCol},
                       {"row":toRow,"col":toCol}))
                return

        quad.filledBy=null
        col=data.mCol
        row=data.mRow
        data.mCol=toCol
        data.mRow=toRow
        newCol=toCol
        newRow=toRow
        linesGame.activeCircle=null
        quadSource.itemAt(toRow*quadCount+toCol).filledBy=this
        tempScale=scale
        moveAnimation.start()
        nextTurn()
    }
    function remove(){
        quad.filledBy=null
        removeAnimation.start()
    }
    function recolor(newColor){
        oldColor=quadColor
        var data=preserveModel.get(index)
        data.mColor=newColor
        quadColor=newColor
        recolorAnimation.start()
    }
    function freeze(){
        circle.enabled=false
        gameOverAnimation.start()
    }

    x:quad.x
    y:quad.y

    width:quadSize
    height:quadSize
    MouseArea{
        anchors.fill: parent
        onClicked: activeCircle = active ? null : circle
    }
    Rectangle{
        id:circleRect
        anchors.centerIn: parent
        color:colorPool[quadColor]
        property real animDist:0

        width:quadSize-2*circleMargin-animDist
        height:quadSize-2*circleMargin-animDist
        radius: quadSize/2
        //border.width: 1*sizeSet

        SequentialAnimation on scale {
            id:activeAnimation
            loops: Animation.Infinite
            PropertyAnimation{from:1;to:0.6;duration:1000}
            PropertyAnimation{from:0.6;to:1;duration:1000}
            //alwaysRunToEnd: true
            running:active
        }
        SequentialAnimation{
            id:moveAnimation
            running: false
            ParallelAnimation{
                ColorAnimation{target:circleRect;property:"color";from:colorPool[quadColor];to:baseColor;duration:250}
                NumberAnimation{target:circleRect;property:"scale";from:tempScale;to:0.5;duration:250}
            }
            PropertyAction{target:circle;property:"col";value:circle.newCol}
            PropertyAction{target:circle;property:"row";value:circle.newRow}
            ParallelAnimation{
                ColorAnimation{target:circleRect;property:"color";to:colorPool[quadColor];from:baseColor;duration:250}
                NumberAnimation{target:circleRect;property:"scale";from:0.5;to:1;duration:250}
            }
        }
        SequentialAnimation{
            id:removeAnimation
            running: false
            ColorAnimation{target:circleRect;property:"color";from:colorPool[quadColor];to:baseColor;duration:500}
            ScriptAction {script: {activeModel.remove(index)} }
        }
        ParallelAnimation{
            id:recolorAnimation
            running: false
            SequentialAnimation{
                ColorAnimation{target:circleRect;property:"color";from:colorPool[oldColor];to:baseColor;duration:250}
                ColorAnimation{target:circleRect;property:"color";from:baseColor;to:colorPool[quadColor];duration:250}
            }
            SequentialAnimation{
                NumberAnimation{target:circleRect;property:"scale";from:1;to:0.5;duration:250}
                NumberAnimation{target:circleRect;property:"scale";from:0.5;to:1;duration:250}
            }
        }
        ParallelAnimation{
            id:createAnimation
            running: false
            NumberAnimation{target:circleRect;property:"scale";from:0.5;to:1;duration:500}
            ColorAnimation{target:circleRect;property:"color";from:baseColor;to:colorPool[quadColor];duration:500}
        }
        ColorAnimation{
            id:gameOverAnimation
            running:false
            target:circleRect;property:"color";from:colorPool[quadColor];to:"darkgrey";duration:5000
        }
    }
    Component.onCompleted: {
        quad.filledBy=this
        createAnimation.start()
    }
}
