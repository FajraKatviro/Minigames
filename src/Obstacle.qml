import QtQuick 2.5


Item{
    property bool collidable:true
    function checkCollision(path,nearestCollision){
        var from=mapFromItem(activeArea,path.x1,path.y1)
        var to=mapFromItem(activeArea,path.x2,path.y2)

        function checkEdge(m1,m2,d){
            var dist=m2-m1
            var direction=dist>=0 ? 1 : -1
            var distBefore=d-m1-ballSize*0.5*direction
            return distBefore/dist
        }

        var edgeCollisions=[
                    {"k":checkEdge(from.y,to.y,0),      "m1":-ballSize*0.5,"m2":width +ballSize*0.5, "from":from.x,"to":to.x,"item":this,"d":rotation},
                    {"k":checkEdge(from.x,to.x,width),  "m1":-ballSize*0.5,"m2":height+ballSize*0.5,"from":from.y,"to":to.y,"item":this,"d":rotation+90},
                    {"k":checkEdge(from.y,to.y,height), "m1":-ballSize*0.5,"m2":width +ballSize*0.5, "from":from.x,"to":to.x,"item":this,"d":rotation+180},
                    {"k":checkEdge(from.x,to.x,0),      "m1":-ballSize*0.5,"m2":height+ballSize*0.5,"from":from.y,"to":to.y,"item":this,"d":rotation+270}
                ]

        for(var i in edgeCollisions){
            var edgeCollision=edgeCollisions[i]
            if(edgeCollision.k<=1 && edgeCollision.k>0){
                if(nearestCollision===undefined || nearestCollision.k>edgeCollision.k){
                    var cross=edgeCollision.from+(edgeCollision.to-edgeCollision.from)*edgeCollision.k
                    if(cross>=edgeCollision.m1 && cross<=edgeCollision.m2){
                        nearestCollision=edgeCollision
                    }
                }
            }
        }

        return nearestCollision
    }
    function collided(){
        addRandom()
    }
}

