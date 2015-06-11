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
import re, traceback
from urlparse import urlparse, parse_qs

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from qgis.core import *
from qgis.gui import *

from GdalTools.tools import GdalTools_utils

from ngwapi import ngwapi
from identifyplusutils import  gdallocationinfoXMLOutputProcessing

from representations import *


class IdentifyPlusModel(QObject):
    
    finished = pyqtSignal()
    error = pyqtSignal(Exception, basestring)
    progress = pyqtSignal(float, list)

    def __init__(self, qgsMapCanvas):
        QObject.__init__(self)

        if not isinstance(qgsMapCanvas, QgsMapCanvas):
            raise TypeError("IdentifyPlusModel expected a qgis._gui.QgsMapCanvas, got a {} instead".format(type(qgsMapCanvas)))

        self._qgsMapCanvas = qgsMapCanvas
        self._qgsMapLayers = list()
        self._killed = False
    
    def setIdentificationSettings(self, qgsPoint):
        if not isinstance(qgsPoint, QgsPoint):
                raise TypeError("identification expected a qgis._core.QgsPoint, got a {} instead".format(type(qgsPoint)))
        self._qgsPoint = qgsPoint
    
    def _defineLayers(self, **args):
        del self._qgsMapLayers[:]

        if (args.has_key(u"all_qgis_layers")):
            if args[u"all_qgis_layers"] == True:
                self._qgsMapLayers.extend(self._qgsMapCanvas.layers())
    
    def identification(self):
        try:
            self._defineLayers(all_qgis_layers=True)
            
            percentPerLayer = 100/len(self._qgsMapLayers);
            percentProgress = 0
            
            for qgsMapLayer in self._qgsMapLayers:
                objects = list()
                if qgsMapLayer.type() == QgsMapLayer.RasterLayer:
                    raster_objects = self._initRasterLayer(qgsMapLayer, self._qgsPoint)
                    for obj in raster_objects:
                        objects.append([obj, qgsMapLayer, [[DictView,{}]] ])
                    
                elif qgsMapLayer.type() == QgsMapLayer.VectorLayer:
                    vector_objects = self._initVectorLayer(qgsMapLayer, self._qgsPoint)
                    
                    representations = list
    
                    res = self._parseQgsMapLayerSourceForNGW(qgsMapLayer)
                    if res is None:
                        representations =  [[AttributesView,{}]]
                    else:
                        representations =  [[AttributesView,{}], [NGWImages,res[1]] ]
    
                    for obj in vector_objects:
                        objects.append([obj, qgsMapLayer, representations])
                else:
                    QgsMessageLog.logMessage(self.tr("Unknown layer type"), u'IdentifyPlus', QgsMessageLog.WARNING)
                
                if self._killed is True:
                    # kill request received, exit loop early
                    break


                percentProgress = percentProgress + percentPerLayer
                self.progress.emit(percentProgress, objects)
            
            if self._killed is False:
                self.progress.emit(100, [])
                
        except Exception, e:
            # forward the exception upstream
            self.error.emit(e, traceback.format_exc())
        
        self.finished.emit()
    
    def kill(self):
        self._killed = True


    def _parseQgsMapLayerSourceForNGW(self, qgsMapLayer):
        '''
            wfs:        http://demo.nextgis.ru/ngw/resource/1311/wfs?SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=rukluobninsk4wfs&SRSNAME=EPSG:3857&username=administrator&password=admin
            geojson:    http://administrator:admin@demo.nextgis.ru/ngw/resource/1316/geojson/
        '''
        baseURL = ""
        ngw_username = ""
        ngw_password = ""
        resourceID = 0
            
        o = urlparse(qgsMapLayer.source())
        
        m = re.search('^.*/resource/\d+/',o.path)
        if m is None:
            return None
        
        # o.path is '.../resource/<resource id>/.......'
        # m.group() is '.../resource/<resource id>/'
        basePathStructure = m.group().strip('/').split('/')

        baseURL = o.scheme + '://' + o.netloc + '/' + '/'.join(basePathStructure[:-2])
        resourceID = int(basePathStructure[-1])
        requestAttrs = parse_qs(o.query)

        if qgsMapLayer.providerType() == u'WFS':
            if requestAttrs.has_key(u'username'):
                ngw_username = requestAttrs.get(u'username')[0]
            if requestAttrs.has_key(u'password'):
                ngw_password = requestAttrs.get(u'password')[0]
        elif qgsMapLayer.providerType() == u'ogr':
            if o.netloc.find('@') != -1:
                auth_data = o.netloc.split('@')[0]
                ngw_username = auth_data.split(':')[0]
                ngw_password = auth_data.split(':')[1]
        else:
            return None
        additionAttrs = {}
        if requestAttrs.get(u'TYPENAME') is not None:
            additionAttrs.update({u'LayerName': requestAttrs[u'TYPENAME'][0]})
            
        additionAttrs.update({u'auth':(ngw_username, ngw_password)})
        additionAttrs.update({u'baseURL':baseURL})
        additionAttrs.update({u'resourceId':resourceID})
        
        try:
            return (ngwapi.getNGWResource(baseURL, resourceID, (ngw_username, ngw_password)), additionAttrs)
        except ngwapi.NGWAPIError as err:
            QgsMessageLog.logMessage(self.tr("Get NGW resource error") + ":\n" + str(err), u'IdentifyPlus', QgsMessageLog.CRITICAL)
            return None
        
    def _initRasterLayer(self, qgsMapLayer, qgsPoint):
        QgsMessageLog.logMessage(
            "identification raster point %f %f"%(qgsPoint.x(), qgsPoint.y()),
            u'IdentifyPlus',
            QgsMessageLog.INFO)
        
        point = self._qgsMapCanvas.getCoordinateTransform().toMapCoordinates(qgsPoint.x(), qgsPoint.y())
        
        #Use gdalocationinfo utility
        process = QProcess()
        GdalTools_utils.setProcessEnvironment(process)
        
        gdallocationinfo_params = []
        
        settings = QSettings()
        proxyEnabled = settings.value("proxy/proxyEnabled", False, type=bool)
        
        if proxyEnabled == True:
            proxyType = settings.value("proxy/proxyType", "", type=unicode)
            if  proxyType == "HttpProxy":
                
                GDAL_HTTP_PROXY = ""
                proxyHost = settings.value("proxy/proxyHost", None, type=unicode)
                if proxyHost is None:
                    QgsMessageLog.logMessage(
                        self.tr("QGIS proxysettings error") + ": " + self.tr("Parameter 'proxyHost' is missing"), 
                        u'IdentifyPlus', 
                        QgsMessageLog.CRITICAL)
                    return []                
                GDAL_HTTP_PROXY = GDAL_HTTP_PROXY + proxyHost             
                proxyPort = settings.value("proxy/proxyPort", None, type=unicode)
                if proxyPort is not None:
                    GDAL_HTTP_PROXY = GDAL_HTTP_PROXY  + ":%s"%proxyPort
                gdallocationinfo_params.extend(["--config", "GDAL_HTTP_PROXY", GDAL_HTTP_PROXY])
                
                GDAL_HTTP_PROXYUSERPWD = ""
                proxyUser = settings.value("proxy/proxyUser", None, type=unicode)
                if proxyUser is not None:
                    GDAL_HTTP_PROXYUSERPWD = GDAL_HTTP_PROXYUSERPWD + proxyUser
                    proxyPassword = settings.value("proxy/proxyPassword", None, type=unicode)
                    if proxyPassword is not None:
                        GDAL_HTTP_PROXYUSERPWD = GDAL_HTTP_PROXYUSERPWD + ":%s"%proxyPassword
                    gdallocationinfo_params.extend(["--config", "GDAL_HTTP_PROXYUSERPWD", GDAL_HTTP_PROXYUSERPWD])
        
        gdallocationinfo_params.extend(["-xml","-b", "1" ,"-geoloc", qgsMapLayer.source(), str(point.x()), str(point.y())])
        
        QgsMessageLog.logMessage(
            "gdallocationinfo "+ " ".join(gdallocationinfo_params),
            u'IdentifyPlus',
            QgsMessageLog.INFO)
            
        process.start("gdallocationinfo", gdallocationinfo_params, QIODevice.ReadOnly)
        finishWaitSuccess = process.waitForFinished()
        
        #if not finishWaitSuccess:
        #    QgsMessageLog.logMessage(self.tr("Wait for gdallocationinfo more then 5 sec <br/>"), u'IdentifyPlus', QgsMessageLog.CRITICAL)
        #    return []
        
        if(process.exitCode() != 0):
            err_msg = str(process.readAllStandardError())
            if err_msg == '':
                err_msg = str(process.readAllStandardOutput())
            
            QgsMessageLog.logMessage(self.tr("gdallocationinfo return error status<br/>") + ":\n" + err_msg, u'IdentifyPlus', QgsMessageLog.CRITICAL)
        else:
            data = str(process.readAllStandardOutput());
            res = gdallocationinfoXMLOutputProcessing(data)
            
            if res[0] != None:
               QgsMessageLog.logMessage(self.tr("Parsing gdallocationinfo request error<br/>") + ":\n" + res[1] + "\n" + data, u'IdentifyPlus', QgsMessageLog.CRITICAL)
            else:
                return res[1]
        
        return []
    def _initVectorLayer(self, qgsMapLayer, qgsPoint):
        # load identify radius from settings
        settings = QSettings()
        identifyValue = float(settings.value("/Map/searchRadiusMM", QGis.DEFAULT_IDENTIFY_RADIUS))
    
        if identifyValue <= 0.0:
          identifyValue = QGis.DEFAULT_IDENTIFY_RADIUS

        pointFrom = self._qgsMapCanvas.getCoordinateTransform().toMapCoordinates(
            qgsPoint.x() - identifyValue * self._qgsMapCanvas.PdmWidthMM, 
            qgsPoint.y() + identifyValue * self._qgsMapCanvas.PdmHeightMM)
            
        pointTo = self._qgsMapCanvas.getCoordinateTransform().toMapCoordinates(
            qgsPoint.x() + identifyValue * self._qgsMapCanvas.PdmWidthMM, 
            qgsPoint.y() - identifyValue * self._qgsMapCanvas.PdmHeightMM)
        
        featureCount = 0
        featureList = []
        try:
          #searchRadius = self._qgsMapCanvas.extent().width() * (identifyValue / 100.0)
          r = QgsRectangle()
          r.setXMinimum(pointFrom.x())
          r.setXMaximum(pointTo.x())
          r.setYMinimum(pointFrom.y())
          r.setYMaximum(pointTo.y())
    
          r = self._qgsMapCanvas.mapTool().toLayerCoordinates(qgsMapLayer, r)
    
          rq = QgsFeatureRequest()
          rq.setFilterRect(r)
          rq.setFlags(QgsFeatureRequest.ExactIntersect)
          for f in qgsMapLayer.getFeatures(rq):
            featureList.append(QgsFeature(f))
        except QgsCsException as cse:
          QgsMessageLog.logMessage(self.tr("Caught CRS exception") + ":\n" + cse.what(), u'IdentifyPlus', QgsMessageLog.CRITICAL)
        
        myFilter = False
    
        #renderer = qgsMapLayer.rendererV2() # неизвестность
    
        qgsVersion = int(unicode(QGis.QGIS_VERSION_INT))
        
        
        #if renderer is not None and (renderer.capabilities() | QgsFeatureRendererV2.ScaleDependent):
        #  if qgsVersion < 20200 and qgsVersion > 10900:
        #    renderer.startRender( self._qgsMapCanvas.mapRenderer().rendererContext(), qgsMapLayer)
        #  elif qgsVersion >= 20300:
        #    renderer.startRender( self._qgsMapCanvas.mapRenderer().rendererContext(), qgsMapLayer.pendingFields())
        #  else:
        #    renderer.startRender( self._qgsMapCanvas.mapRenderer().rendererContext(), qgsMapLayer)
            
        #  myFilter = renderer.capabilities() and QgsFeatureRendererV2.Filter
    
        #for f in featureList:
        #    if myFilter and not renderer.willRenderFeature(f): # какие-то фичи отсеивают
        #        continue
        #    featureCount += 1
        #    self.objects.append(ExtendedFeature(self._qgsMapCanvas, qgsMapLayer, f))
        
        #if renderer is not None and (renderer.capabilities() | QgsFeatureRendererV2.ScaleDependent):
        #  renderer.stopRender(self._qgsMapCanvas.mapRenderer().rendererContext())

        return featureList