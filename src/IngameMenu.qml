import QtQuick 2.5

Item{
    id: menuLine

    property bool showPauseButton:false
    property bool showExtraButton:false
    property color color

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
            height: scoreColumn.implicitHeight
            Column{
                id:scoreColumn
                anchors.centerIn: parent
                spacing: 10 * sizeSet
                Rectangle{
                    color: Qt.rgba(0.9,0.9,0.9,1)
                    width:buttonsGrid.width
                    height: highscoreText.implicitHeight
                    Text{
                        id:highscoreText
                        anchors.fill: parent
                        color:menuLine.color
                        style: Text.Outline
                        styleColor: "black"
                        font.pointSize: 14 * sizeSet
                        text: "Highscore \n" + highScore
                        lineHeight: 1.2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                Rectangle{
                    color: Qt.rgba(0.9,0.9,0.9,1)
                    width:buttonsGrid.width
                    height: scoreText.implicitHeight
                    Text{
                        id:scoreText
                        anchors.fill: parent
                        color:menuLine.color
                        style: Text.Outline
                        styleColor: "black"
                        font.pointSize: 14 * sizeSet
                        text: "Score \n" + score
                        lineHeight: 1.2
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        Text{
            width:menuLine.width
            height: 40 * sizeSet
            color:Qt.hsla(0.0,0.0,0.4,1.0)
            font.pointSize: 14 * sizeSet
            text: hint
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Item{
            width:menuLine.width
            height: buttonsGrid.height
            Grid{
                id:buttonsGrid
                anchors.centerIn: parent
                columns: 2
                spacing: 5*sizeSet
                MinigamesButton{
                    id: menuButton
                    color:menuLine.color
                    text: "Menu"
                    onClicked: menuButtonPressed()
                }
                MinigamesButton{
                    id: pauseButton
                    color:menuLine.color
                    enabled: showPauseButton
                    text: showPauseButton ? "Pause" : ""
                    checkable: true
                }
                MinigamesButton{
                    id: restartButton
                    color:menuLine.color
                    text: "Restart"
                    onClicked: restartButtonPressed()
                }
                MinigamesButton{
                    id: optionButton
                    color:menuLine.color
                    enabled: showExtraButton
                    text: showExtraButton ? "Another restart" : ""
                    onClicked: optionButtonPressed()
                }
            }
        }
    }
}
