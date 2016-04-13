import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

Button{
    id: btn
    property color color: "#999"
    property int buttonHeight: 100
    property int buttonWidth: 100
    property string image
    style: ButtonStyle{
        label: Text{
            text: control.text
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 10 * sizeSet
        }
        background: Item{
            implicitWidth: buttonWidth*sizeSet
            implicitHeight: buttonHeight*sizeSet
            Item{
                id: bg
                anchors.fill: parent
                states: [
                    State{
                        name: "pressed"
                        when: control.checked || control.pressed
                        PropertyChanges { target: effect; color: Qt.rgba(btn.color.r,btn.color.g,btn.color.b,0.65) }
                    }
                ]
                transitions:[
                    Transition {
                        from: "pressed"
                        ColorAnimation{ target:effect; duration: 2000 }
                    }
                ]
                Image {
                    id: img
                    source: btn.image
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }
                ColorOverlay {
                    id: effect
                    anchors.fill: parent
                    source: img
                    color: "transparent"
                }
            }
        }
    }
}
