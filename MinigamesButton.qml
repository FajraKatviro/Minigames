import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Button{
    id: btn
    property var color: "#999"
    //width: 175
    //height: 50
    style: ButtonStyle{
        background: Item{
            implicitWidth: 175*sizeSet
            implicitHeight: 50*sizeSet
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
