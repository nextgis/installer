# -*- coding: utf-8 -*-
from PyQt4 import QtCore, QtGui, Qt, QtDeclarative
import resources

class Image(QtCore.QObject):   

    changed = QtCore.pyqtSignal()

    def __init__(self, url):
        QtCore.QObject.__init__(self)
        self._url = url

    @QtCore.pyqtProperty(QtCore.QUrl, notify=changed)
    def url(self):
        return QtCore.QUrl(self._url)

class ImagesListModel(QtCore.QAbstractListModel):
    COLUMNS = {QtCore.Qt.UserRole: 'image'}
    def __init__(self, images = [], parent=None): 
        """ images: a list where each item is a object of Image class
        """
        QtCore.QAbstractListModel.__init__(self, parent) 
    
        roles = self.roleNames()
        roles.update(ImagesListModel.COLUMNS)

        self.setRoleNames(roles)
        self.__images = images

    def rowCount(self, parent=QtCore.QModelIndex()):
        return len(self.__images)

    def data(self, index, role):
        if index.isValid() and role == QtCore.Qt.UserRole:
            return self.__images[index.row()]
        else: 
            return None
    
    def getAllImages(self):
        return self.__images
    
    def appendImages(self, images):
        for image in images:
            self.__images.append(image)
        self.modelReset.emit()
    
    def clean(self):
        del self.__images[:]

class ImageGalleryWidget(QtGui.QWidget):

    addImages = QtCore.pyqtSignal(name='addImages')
    deleteImage = QtCore.pyqtSignal(name='deleteImage')
    downloadImage = QtCore.pyqtSignal(unicode, name='downloadImage')
    downloadAllImages = QtCore.pyqtSignal(name='downloadAllImages')
    
    def __init__(self, images, no_images_message, parent=None):
        QtGui.QWidget.__init__(self, parent)
        
        self.images = images    

        self.hblMainLayout = QtGui.QHBoxLayout(self)
        self.setLayout(self.hblMainLayout)  
            
        self.qmlImageGallery = QtDeclarative.QDeclarativeView(self)
        self.qmlImageGallery.setResizeMode(QtDeclarative.QDeclarativeView.SizeRootObjectToView)
        self.qmlImageGallery.engine().rootContext().setContextProperty('images', self.images)
        self.qmlImageGallery.engine().rootContext().setContextProperty('no_images_message', no_images_message)
        self.qmlImageGallery.setSource( QtCore.QUrl('qrc:/form.qml') ) 

        self.hblMainLayout.addWidget(self.qmlImageGallery)

        root = self.qmlImageGallery.rootObject()        
        root.addImages.connect(self.onAddImages)
        root.deleteImage.connect(self.onDeleteImage)
        root.downloadImage.connect(self.onDownloadImage)
        root.downloadAllImages.connect(self.onDownloadAllImages)

    def onAddImages(self):  
        self.addImages.emit()
    def onDeleteImage(self):
        self.deleteImage.emit()
    def onDownloadImage(self, imageURL):
        print type(imageURL)
        self.downloadImage.emit(imageURL)
    def onDownloadAllImages(self):
        self.downloadAllImages.emit()
