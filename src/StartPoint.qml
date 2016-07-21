import QtQuick 2.5

Text{
    anchors.centerIn: parent
    text:"Tap to start"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color:"darkgrey"
    style: Text.Outline
    font.italic: true
    font.pixelSize: 40 * sizeSet
    signal startRequested
    MouseArea{
        anchors.fill: parent
        enabled:parent.visible
        onClicked: parent.startRequested()
    }
}
