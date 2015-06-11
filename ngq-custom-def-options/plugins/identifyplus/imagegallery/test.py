# -*- coding: utf-8 -*-

from PyQt4 import QtCore, QtGui, Qt, QtDeclarative
import image_gallery

i1 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-1.jpg"))
i2 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-2.jpg"))
i3 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-3.jpg"))
i4 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-4.jpg"))
i5 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-5.jpg"))
i6 = image_gallery.Image(QtCore.QUrl.fromLocalFile(u"plaza-6.jpg"))


#images_model = image_gallery.ImagesListModel([i1, i2, i3, i4, i5, i6])
images_model = image_gallery.ImagesListModel()

def onAddImages():
    print "Add images!"
    images_model.appendImages([i1])
def onDeleteImage():
    print "Delete image!"
def onDownloadImage(image):
    print "Download image!"
    print image
def onDownloadAllImages():
    print "Download all image!"

import sys
app = QtGui.QApplication(sys.argv)

w = image_gallery.ImageGalleryWidget(images_model, u" no photos")
w.setGeometry(100, 100, 300, 700)

w.addImages.connect(onAddImages)
w.deleteImage.connect(onDeleteImage)
w.downloadImage.connect(onDownloadImage)
w.downloadAllImages.connect(onDownloadAllImages)
w.show()



sys.exit(app.exec_())

