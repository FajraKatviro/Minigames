import QtQuick 2.5

Item{
    id: menuLine

    property bool showPauseButton:true
    property bool showExtraButton:false

    signal menuButtonPressed
    //signal pauseButtonPressed
    signal restartButtonPressed
    signal optionButtonPressed

    property int highScore
    property int score
    property string hint
    property string optionButtonLabel
    readonly property alias paused:pauseButton.checked

    width: 200 * sizeSet
    anchors{
        left:parent.left
        top:parent.top
        bottom:parent.bottom
    }
    Column{
        anchors.centerIn: parent
        spacing: 10 * sizeSet
        Text{
            color:"darkgrey"
            font.pointSize: 14 * sizeSet
            text: "Highscore:" + highScore
        }
        Text{
            color:"darkgrey"
            font.pointSize: 14 * sizeSet
            text: "Score:" + score
        }
        Text{
            color:Qt.hsla(0.0,0.0,0.4,1.0)
            font.pointSize: 14 * sizeSet
            text: hint
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            width:pauseButton.width
        }
        Grid{
            width:200
            MinigamesButton{
                id: menuButton
                color:"green"
                text: "Menu"
                onClicked: menuButtonPressed()
            }
            MinigamesButton{
                id: pauseButton
                color:"green"
                enabled: showPauseButton
                text: showPauseButton ? "Pause" : ""
                checkable: true
            }
            MinigamesButton{
                id: restartButton
                color:"green"
                text: "Restart"
                onClicked: restartButtonPressed()
            }
            MinigamesButton{
                id: optionButton
                color:"green"
                enabled: showExtraButton
                text: showExtraButton ? "Another restart" : ""
                onClicked: optionButtonPressed()
            }
        }
    }
}
