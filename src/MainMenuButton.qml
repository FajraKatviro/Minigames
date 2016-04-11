import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button{
    id: btn
    property color color: "#999"
    //width: 175
    //height: 50
    property int buttonHeight: 100
    property int buttonWidth: 100
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
            Rectangle{
                id: bg
                anchors.fill: parent
                //rotation:270
                color: Qt.rgba(0.5,0.5,0.5,0.8)
                states: [
                    State{
                        name: "pressed"
                        when: control.checked || control.pressed
                        PropertyChanges{ target:bg; color: btn.color }
                    }
                ]
                transitions:[
                    Transition {
                        from: "pressed"
                        ColorAnimation{ target:bg; duration: 2000 }
                    }
                ]
            }
        }
    }
}
