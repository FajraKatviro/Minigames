import QtQuick 2.4
import Qt.labs.settings 1.0

Rectangle{
    id:gameArea
    anchors.fill: parent
    color:"lightgray"

    property int cellSize: (parent===null?0:parent.height - cellSpacing * (areaSize+1)) / areaSize
    property int cellSpacing: 5
    property int areaSize: 4

    property var colors: {2:"red",4:"blue",8:"green",16:"yellow",
                          32:"violet", 64:"navy",128:"gold",
                          256:"pink",512:"orange",1024:"haki",
                          2048:"magenta",4096:"cyan"}

    signal quitRequested
    signal sanityse
    property bool isGameOver:false

    property int score
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    Settings{
        category: "Numbers"
        property alias highScore:gameArea.highScore
    }

    function completeLoading(){
        //newGame()
    }

    function gameOver(){
        isGameOver=true
    }

    IngameMenu{
        id:menuLine

        caption: "Numbers"
        color: "red"

        score: gameArea.score
        highScore: gameArea.highScore
        hint: "Tip: use swipe to move quads"

        showPauseButton: false

        onMenuButtonPressed: quitRequested()
        onRestartButtonPressed: newGame()
        onHintButtonPressed: game.hintRequested()
    }

    Item{
        id: game

        property int vDirection: 0
        property int hDirection: 0

        property int quadsCalculated: 0
        property bool needRecalculation: true
        property bool active: true
        property bool needSummarize: false
        property bool turnSuccess: false

        signal hintRequested

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: mainGrid.implicitHeight
        height: mainGrid.implicitHeight

        onActiveChanged: if(active && turnSuccess){createRandom(); score+=2;}

        function createRandom(){
            var free=[]
            for(var i=0,j=0;i<areaQuads.count;++i){
                var quad=areaQuads.itemAt(i)
                if(quad.isFree()){
                    free[j++]=i;
                }
            }
            var capacity=free.length
            if(capacity>0){
                var ind=free[Math.floor(Math.random()*free.length)]
                var r=Math.floor(ind / areaSize)
                var c=ind % areaSize
                activeModel.addQuad(r,c,2)
                if(capacity===1 && !canMove()){
                    gameOver()
                }
            }else{
                gameOver()
            }
        }

        function canMove(){
            for(var a=0;a<areaSize;++a){
                var hScore=areaQuads.getQuad(0,a).occupiedBy.score
                var vScore=areaQuads.getQuad(a,0).occupiedBy.score
                for(var b=1;b<areaSize;++b){
                    var score=areaQuads.getQuad(b,a).occupiedBy.score
                    if(score===hScore)
                        return true
                    hScore=score

                    score=areaQuads.getQuad(a,b).occupiedBy.score
                    if(score===vScore)
                        return true
                    vScore=score

                }
            }
            return false
        }

        signal stateRefresh()
        function requestRefresh(){
            if(vDirection===0 && hDirection===0)
                return;
            active=false
            quadsCalculated=0
            var b=needRecalculation
            needRecalculation=false
            if(b)
                stateRefresh()
            else if(needSummarize)
                summarize()
            else{
                active=true
                needRecalculation=true
            }
        }

        function summarize(){
            quadsCalculated=activeModel.count
            if(hDirection===-1){
                for(var r=0;r<areaSize;++r){
                    for(var c=0;c<areaSize-1;++c){
                        var cur=areaQuads.getQuad(r,c)
                        var nex=areaQuads.getQuad(r,c+1)
                        if(cur!==null && nex!==null && !cur.isFree() && !nex.isFree()){
                            if(cur.occupiedBy.score===nex.occupiedBy.score && !cur.occupiedBy.summarized){
                                cur.occupiedBy.score*=2
                                activeModel.remove(nex.occupiedBy.modelIndex)
                                ++c
                                turnSuccess=true
                                quadsCalculated=activeModel.count
                                cur.occupiedBy.summarized=true
                                return
                            }
                        }
                        if(cur!==null && !cur.isFree())cur.occupiedBy.summarized=true
                    }
                }
            }else if(hDirection===1){
                for(var r=0;r<areaSize;++r){
                    for(var c=areaSize-1;c>0;--c){
                        var cur=areaQuads.getQuad(r,c)
                        var nex=areaQuads.getQuad(r,c-1)
                        if(cur!==null && nex!==null && !cur.isFree() && !nex.isFree()){
                            if(cur.occupiedBy.score===nex.occupiedBy.score && !cur.occupiedBy.summarized){
                                cur.occupiedBy.score*=2
                                activeModel.remove(nex.occupiedBy.modelIndex)
                                --c
                                turnSuccess=true
                                quadsCalculated=activeModel.count
                                cur.occupiedBy.summarized=true
                                return
                            }
                        }
                        if(cur!==null && !cur.isFree())cur.occupiedBy.summarized=true
                    }
                }
            }else if(vDirection===-1){
                for(var r=0;r<areaSize-1;++r){
                    for(var c=0;c<areaSize;++c){
                        var cur=areaQuads.getQuad(r,c)
                        var nex=areaQuads.getQuad(r+1,c)
                        if(cur!==null && nex!==null && !cur.isFree() && !nex.isFree()){
                            if(cur.occupiedBy.score===nex.occupiedBy.score && !cur.occupiedBy.summarized){
                                cur.occupiedBy.score*=2
                                activeModel.remove(nex.occupiedBy.modelIndex)
                                ++r
                                turnSuccess=true
                                quadsCalculated=activeModel.count
                                cur.occupiedBy.summarized=true
                                return
                            }
                        }
                        if(cur!==null && !cur.isFree())cur.occupiedBy.summarized=true
                    }
                }
            }else if(vDirection===1){
                for(var r=areaSize;r>0;--r){
                    for(var c=0;c<areaSize;++c){
                        var cur=areaQuads.getQuad(r,c)
                        var nex=areaQuads.getQuad(r-1,c)
                        if(cur!==null && nex!==null && !cur.isFree() && !nex.isFree()){
                            if(cur.occupiedBy.score===nex.occupiedBy.score && !cur.occupiedBy.summarized){
                                cur.occupiedBy.score*=2
                                activeModel.remove(nex.occupiedBy.modelIndex)
                                --r
                                turnSuccess=true
                                quadsCalculated=activeModel.count
                                cur.occupiedBy.summarized=true
                                return
                            }
                        }
                        if(cur!==null && !cur.isFree())cur.occupiedBy.summarized=true
                    }
                }
            }else{
                console.log("unexpected direction")
            }

            needRecalculation=true
            needSummarize=false
        }

        Timer{
            interval: 1
            repeat: true
            running: !parent.active
            onTriggered: {
                if(parent.quadsCalculated===activeModel.count){
                    parent.requestRefresh()
                }
            }
        }


        Grid{
            id: mainGrid
            anchors.fill: parent
            //anchors.margins: cellSpacing
            spacing: cellSpacing
            columns: areaSize
            Repeater{
                id: areaQuads
                model: areaSize*areaSize

                function getQuad(row,col){
                    if(row<0 ||
                       row>=areaSize ||
                       col<0 ||
                       col>=areaSize )
                        return null;
                    return itemAt(row*areaSize+col);
                }

                delegate: Rectangle{
                    id:quadDelegate
                    property Item occupiedBy: null
                    function isFree(){
                        return occupiedBy===null || occupiedBy.placeQuad!==this;
                    }

                    height: cellSize
                    width: cellSize
                    color:"white"
                    radius: 2
                    border.width: 1
                    Connections{
                        target: gameArea
                        onSanityse:quadDelegate.occupiedBy=null
                    }
                }
            }
        }
        Item{
            anchors.fill: mainGrid
            Repeater{
                id: activeQuads
                model: ListModel{
                    id: activeModel
                    function addQuad(row,column,score){
                        append({'row':row,'column':column,'pts':score})
                    }
                }

                delegate: Item{
                    id: activeQuad
                    property int currentRow: row
                    property int currentColumn: column
                    property int score: pts
                    property int modelIndex: index
                    property int newRow: currentRow + game.vDirection
                    property int newColumn: currentColumn + game.hDirection
                    property Item placeQuad:areaQuads.getQuad(currentRow,currentColumn)
                    property var newPlace:areaQuads.getQuad(newRow,newColumn)
                    property bool summarized: false
                    onPlaceQuadChanged: placeQuad.occupiedBy=this

                    onScoreChanged: animateColors()

                    function animateColors(){
                        colorAnimation.stop()
                        colorAnimation.targetColor=colors[score]
                        colorAnimation.start()
                    }

                    Connections{
                        target: game
                        onStateRefresh:{
                           activeQuad.summarized=false
                            if(activeQuad.newPlace!==null && activeQuad.newPlace.isFree()){
                                game.needRecalculation=true
                                activeQuad.currentRow=activeQuad.newRow
                                activeQuad.currentColumn=activeQuad.newColumn
                                game.turnSuccess=true
                            }
                            ++game.quadsCalculated
                        }
                        onHintRequested:{
                            activeQuad.animateColors()
                        }
                    }

                    x: placeQuad.x
                    y: placeQuad.y
                    width: cellSize
                    height: cellSize
                    Rectangle{
                        anchors{
                            fill:parent
                            margins: 5
                        }
                        //color: colors[score]
                        radius: 4
                        border.width: 2
                        clip: true
                        Text{
                            anchors.fill: parent
                            text: score
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 40 * sizeSet
                        }
                        ColorAnimation on color{
                            id: colorAnimation
                            property var targetColor
                            from:targetColor
                            to:"grey"
                            duration: 750
                            //easing.type: Easing.Linear
                        }
                    }

                    Behavior on x{ NumberAnimation{ duration: 250} }
                    Behavior on y{ NumberAnimation{ duration: 250} }

                    NumberAnimation on width{id:createAnimation;from:0;to:cellSize;duration:500}
                    NumberAnimation on height{id:createAnimationHeight;from:0;to:cellSize;duration:500}


                    Component.onCompleted:{
                        createAnimation.start()
                        createAnimationHeight.start()
                        placeQuad.occupiedBy=this
                    }
                }
            }
        }

        StartPoint{
            id:tapToStartText
            onStartRequested: goPlay()
        }
    }

    function setDirection(v,h){
        if(game.active){
            game.vDirection=v
            game.hDirection=h
            game.needSummarize=true
            game.turnSuccess=false
            game.requestRefresh()
        }
    }

    Connections{
        target: mainControl
        onLeftSwipe: setDirection(0,-1)
        onUpSwipe: setDirection(-1,0)
        onRightSwipe: setDirection(0,1)
        onDownSwipe: setDirection(1,0)
    }

    function newGame(){
        isGameOver=false
        score=0
        activeModel.clear()
        sanityse()
        game.createRandom()
        game.createRandom()
        game.createRandom()
    }

    Component.onCompleted:{
        //newGame()
    }

    //enabled: false
    property bool started: false
    function goPlay(){
        tapToStartText.visible=false
        //enabled=true
        started=true
        menuLine.started=true
        newGame()
    }
}
