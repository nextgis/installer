# -*- coding: utf-8 -*-

#******************************************************************************
#
# IdentifyPlus
# ---------------------------------------------------------
# Extended identify tool. Supports displaying and modifying photos
#
# Copyright (C) 2012-2013 NextGIS (info@nextgis.org)
#
# This source is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2 of the License, or (at your option)
# any later version.
#
# This code is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# A copy of the GNU General Public License is available on the World Wide Web
# at <http://www.gnu.org/licenses/>. You can also obtain it by writing
# to the Free Software Foundation, 51 Franklin Street, Suite 500 Boston,
# MA 02110-1335 USA.
#
#******************************************************************************
import numbers

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from PyQt4 import QtDeclarative

from qgis.core import *
from qgis.gui import *

from ui_attributestable import Ui_AttributesTable

from imagegallery.image_gallery import ImageGalleryWidget, ImagesListModel, Image
from identifyplusutils import getImageByURL
from ngwapi import ngwapi

import functools

class RepresentationContainer(QTabWidget):
    def __init__(self, parent = None):
        QTabWidget.__init__(self, parent)
        self.representations = list()
        self.threades = list()
        
    def takeControl(self, (obj, qgsMapLayer, representations)):
        existingReprs = []
        reprsClasses = [repr[0] for repr in representations]
        for i in range(0,  self.count())[::-1]:
            if type(self.widget(i)) in reprsClasses:
                #self.widget(i).takeControl(obj, qgsMapLayer, representations[i][1])
                self.__transferControl(
                    self.widget(i),
                    obj,
                    qgsMapLayer,
                    representations[reprsClasses.index(type(self.widget(i)))][1]
                )
                existingReprs.append( type(self.widget(i)) )
            else:
                self.removeTab(i)
        
        newReprsClasses = list(set(reprsClasses) - set(existingReprs))
        
        for reprClass in newReprsClasses:
            representation = reprClass(self)
            self.addTab(representation, representation.reprName)
            #representation.takeControl( obj, qgsMapLayer, repr[1])
            self.__transferControl(representation, obj, qgsMapLayer, representations[reprsClasses.index(reprClass)][1])    

    def __transferControl(self, representation, obj, qgsMapLayer, reprAttrs):
        #representation.takeControl(obj, qgsMapLayer, reprAttrs)
        thread = QThread(self)
        representation.moveToThread(thread)

        thread.started.connect( functools.partial(representation.takeControl, obj, qgsMapLayer, reprAttrs) )
        representation.finished.connect(thread.quit)
        thread.finished.connect(thread.deleteLater)
        thread.start()
        
        self.threades.append(thread)
        
class DictView(QWidget, Ui_AttributesTable):
    finished = pyqtSignal()
    mainfields = [u'layerId', u'layerName']
    def __init__(self, parent = None):
        QWidget.__init__(self, parent)
        self.reprName = self.tr("attributes")
        self.setupUi(self)
        
        self.tblAttributes.verticalHeader().setResizeMode(QHeaderView.ResizeToContents)
        
        self.labels = []

    def takeControl(self, dictAttributes, qgsMapLayer, representationsData):
        if not isinstance(dictAttributes, dict):
            raise AttributeError("dictAttributes is not dict")
        
        for l in self.labels:
            l.close()
        
        self.tblAttributes.clear()
        self.tblAttributes.setHorizontalHeaderLabels([self.tr("Name"), self.tr("Value")])
        #self.tblAttributes.setRowCount(len(dictAttributes))
        self.tblAttributes.setRowCount(0)
        self.tblAttributes.setColumnCount(2)
        
        
        row = 0
        
        font = QFont()
        font.setWeight(75)
        font.setBold(True)
        
        for fieldName, fieldValue in dictAttributes.items():            
            itemFieldName = QTableWidgetItem(fieldName)
            itemFieldValue = QTableWidgetItem(fieldValue)
            
            rowIndex = row
            if fieldName in self.mainfields:
                itemFieldName.setFont(font)
                itemFieldValue.setFont(font)
                rowIndex = 0
            
            self.tblAttributes.insertRow(rowIndex)
            self.tblAttributes.setItem(rowIndex, 1, itemFieldValue )
            self.tblAttributes.setItem(rowIndex, 0, itemFieldName )
                
            row += 1
        self.finished.emit()

class AttributesView(QWidget, Ui_AttributesTable):
    finished = pyqtSignal()
    def __init__(self, parent = None):
        QWidget.__init__(self, parent)
        self.reprName = self.tr("attributes")
        self.setupUi(self)
        
        self.tblAttributes.verticalHeader().setResizeMode(QHeaderView.ResizeToContents)

    def takeControl(self, qgsFeature, qgsMapLayer, representationsData):
        if not isinstance(qgsFeature, QgsFeature):
            raise AttributeError("qgsMapCanvas is not qgis._core.QgsFeature")

        attrs = {}

        qgsAttrs = qgsFeature.attributes()
        fields = qgsFeature.fields().toList()
        for i in xrange(len(qgsAttrs)):
            attrs[fields[i].name()] = qgsAttrs[i]

        self.tblAttributes.clear()
        self.tblAttributes.setHorizontalHeaderLabels([self.tr("Name"), self.tr("Value")])
        self.tblAttributes.setRowCount(len(attrs))
        self.tblAttributes.setColumnCount(2)
        
        row = 0
        for fieldName, fieldValue in attrs.items():
            item = QTableWidgetItem(fieldName)
            self.tblAttributes.setItem(row, 0, item )
            
            if isinstance(fieldValue, QPyNullVariant):
                item = QTableWidgetItem("NULL")
                
            elif isinstance(fieldValue, QVariant):
                item = QTableWidgetItem(attrs[i].toString())
                
            else:
              if isinstance(fieldValue, numbers.Number):
                item = QTableWidgetItem(str(fieldValue))
              else:
                item = QTableWidgetItem(fieldValue)
            
            self.tblAttributes.setItem(row, 1, item )
            row += 1
        self.finished.emit()


class NGWImages(ImageGalleryWidget):
    finished = pyqtSignal()
    def __init__(self, parent = None):
        self.images_model = ImagesListModel()
        ImageGalleryWidget.__init__(
            self,
            self.images_model,
            QApplication.translate("NGWImages", "No photos", None, QApplication.UnicodeUTF8),
            parent)
        
        self.reprName = self.tr("images")
        
        self.addImages.connect(self.addPhotos)
        self.deleteImage.connect(self.deletePhoto)
        self.downloadImage.connect(self.downloadPhoto)
        self.downloadAllImages.connect(self.downloadPhotos)


    def takeControl(self, qgsFeature, qgsMapLayer, representationsData):
        self.images_model.clean()
        ngwResource = ngwapi.getNGWResource(representationsData[u"baseURL"], representationsData[u"resourceId"], representationsData[u"auth"])

        ngwResource4identify = None

        if isinstance(ngwResource, ngwapi.NGWResourceWFS):
            resourceId4identify = ngwResource.getLayerResourceIDByKeyname(representationsData[u'LayerName'])
            ngwResource4identify = ngwapi.getNGWResource(ngwResource.baseURL, resourceId4identify, representationsData[u'auth'])
            
        elif isinstance(ngwResource, ngwapi.NGWResourceVectorLayer):
            ngwResource4identify = ngwResource
        
        fid = qgsFeature.id()
        if qgsMapLayer.dataProvider().name() == u'WFS':
            fid = fid + 1
            
        imagesIds = ngwapi.ngwIdentification(ngwResource4identify, fid, representationsData[u'auth']).imagesIds
        
        images = []
        for imageId in imagesIds:
            url = ngwResource4identify.getURLForGetFeatureImage(fid, imageId)
            images.append(Image( url ))

        self.images_model.appendImages(images)
        self.finished.emit()
    
    def downloadPhoto(self, imageURL):
        settings = QSettings("Photos", "identifyplus")
        lastDir = settings.value( "/lastPhotoDir", "." )
    
        fName = QFileDialog.getSaveFileName(self,
                                            self.tr("Save image"),
                                            lastDir,
                                            self.tr("PNG files (*.png)")
                                           )
        if fName == "":
          return
    
        if not fName.lower().endswith(".png"):
          fName += ".png"
        
        img = getImageByURL(imageURL, None)
        img.save(fName)
            
        settings.setValue("/lastPhotoDir", QFileInfo(fName).absolutePath())
    
    def deletePhoto(self):
        self.showMessage(self.tr("The delete photo operation is not available"))

    def downloadPhotos(self):
        settings = QSettings("Photos", "identifyplus")
        lastDir = settings.value( "/lastPhotoDir", "." )
    
        dirName = QFileDialog.getExistingDirectory(self,
                                                   self.tr("Select directory"),
                                                   lastDir,
                                                   QFileDialog.ShowDirsOnly
                                                  )
        if dirName == "":
            return

        for image in self.images_model.getAllImages():
            url = image.url.toString()
            img = getImageByURL(url, None)
            img.save("%s/%s.png" % (dirName, "photo_%s"%url.split('/')[-1]))
          
        settings.setValue("/lastPhotoDir", QFileInfo(dirName).absolutePath())
  
    def addPhotos(self):
        self.showMessage(self.tr("The add photo operation is not available"))
    
    def showMessage(self, message):
        msgViewer = QgsMessageViewer(self)
        msgViewer.setTitle(self.tr("IdentifyPlus message") )
        msgViewer.setCheckBoxVisible(False)
        msgViewer.setMessageAsHtml(message)
        msgViewer.showMessage()