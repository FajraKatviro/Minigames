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
    property bool ignoreMoodSwap: false

    style: ButtonStyle{
        id:style
        readonly property color greyscaled: Qt.rgba(0.35,0.35,0.35,0.9)
        readonly property real colorFactor:0.87
        readonly property color colored: Qt.rgba(btn.color.r*colorFactor,btn.color.g*colorFactor,btn.color.b*colorFactor,1.0)

        label: Text{
            text: control.text
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 10 * sizeSet
        }
        background: Item{
            implicitWidth: buttonWidth*sizeSet
            implicitHeight: buttonHeight*sizeSet
            Rectangle{
                id: bg
                anchors.fill: parent
                color: (happyMode && !ignoreMoodSwap) ? style.colored : style.greyscaled
                states: [
                    State{
                        name: "pressed"
                        when: control.checked || control.pressed
                        PropertyChanges { target: bg; color: (happyMode && !ignoreMoodSwap) ? style.greyscaled : style.colored }
                    }
                ]
                transitions:[
                    Transition {
                        from: "pressed"
                        ColorAnimation{ target:bg; duration: 2000 }
                    }
                ]
                Image {
                    id: img
                    source: btn.image
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
