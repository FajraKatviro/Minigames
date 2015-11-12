import QtQuick 2.4

Rectangle{
    anchors.fill: parent
    color:"lightgray"

    property int cellSize: (parent.height - cellSpacing * (areaSize+1)) / areaSize
    property int cellSpacing: 5
    property int areaSize: 4

    property var colors: {2:"red",4:"blue",8:"green",16:"yellow",
                          32:"violet", 64:"navy",128:"gold",
                          256:"pink",512:"orange",1024:"haki",
                          2048:"",4096:""}

    signal quitRequested

    property int score

    Item{
        anchors{
            left:parent.left
            top:parent.top
            bottom: parent.bottom
            right: game.left
        }
        Column{
            anchors.centerIn: parent
            spacing: 40*sizeSet
            MinigamesButton{
                color:"red"
                text: "Menu"
                onClicked: quitRequested()
            }
            MinigamesButton{
                color:"red"
                text: "Restart"
                onClicked: newGame()
            }
            Text{
                color:"darkgrey"
                text:"Score: " + score
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20 * sizeSet
            }
        }
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
            if(free.length>0){
                var ind=free[Math.floor(Math.random()*free.length)]
                var r=Math.floor(ind / areaSize)
                var c=ind % areaSize
                activeModel.addQuad(r,c,2)
            }
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
                    property Item occupiedBy: null
                    function isFree(){
                        return occupiedBy===null || occupiedBy.placeQuad!==this;
                    }

                    height: cellSize
                    width: cellSize
                    color:"white"
                    radius: 2
                    border.width: 1
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
        activeModel.clear()
        game.createRandom()
        game.createRandom()
        game.createRandom()
    }

    Component.onCompleted:{
        newGame()
    }
}
