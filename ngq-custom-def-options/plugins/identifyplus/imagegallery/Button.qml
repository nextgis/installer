//contents of Button.qml
import QtQuick 1.0

Rectangle
{
    signal push
    property string icoName: ""

    width: 21
    height: 21
    color: myPalette.window
    
    Image 
    {
        anchors.centerIn: parent
        width: 16
        height: 16
        fillMode: Image.PreserveAspectFit
        source: icoName
        smooth: true
    }
    
    MouseArea 
    {
        id: mousearea
        anchors.fill: parent
        
        onPressed:
        {
            parent.color = "#444"
        }
        onReleased:
        {
            parent.color = myPalette.window
        }
        onEntered:
        {
            parent.border.width = 1
            parent.border.color = "#000"
        }
        onExited:
        {
            parent.border.width = 1
            parent.border.color = parent.color
        }
        
        hoverEnabled: true
    }
    
    Component.onCompleted:
    {
        mousearea.clicked.connect(push)
    }
}