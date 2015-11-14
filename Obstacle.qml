import QtQuick 2.5


Item{
    property bool justCollided:false
    property bool collidable:true
    function collided(){
        addRandom()
    }
}

