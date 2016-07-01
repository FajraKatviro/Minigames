import QtQuick 2.5
import Qt.labs.settings 1.0

Rectangle{
    id: gameArea
    color: "lightgrey"

    property real obstacleSize: activeArea.width/areaSize
    property real obstacleHeight: obstacleSize*0.5
    property int areaSize: 5
    property real blackHolePos: obstacleHeight*3
    property int frameDuration: Math.max(200,initialFrameDuration-framePenalty*50)
    property int initialFrameDuration: 1500
    property int framePenalty: score/50
    property int score: 0
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    property bool isGameOver:false
    Settings{
        category: "Defence"
        property alias highScore:gameArea.highScore
    }
    property bool paused: menuLine.paused
    property bool started: false
    property bool inProgress: started && !paused

    property var crippersPool:[
        {objectColor:0.0,     objectSpeed:200,    objectDurability:1,   boostChance:0.5},
        {objectColor:0.0,     objectSpeed:100,    objectDurability:2,   boostChance:0.3},
        {objectColor:0.0,     objectSpeed:120,    objectDurability:3,   boostChance:0.4},
        {objectColor:0.0,     objectSpeed:50,     objectDurability:4,   boostChance:0.2},
        {objectColor:0.0,     objectSpeed:20,     objectDurability:5,   boostChance:0.1}
    ]

    signal quitRequested

    function newGame(){
        isGameOver=false
        score=0
        cripperSource.clear()
        for(var i=0;i<areaSize;++i)
            wallSource.itemAt(i).reset()
        started=true
    }

    function gameOver(){
        if(!started)
            return
        isGameOver=true
        started=false
    }

    function createCripper(){
        var cripperType=crippersPool[getRandomNumber(0,crippersPool.length-1)]
        var boosted=Math.random()<cripperType.boostChance ? getRandomNumber(1,3) : 0
        if(score<30)
            boosted=0
        cripperSource.append({"objectColor":cripperType.objectColor,
                              "objectSpeed":cripperType.objectSpeed,
                              "objectDurability":cripperType.objectDurability,
                              "objectCol":getRandomNumber(0,areaSize-1),
                              "boostedMode":boosted})
    }

    function completeLoading(){
        newGame()
    }

    function useHint(col,hintType){
        if(hintType===1)
            hints.itemAt(col).animateCannon()
        else if(hintType===2)
            hints.itemAt(col).animateFortification()
        else if(hintType===3)
            hints.itemAt(col).animateBlackhole()
    }

    function clearColumn(col){
        for(var i=0;i<crippers.count;++i){
            var cripper=crippers.itemAt(i)
            if(cripper.col===col){
                cripper.slash(cripper.durability)
            }
        }
    }

    ListModel{
        id:cripperSource
    }

    function getWall(col){
        return wallSource.itemAt(col)
    }

    function checkBlackHole(y,col){
        if(y>=blackHolePos+obstacleHeight*0.5 &&
           y<blackHolePos+obstacleHeight*2.0  &&
           hints.itemAt(col).blackHoleEnabled){
                return true
        }
        return false
    }

    Timer{
        interval: frameDuration
        onTriggered: createCripper()
        repeat: true
        running: inProgress
    }

    Rectangle{
        id:activeArea
        anchors{
            top:parent.top
            left:menuLine.right
            right:parent.right
            bottom:parent.bottom
        }
        color: Qt.rgba(0.9,0.9,0.9,1)
        clip: true
        Repeater{
            id:crippers
            model:cripperSource
            delegate: Rectangle{
                id:cripper
                property int col: objectCol
                property int durability: objectDurability
                property real colorIntensity: boosted>=3 ? 0 : durability/objectDurability
                property real objColor:boosted===2 ? 0.4 : objectColor
                property real colorValue:0.5
                property int boosted: boostedMode
                color:Qt.hsla(objColor,colorIntensity,colorValue,1)
                width:obstacleSize
                height:obstacleHeight
                x:col*obstacleSize
                y:0
                onYChanged: {
                    if(durability>0){
                        var curWall=getWall(col)
                        if(curWall.durability<=0){
                            gameOver()
                            return
                        }
                        if(checkBlackHole(y,col)){
                            slash(durability)
                            return
                        }
                        if(y+obstacleHeight>=wall.y){
                            var delta=Math.min(durability,curWall.durability)
                            slash(delta)
                            curWall.durability-=delta
                            if(curWall.durability<=0){
                                gameOver()
                            }
                        }
                    }
                }
                NumberAnimation on y{
                    running:true
                    from:0
                    to:activeArea.height
                    duration:activeArea.height/objectSpeed*1000
                    paused:!gameArea.inProgress
                }
                SequentialAnimation on opacity{
                    id:removeAnimation
                    running: false
                    NumberAnimation{from:1;to:0;duration:400}
                    ScriptAction{script:cripperSource.remove(index)}
                }
                function slash(d){
                    if(durability>0){
                        score+=d
                        durability-=d
                        if(boosted!==0){
                            useHint(col,boosted)
                            boosted=0
                        }
                        if(durability<=0){
                            removeAnimation.start()
                        }
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: parent.slash(1)
                    enabled: inProgress
                }
                NumberAnimation on objColor {
                    running: boosted===1
                    loops: Animation.Infinite
                    from:0.0
                    to:1.0
                    duration:2000
                }
                SequentialAnimation{
                    running: boosted===3
                    loops: Animation.Infinite
                    NumberAnimation{
                        target:cripper;property:"colorValue"
                        from:0.0;to:1.0;duration:500
                    }
                    NumberAnimation{
                        target:cripper;property:"colorValue"
                        from:1.0;to:0.0;duration:500
                    }
                    onStopped: cripper.colorValue=0.5
                }
            }
        }
        Repeater{
            id:hints
            model:areaSize
            delegate:Item{
                id:hint
                width:obstacleSize
                height:activeArea.height
                x:width*index
                property bool blackHoleEnabled:false
                function animateCannon(){
                    cannonAnimation.start()
                }
                function animateFortification(){
                    fortifyAnimation.start()
                }
                function animateBlackhole(){
                    blackholeAnimation.start()
                }
                Rectangle{
                    id:cannon
                    anchors.fill: parent
                    property real scaling:0.0
                    transform: Scale{origin.x:width*0.5; xScale: cannon.scaling}
                    SequentialAnimation{
                        id:cannonAnimation
                        running: false
                        NumberAnimation{target:cannon;property:"scaling";from:0.0;to:1.0;duration:1000;easing.type:Easing.InElastic}
                        ScriptAction{script:clearColumn(index)}
                        NumberAnimation{target:cannon;property:"scaling";from:1.0;to:0.0;duration:1000;easing.type:Easing.OutQuad}
                    }
                }
                Rectangle{
                    id:fortificator
                    anchors{
                        left:parent.left
                        right:parent.right
                        bottom:parent.bottom
                        bottomMargin:vOffset
                    }
                    height: obstacleHeight
                    property real vOffset:-obstacleHeight
                    color:"green"
                    SequentialAnimation{
                        id:fortifyAnimation
                        running: false
                        NumberAnimation{
                            target:fortificator
                            property: "vOffset"
                            from:-obstacleHeight
                            to:obstacleHeight
                            duration: 1000
                        }
                        ScriptAction{script:wallSource.itemAt(index).fortify(5)}
                        PropertyAction{
                            target:fortificator
                            property: "vOffset"
                            value:-obstacleHeight
                        }
                    }
                }
                Rectangle{
                    id:blackHole
                    anchors{
                        left:parent.left
                        right:parent.right
                        top:parent.top
                        topMargin: blackHolePos
                    }
                    height: obstacleHeight*3
                    property real scaling:hint.blackHoleEnabled ? 1 : 0
                    transform: Scale{origin.y:blackHole.height*0.5; yScale: blackHole.scaling}
                    Behavior on scaling {NumberAnimation{duration:400}}
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0) }
                        GradientStop { position: 0.33; color: "black" }
                        GradientStop { position: 0.66; color: "black" }
                        GradientStop { position: 1.0; color: Qt.rgba(0,0,0,0) }
                    }
                    SequentialAnimation{
                        id:blackholeAnimation
                        running: false
                        paused: hint.blackHoleEnabled && gameArea.paused
                        ScriptAction{script:hint.blackHoleEnabled=true}
                        PauseAnimation{duration:6000}
                        ScriptAction{script:hint.blackHoleEnabled=false}
                    }
                }
            }
        }
        Item{
            id:wall
            anchors{
                left:parent.left
                right: parent.right
                bottom:parent.bottom
                bottomMargin: obstacleHeight
            }
            height: obstacleHeight
            Row{
                anchors.centerIn: parent
                Repeater{
                    id:wallSource
                    model:areaSize
                    delegate: Rectangle{
                        property int col: index
                        property int durability: 10
                        property real colorIntensity:0.02*durability
                        property real objectColor:0.4
                        color:Qt.hsla(objectColor,colorIntensity,0.5,1)
                        width:obstacleSize
                        height:obstacleHeight
                        opacity:durability>0?1:0
                        Behavior on opacity{NumberAnimation{duration:400}}
                        function fortify(d){
                            if(durability>0){
                                durability+=d
                            }
                        }
                        function reset(){
                            durability=10
                        }
                    }
                }
            }
        }
    }

    IngameMenu{
        id:menuLine

        score: gameArea.score
        highScore: gameArea.highScore
        hint: "Tip: tap out falling blocks"

        showPauseButton: true

        onMenuButtonPressed: gameArea.quitRequested()
        onRestartButtonPressed: newGame()

    }

    Component.onCompleted: {
        //newGame()
    }
}
