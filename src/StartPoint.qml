import QtQuick 2.5

Item{
    id:lbl
    anchors.fill: parent
    Text{
        anchors.centerIn: parent
        text:isGameOver ? "Game over" : "Tap to start"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color:"darkgrey"
        style: Text.Outline
        font.italic: true
        font.pixelSize: 40 * sizeSet
    }
    signal startRequested
    MouseArea{
        anchors.fill: parent
        enabled:parent.visible
        onClicked:if(!started) parent.startRequested()
    }
    visible: false
    opacity:0
    states:[
        State{
            name: "active"
            when: isGameOver
            PropertyChanges {target:lbl; visible:true; opacity:1}
        },
        State{
            name: "notStarted"
            when: !started
            PropertyChanges {target:lbl; visible:true; opacity:1}
        }
    ]

    transitions:Transition{
        to:"active"
        NumberAnimation{property:"opacity";duration:2000}
    }
}
