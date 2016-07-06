import QtQuick 2.5
import Qt.labs.settings 1.0

Rectangle{
    id:linesGame
    color:"lightgrey"

    property real quadSize:30*sizeSet
    property real quadMargin:2*sizeSet
    property real circleMargin:2*sizeSet
    property int quadCount:10
    property int spawnCount:3
    property color baseColor:Qt.rgba(0.9,0.9,0.9,1)
    property var colorPool:["red","blue","green","cyan","brown","yellow","magenta"]
    property Item activeCircle

    property int score: 0
    onScoreChanged: if(score>highScore)highScore=score
    property int highScore:0
    Settings{
        category: "ColorLines"
        property alias highScore:linesGame.highScore
    }

    signal quitRequested
    property bool isGameOver:false

    function completeLoading(){
        createPreserved()
        newGame()
    }

    Item{
        id:mainArea
        anchors{
            top:parent.top
            bottom:parent.bottom
            left:menuLine.right
            right:parent.right
        }
        Column{
            anchors.centerIn: parent
            spacing: 15*sizeSet
            Item{
                width:mainArea.width
                height:preservedRow.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: false
                Row{
                    id:preservedRow
                    anchors.centerIn: parent
                    spacing: quadMargin
                    Repeater{
                        id:preservedQuads
                        model:spawnCount
                        delegate: LinesQuad{}
                    }
                }
                Item{
                    anchors.fill: preservedRow
                    Repeater{
                        id:preservedCircles
                        delegate: LinesCircle{enabled: false}
                        model:preserveModel
                    }
                    ListModel{
                        id:preserveModel
                        property var quadSource:preservedQuads
                    }
                }
            }
            Item{
                height:mainGrid.implicitHeight
                width:height
                anchors.horizontalCenter: parent.horizontalCenter
                Grid{
                    id:mainGrid
                    anchors.centerIn: parent
                    columns: quadCount
                    spacing: quadMargin
                    Repeater{
                        id:quads
                        model:quadCount*quadCount
                        delegate: LinesQuad{}
                        function getQuad(row,col){
                            return itemAt(row*quadCount+col)
                        }
                    }
                }
                Item{
                    anchors.fill: mainGrid
                    Repeater{
                        y:5
                        id:activeCircles
                        delegate: LinesCircle{}
                        model:activeModel
                    }
                    ListModel{
                        id:activeModel
                        property var quadSource:quads
                    }
                }
            }
        }
    }
    function addCircle(model,row,column,color){
        model.append({"mRow":row,"mCol":column,"mColor":color,"quadSource":model.quadSource})
    }

    IngameMenu{
        id:menuLine

        color: "magenta"

        score:linesGame.score
        highScore: linesGame.highScore
        hint: "Tip: use tap and tap to select and move"

        onMenuButtonPressed: quitRequested()
        onRestartButtonPressed: newGame()
    }

/*    Item{
        id: menuLine
        width: 200 * sizeSet
        anchors{
            left:parent.left
            top:parent.top
            bottom:parent.bottom
        }
        Column{
            anchors.centerIn: parent
            spacing: 15 * sizeSet
            Text{
                color:"darkgrey"
                font.pointSize: 16 * sizeSet
                text: "Highscore:" + highScore
            }
            Text{
                color:"darkgrey"
                font.pointSize: 16 * sizeSet
                text: "Score:" + score
            }
            MinigamesButton{
                color:"pink"
                text:"Menu"
                onClicked: quitRequested()
            }
            MinigamesButton{
                id:restartBtn
                color:"pink"
                text:"Restart"
                onClicked: newGame()
            }
            Text{
                color:Qt.hsla(0.0,0.0,0.4,1.0)
                font.pointSize: 14 * sizeSet
                text: "Tip: use tap and tap to select and move"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                width:restartBtn.width
            }
        }
    }
*/
    function nextTurn(){
        if(tryMatch())
            return

        var emptyQuads=spawnPreserved()
        if(emptyQuads>=0){
            if(tryMatch() || emptyQuads>0){
                preserveSpawn()
                return;
            }
        }
        gameOver()
    }

    function preserveSpawn(){
        for(var i=0;i<preservedCircles.count;++i){
            preservedCircles.itemAt(i).recolor(getRandomNumber(0,colorPool.length-1))
        }
    }

    function spawnPreserved(){
        var freeQuads=[]
        for(var x=0;x<quadCount;++x){
            for(var y=0;y<quadCount;++y){
                if(quads.itemAt(y*quadCount+x).filledBy===null)
                    freeQuads.push({"row":y,"col":x})
            }
        }
        for(var i=0;i<spawnCount;++i){
            if(freeQuads.length>0){
                var ind=getRandomNumber(0,freeQuads.length-1)
                addCircle(activeModel,freeQuads[ind].row,freeQuads[ind].col,preserveModel.get(i).mColor)
                freeQuads.splice(ind,1)
            }else{
                return -1
            }
        }
        return freeQuads.length
    }

    function spawnRandom(){
        var freeQuads=[]
        for(var x=0;x<quadCount;++x){
            for(var y=0;y<quadCount;++y){
                freeQuads.push({"row":y,"col":x})
            }
        }
        for(var i=0;i<4;++i){
            var ind=getRandomNumber(0,freeQuads.length-1)
            addCircle(activeModel,freeQuads[ind].row,freeQuads[ind].col,getRandomNumber(0,colorPool.length-1))
            freeQuads.splice(ind,1)
        }
    }

    function createPreserved(){
        for(var i=0;i<spawnCount;++i){
            addCircle(preserveModel,0,i,0)
        }
    }

    function tryMatch(){
        var area=[]
        var i=0
        for(var y=0;y<quadCount;++y){
            var row=[]
            for(var x=0;x<quadCount;++x){
                var circle=quads.itemAt(i).filledBy
                row.push(circle===null?-1:circle.quadColor)
                ++i;
            }
            area.push(row)
        }

        var toDelete=[]
        var lastSequence=[]
        var lastColor=-1
        function endSequence(nextSequence,nextColor){
            if(lastSequence.length>=5){
                toDelete.push(lastSequence)
            }
            lastSequence=nextSequence
            lastColor=nextColor
        }
        function checkSequence(row,col){
            i=row*quadCount+col
            circle=quads.itemAt(i).filledBy
            var curColor=circle===null?-1:circle.quadColor
            if(curColor>=0&&curColor===lastColor){
                lastSequence.push(i)
            }else{
                endSequence([i],curColor)
            }
        }

        //check rows
        for(y=0;y<quadCount;++y){
            for(x=0;x<quadCount;++x){
                checkSequence(y,x)
            }
            endSequence([],-1)
        }

        //check columns
        for(x=0;x<quadCount;++x){
            for(y=0;y<quadCount;++y){
                checkSequence(y,x)
            }
            endSequence([],-1)
        }

        var offset

        //check to right up diagonals
        for(y=0;y<quadCount;++y){
            for(offset=0;offset<=y;++offset){
                checkSequence(y-offset,offset)
            }
            endSequence([],-1)
        }
        for(x=1,y=quadCount-1;x<quadCount;++x){
            for(offset=0;offset<quadCount-x;++offset){
                checkSequence(y-offset,x+offset)
            }
            endSequence([],-1)
        }

        //check to right bottom diagonals
        for(;y>=0;--y){
            for(offset=0;offset<quadCount-y;++offset){
                checkSequence(y+offset,offset)
            }
            endSequence([],-1)
        }
        for(x=1;x<quadCount;++x){
            for(offset=0;offset<quadCount-x;++offset){
                checkSequence(offset,x+offset)
            }
            endSequence([],-1)
        }


        if(toDelete.length>0){
            for(i in toDelete){
                var sequence=toDelete[i]
                for(var j in sequence){
                    circle=quads.itemAt(sequence[j]).filledBy
                    if(circle!==null)
                        circle.remove()
                }
                score+=sequence.length
            }
            return true
        }

        return false
    }

    function pathExists(from,to){
        var pathQuads=[]
        for(var y=0;y<quadCount;++y){
            var rowQuads=[]
            for(var x=0;x<quadCount;++x){
                var filled=quads.itemAt(y*quadCount+x).filledBy!==null
                rowQuads.push({"filled":filled,"visited":false})
            }
            pathQuads.push(rowQuads)
        }
        pathQuads[from.row][from.col].filled=false

        function visitQuad(row,col){
            if(row===to.row&&col===to.col)
                return true
            if(row<0||col<0||row>=quadCount||col>=quadCount)
                return false
            var quad=pathQuads[row][col]
            if(quad.visited||quad.filled)
                return false
            quad.visited=true
            return visitQuad(row+1,col) ||
                   visitQuad(row-1,col) ||
                   visitQuad(row,col+1) ||
                   visitQuad(row,col-1)
        }

        return visitQuad(from.row,from.col)
    }

    function newGame(){
        isGameOver=false
        score=0
        activeModel.clear()
        preserveSpawn()
        spawnRandom()
    }

    function gameOver(){
        isGameOver=true
        for(var i=0;i<preservedCircles.count;++i){
            preservedCircles.itemAt(i).freeze()
        }
        for(i=0;i<activeCircles.count;++i){
            activeCircles.itemAt(i).freeze()
        }
    }

    Component.onCompleted: {
    }
}

