import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button{
    id: btn
    property color color: "#999"
    //width: 175
    //height: 50
    width: 75*sizeSet
    height: 75*sizeSet
    style: ButtonStyle{
        label: Text{
            anchors.fill: parent
            text: control.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 12 * sizeSet
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        background: Item{
            //implicitWidth: 75*sizeSet
            //implicitHeight: 75*sizeSet
            Rectangle{
                id: bg
                height:parent.width
                width:parent.height
                anchors.centerIn: parent
                rotation:270
                color: "grey"
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
