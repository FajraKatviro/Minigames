import QtQuick 2.5

Rectangle{
    width:quadSize
    height:quadSize
    color:baseColor
    border.width: 1*sizeSet
    radius: 2*sizeSet
    property Item filledBy
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


