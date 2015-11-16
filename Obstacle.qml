import QtQuick 2.5


Item{
    property bool collidable:true
    function checkCollision(path,nearestCollision){
        var from=mapFromItem(activeArea,path.x1,path.y1)
        var to=mapFromItem(activeArea,path.x2,path.y2)

        function checkEdge(m1,m2,d){
            var dist=m2-m1
            var distBefore=d-m1
            return distBefore/dist
        }

        var edgeCollisions=[
                    {"k":checkEdge(from.y,to.y,0),      "m1":0,"m2":width, "from":from.x,"to":to.x},
                    {"k":checkEdge(from.x,to.x,width),  "m1":0,"m2":height,"from":from.y,"to":to.y},
                    {"k":checkEdge(from.y,to.y,height), "m1":0,"m2":width, "from":from.x,"to":to.x},
                    {"k":checkEdge(from.x,to.x,0),      "m1":0,"m2":height,"from":from.y,"to":to.y}
                ]

        for(var i in edgeCollisions){
            var edgeCollision=edgeCollisions[i]
            if(edgeCollision.k<=1 && edgeCollision.k>0){
                if(nearestCollision===undefined || nearestCollision.k>edgeCollision.k){
                    var cross=edgeCollision.from+(edgeCollision.to-edgeCollision.from)*k
                    if(cross>=edgeCollision.m1 && cross<=edgeCollision.m2){
                        nearestCollision=edgeCollision
                    }
                }
            }
        }

        return nearestCollision
    }
    property var pointFrom
    property var pointTo
    function collided(){
        addRandom()
    }
}

