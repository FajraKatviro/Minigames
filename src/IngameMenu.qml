import QtQuick 2.5

Item{
    id: menuLine

    property bool showPauseButton:false
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
        Item{
            width:menuLine.width
            height: highscoreText.implicitHeight + scoreText.implicitHeight + 5*sizeSet
            Text{
                id:highscoreText
                anchors{
                    left:parent.left
                    right:parent.right
                    top:parent.top
                    leftMargin: 20*sizeSet
                }
                color:"darkgrey"
                font.pointSize: 14 * sizeSet
                text: "Highscore:" + highScore
            }
            Text{
                id:scoreText
                anchors{
                    left:parent.left
                    right:parent.right
                    top:highscoreText.bottom
                    leftMargin: 20*sizeSet
                }
                color:"darkgrey"
                font.pointSize: 14 * sizeSet
                text: "Score:" + score
            }
        }
        Text{
            width:menuLine.width
            color:Qt.hsla(0.0,0.0,0.4,1.0)
            font.pointSize: 14 * sizeSet
            text: hint
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
        Item{
            width:menuLine.width
            height: width
            Grid{
                anchors.centerIn: parent
                columns: 2
                spacing: 5*sizeSet
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
}
