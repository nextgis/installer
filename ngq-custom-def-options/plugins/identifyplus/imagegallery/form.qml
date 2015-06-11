import QtQuick 1.0
 
Rectangle {
    id: mainForm
    anchors.fill: parent
    signal addImages
    signal deleteImage
    signal downloadImage(string imageUrl)
    signal downloadAllImages
    
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    
    Rectangle
    {
        id: gallery
        width:  parent.width
        height: parent.height - galeryControls.height
        
        anchors.top: parent.top;
        
        color: "black"

        ListView
        {
            id: imagesList            
            anchors.rightMargin: 8
            Component
            {
                id: imageDelegate
                    
                        Rectangle 
                        {
                            id: imageCard
                            anchors.horizontalCenter:parent.horizontalCenter
            
                            color: myPalette.window
                        
                            width: 
                            { 
                                if(trueImage.sourceSize.width >= parent.width - 10 )
                                    parent.width - 10
                                else
                                    trueImage.sourceSize.width
                            }
                        
                            height: 
                            {
                                var h = 0
                                if(trueImage.sourceSize.width >= parent.width )
                                    h = parent.width * trueImage.sourceSize.height / trueImage.sourceSize.width
                                else
                                    h = trueImage.sourceSize.height
            
                                h = h + 25
                                return h
                            }
                            
                            Image 
                            {
                                id: trueImage
            
                                anchors.fill: parent
                                anchors.top:parent.top
                                anchors.horizontalCenter:parent.horizontalCenter
                                anchors.topMargin: 4
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                anchors.bottomMargin: 25
            
                                fillMode: Image.PreserveAspectFit //PreserveAspectCrop //PreserveAspectFit
                                source: image.url
                                smooth: true
                            }
                                    
                            Row
                            {
                                id: rowOfButtons
                                anchors.right: trueImage.right
                                anchors.rightMargin:10
                                //anchors.horizontalCenter:parent.horizontalCenter
                                anchors.top: trueImage.bottom 
                                height: 17
                                spacing: 5
                                
                                Button
                                {
                                    icoName: "deleteImageBtn.png"
                                    onPush: deleteImage()
                                }
                                Button
                                {
                                    icoName: "downloadImageBtn.png"
                                    onPush: downloadImage(image.url)
                                }
                            }
                        }
            }
            
            anchors.fill: parent;
            //model: ImageModel {}
            model: images
            delegate: imageDelegate
            
            orientation: ListView.Vertical
            
            spacing: 10
        }
        
        Text 
    	{
            id: message
            color: "#fff"
            opacity: 1
            anchors.centerIn: parent;
            text: no_images_message
            visible :
            {
                if(imagesList.count == 0)
                    true;
                else
                    false;
            }
    	}
    }
    
    ScrollBar
    {
            id: verticalScrollBar
            width: 6; height: gallery.height-12
            anchors.right: gallery.right
            anchors.rightMargin: 2
            anchors.top: gallery.top
            opacity: 1
            orientation: Qt.Vertical
            position: imagesList.visibleArea.yPosition
            pageSize: imagesList.visibleArea.heightRatio
    }
    
    Rectangle
    {
            color: myPalette.window
            
        id: galeryControls
        width:  parent.width
        height: 30
            
        anchors.top: parent.bottom;
        anchors.topMargin: -1 * height
        
        Rectangle
        {
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.top: parent.top
            
            height: 3
            width: parent.width
            
            color: "black"
            
        }
                    
        Rectangle
        {
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.top: parent.top;
            anchors.topMargin: 5
            
            Row
            {
                anchors.horizontalCenter:parent.horizontalCenter
                spacing: 5
                
                Button
                {
                        icoName: "addImageBtn.png"
                        onPush: addImages()
                }
                Button
                {
                        icoName: "downloadImageBtn.png"
                        onPush: downloadAllImages()
                }
            }
        }
    }
    
}
