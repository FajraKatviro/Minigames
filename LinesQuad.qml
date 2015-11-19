import QtQuick 2.5

Rectangle{
    width:quadSize
    height:quadSize
    color:baseColor
    border.width: 1*sizeSet
    radius: 2*sizeSet
    property int xPos
    property int yPos
    property Item filledBy
    function updateCachedPos(){
        var pos=mapToItem(mainArea,0,0)
        xPos=pos.x
        yPos=pos.y
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            if(activeCircle){
                var col=index%quadCount
                var row=(index-col)/quadCount
                activeCircle.move(row,col)
            }
        }
    }
}


