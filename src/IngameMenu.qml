import QtQuick 2.5

Item{
    id: menuLine

    property bool showPauseButton:false
    property bool showExtraButton:false
    property color color
    property string caption

    signal menuButtonPressed
    //signal pauseButtonPressed
    signal restartButtonPressed
    signal optionButtonPressed
    signal hintButtonPressed

    property int highScore
    property int score
    property string hint
    property string optionButtonLabel
    readonly property alias paused:pauseButton.checked

    property bool started:false

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
            width:buttonsGrid.width
            height: 30 * sizeSet
            color: happyMode ? menuLine.color : Qt.hsla(0.0,0.0,0.4,1.0)
            //style: Text.Outline
            //styleColor: "black"
            font.bold:true
            font.pixelSize: 30 * sizeSet
            text: caption
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Rectangle{
            //color: Qt.rgba(0.9,0.9,0.9,1)
            width:buttonsGrid.width
            height: highscoreText.implicitHeight
            Text{
                id:highscoreText
                anchors.fill: parent
                color:Qt.hsla(0.0,0.0,0.2,1.0)
                //color:menuLine.color
                //style: Text.Outline
                //styleColor: "black"
                font.pixelSize: 14 * sizeSet
                text: "Highscore \n" + highScore
                lineHeight: 1.2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Rectangle{
            //color: Qt.rgba(0.9,0.9,0.9,1)
            width:buttonsGrid.width
            height: scoreText.implicitHeight
            Text{
                id:scoreText
                anchors.fill: parent
                color:Qt.hsla(0.0,0.0,0.2,1.0)
                //color:menuLine.color
                //style: Text.Outline
                //styleColor: "black"
                font.pixelSize: 14 * sizeSet
                text: "Score \n" + score
                lineHeight: 1.2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
        Text{
            width:buttonsGrid.width
            height: 40 * sizeSet
            color:Qt.hsla(0.0,0.0,0.4,1.0)
            font.pixelSize: 14 * sizeSet
            text: hint
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Item{
            width:buttonsGrid.width
            height: buttonsGrid.height
            Grid{
                id:buttonsGrid
                anchors.centerIn: parent
                columns: 2
                spacing: 5*sizeSet
                MainMenuButton{
                    id: menuButton
                    buttonHeight: 75
                    buttonWidth: 75
                    color:menuLine.color
                    image: "images/home.png"
                    onClicked: menuButtonPressed()
                }
                MainMenuButton{
                    id: pauseButton
                    buttonHeight: 75
                    buttonWidth: 75
                    color:menuLine.color
                    enabled: showPauseButton && started
                    image: !checked ? "images/play.png" : "images/pause.png"
                    checkable: true
                    visible: showPauseButton
                }
                MainMenuButton{
                    id: hintButton
                    buttonHeight: 75
                    buttonWidth: 75
                    color:menuLine.color
                    enabled: !showPauseButton && started
                    visible: !showPauseButton
                    image: "images/bang.png"
                    onClicked: hintButtonPressed()
                }
                MainMenuButton{
                    id: restartButton
                    buttonHeight: 75
                    buttonWidth: 75
                    enabled: started
                    color:menuLine.color
                    image: "images/restart.png"
                    onClicked: restartButtonPressed()
                }
                /*MainMenuButton{
                    id: optionButton
                    buttonHeight: 75
                    buttonWidth: 75
                    color:menuLine.color
                    enabled: showExtraButton && started
                    text: showExtraButton ? "Another restart" : ""
                    onClicked: optionButtonPressed()
                }*/
                MainMenuButton{
                    id: moodSwitchButton
                    buttonHeight: 75
                    buttonWidth: 75
                    color:menuLine.color
                    image: happyMode ? "images/happy.png" : "images/sad.png"
                    onClicked:swapHappyMode()
                }
            }
        }
    }
}
