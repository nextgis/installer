# -*- coding: utf-8 -*-

"""
***************************************************************************
    publishdialog.py
    ---------------------
    Date                 : September 2014
    Copyright            : (C) 2014 by NextGIS
    Email                : info at nextgis dot org
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

__author__ = 'NextGIS'
__date__ = 'September 2014'
__copyright__ = '(C) 2014, NextGIS'

# This will get replaced with a git SHA1 when you do a git archive

__revision__ = '$Format:%H$'

import time
import sys
import re
import json
import datetime
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtXml import *
from qgis.core import *
from qgis.gui import *
import requests
import os
import glob
import uuid
import tempfile
import zipfile
from newngwconnectiondialog import NewNGWConnectionDialog
from ui_publishdialogbase import Ui_Dialog


class PublishDialog(QDialog, Ui_Dialog):
    def __init__(self, iface):
        QDialog.__init__(self)
        self.setupUi(self)

        self.iface = iface

        self.btnOk = self.buttonBox.button(QDialogButtonBox.Ok)
        self.btnClose = self.buttonBox.button(QDialogButtonBox.Close)

        self.btnNew.clicked.connect(self.newConnection)
        self.btnEdit.clicked.connect(self.editConnection)
        self.btnDelete.clicked.connect(self.deleteConnection)

        self.btnBrowse.clicked.connect(self.selectProject)

        self.populateConnectionList()

    def newConnection(self):
        dlg = NewNGWConnectionDialog(self)
        if dlg.exec_():
            self.populateConnectionList()
        del dlg

    def editConnection(self):
        dlg = NewNGWConnectionDialog(self, self.cmbConnections.currentText())
        if dlg.exec_():
            self.populateConnectionList()
        del dlg

    def deleteConnection(self):
        key = '/connections/' + self.cmbConnections.currentText()
        settings = QSettings('NextGIS', 'publish2ngw')
        settings.remove(key)

        self.populateConnectionList()

    def populateConnectionList(self):
        self.cmbConnections.clear()

        settings = QSettings('NextGIS', 'publish2ngw')
        settings.beginGroup('/connections')
        self.cmbConnections.addItems(settings.childGroups())
        settings.endGroup()

        lastConnection = settings.value('/ui/lastConnection', '')
        idx = self.cmbConnections.findText(lastConnection)
        if idx == -1 and self.cmbConnections.count() > 0:
            self.cmbConnections.setCurrentIndex(0)
        else:
            self.cmbConnections.setCurrentIndex(idx)

        if self.cmbConnections.count() == 0:
            self.btnEdit.setEnabled(False)
            self.btnDelete.setEnabled(False)
        else:
            self.btnEdit.setEnabled(True)
            self.btnDelete.setEnabled(True)

    def selectProject(self):
        settings = QSettings('NextGIS', 'publish2ngw')
        lastDirectory = settings.value('lastDirectory', '.')
        fileName = QFileDialog.getOpenFileName(self, self.tr('Select project'), lastDirectory, self.tr('QGIS files (*.qgs *.QGS)'))

        if fileName == '':
            return

        self.leProject.setText(fileName)
        settings.setValue('lastDirectory', QFileInfo(fileName).absoluteDir().absolutePath())

    def reject(self):
        settings = QSettings('NextGIS', 'publish2ngw')
        settings.setValue('/ui/lastConnection', self.cmbConnections.currentText())
        QDialog.reject(self)

    def accept(self):
        projectFile = QFile(self.leProject.text())
        if not projectFile.open(QIODevice.ReadOnly | QIODevice.Text):
            return

        doc = QDomDocument()
        success, error, lineNum, columnNum = doc.setContent(projectFile, True)
        if not success:
            return

        projectFile.close()

        settings = QSettings('NextGIS', 'publish2ngw')
        key = '/connections/' + self.cmbConnections.currentText()
        self.url = settings.value(key + '/url', '')
        self.user = settings.value(key + '/user', '')
        self.password = settings.value(key + '/password', '')

        self.btnOk.setEnabled(False)
        self.btnClose.setEnabled(False)
        QApplication.processEvents()

        layers = dict()
        if doc is not None:
            layerNodes = doc.elementsByTagName('maplayer')
            for i in xrange(layerNodes.size()):
                element = layerNodes.at(i).toElement()
                layers[element.firstChildElement('id').text()] = element

        self.progressBar.setRange(0, len(layers))
        self.progressBar.setValue(0)
        self.progressBar.setFormat('%v/%m')

        projectTitle = ''
        root = doc.documentElement()
        e = root.firstChildElement('title')
        projectTitle = e.text()
        if projectTitle == '':
            projectTitle = QFileInfo(self.leProject.text()).baseName()

        QgsMessageLog.logMessage('Creating group', 'Publish2NGW', QgsMessageLog.INFO)
        QApplication.processEvents()

        finished = False
        while not finished:
            try:
                url = self.url + '/resource/0/child/'
                params = dict(resource=dict(cls='resource_group', display_name=projectTitle))
                group = requests.post(url, auth=(self.user, self.password), data=json.dumps(params))
                finished = True
            except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
                ret = QMessageBox.question(self, self.tr('Retry'), self.tr('Unable to publish. Retry in 30 sec?'), QMessageBox.Retry | QMessageBox.Cancel, QMessageBox.Cancel)
                if ret == QMessageBox.Retry:
                    time.sleep(30)
                    continue
                else:
                    QgsMessageLog.logMessage('Canceled by user', 'Publish2NGW', QgsMessageLog.INFO)
                    self.canceled()
                    return
            except requests.exceptions.RequestException, e:
                group = None
                QgsMessageLog.logMessage('Unable to create resource group %s: %s' % (projectTitle, e.message), 'Publish2NGW', QgsMessageLog.INFO)
                self.canceled()
                return

        if group:
            groupId = group.json()['id']

            projectTree = self.layerTree(doc)

            for layerId, layerElement in layers.iteritems():
                layer = None
                dataSource = layerElement.firstChildElement('datasource')

                uri = dataSource.text()
                if uri.startswith('dbname'):
                    dsUri = QgsDataSourceURI(uri)
                    if dsUri.host() == '':
                        dbPath = dsUri.database()
                        absolutePath = self.fullLayerPath(dbPath, self.leProject.text())
                        if dbPath != absolutePath:
                            dsUri.setDatabase(absolutePath)
                            node = doc.createTextNode(dsUri.uri())
                            dataSource.replaceChild(node, dataSource.firstChild())
                else:
                    absolutePath = self.fullLayerPath(uri, self.leProject.text())
                    if absolutePath != uri:
                        node = doc.createTextNode(absolutePath)
                        dataSource.replaceChild(node, dataSource.firstChild())

                layerType = layerElement.attribute('type')
                if layerType == 'vector':
                    layer = QgsVectorLayer()
                elif layerType == 'raster':
                    layer = QgsRasterLayer()
                if layer:
                    layer.readLayerXML(layerElement)
                    layer.setLayerName(layerElement.firstChildElement('layername').text())

                if layer is None:
                    continue

                self.progressBar.setValue(self.progressBar.value() + 1)
                QgsMessageLog.logMessage('Publishing %s' % layer.name(), 'Publish2NGW', QgsMessageLog.INFO)
                QApplication.processEvents()

                if not absolutePath.startswith('dbname'):
                    if not os.path.exists(absolutePath):
                        time.sleep(10)
                        QgsMessageLog.logMessage('Layer not found', 'Publish2NGW', QgsMessageLog.INFO)
                        continue

                finished = False
                while not finished:
                    try:
                        resLayer = self.addLayer(groupId, layer.name(), layer)
                        finished = True
                    except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
                        ret = QMessageBox.question(self, self.tr('Retry'), self.tr('Unable to publish. Retry in 30 sec?'), QMessageBox.Retry | QMessageBox.Cancel, QMessageBox.Cancel)
                        if ret == QMessageBox.Retry:
                            time.sleep(30)
                            continue
                        else:
                            QgsMessageLog.logMessage('Canceled by user', 'Publish2NGW', QgsMessageLog.INFO)
                            ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                            if ret == QMessageBox.Yes:
                                url = self.url + '/resource/0/child/' + groupId
                                requests.delete(url, auth=(self.user, self.password))
                            self.canceled()
                            return

                if resLayer is None:
                    QgsMessageLog.logMessage('Layer upload failed. Exiting', 'Publish2NGW', QgsMessageLog.INFO)
                    ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                    if ret == QMessageBox.Yes:
                        url = self.url + '/resource/0/child/' + str(groupId)
                        requests.delete(url, auth=(self.user, self.password))
                    self.canceled()
                    return

                if resLayer.status_code / 100 != 2:
                    msg = json.dumps(resLayer.json()['message'], ensure_ascii=False).strip('"')
                    QgsMessageLog.logMessage('NGW error: %s' % msg, 'Publish2NGW', QgsMessageLog.INFO)
                    ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                    if ret == QMessageBox.Yes:
                        url = self.url + '/resource/0/child/' + str(groupId)
                        requests.delete(url, auth=(self.user, self.password))
                    self.canceled()
                    return

                QgsMessageLog.logMessage('Publishing style for %s' % layer.name(), 'Publish2NGW', QgsMessageLog.INFO)
                QApplication.processEvents()
                finished = False
                while not finished:
                    try:
                        resStyle = self.addStyle(resLayer, layer).json()
                        finished = True
                    except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
                        ret = QMessageBox.question(self, self.tr('Retry'), self.tr('Unable to publish. Retry in 30 sec?'), QMessageBox.Retry | QMessageBox.Cancel, QMessageBox.Cancel)
                        if ret == QMessageBox.Retry:
                            time.sleep(30)
                            continue
                        else:
                            QgsMessageLog.logMessage('Canceled by user', 'Publish2NGW', QgsMessageLog.INFO)
                            ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                            if ret == QMessageBox.Yes:
                                url = self.url + '/resource/0/child/' + groupId
                                requests.delete(url, auth=(self.user, self.password))
                            self.canceled()
                            return

                if not isinstance(resStyle, dict) and resStyle.status_code / 100 != 2:
                    msg = json.dumps(resStyle.json()['message'], ensure_ascii=False).strip('"')
                    QgsMessageLog.logMessage('NGW error: %s' % msg, 'Publish2NGW', QgsMessageLog.INFO)
                    ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                    if ret == QMessageBox.Yes:
                        url = self.url + '/resource/0/child/' + str(groupId)
                        requests.delete(url, auth=(self.user, self.password))
                    self.canceled()
                    return

                self.updateLayerData(projectTree, layerId, resStyle['id'])

            mapTitle = projectTitle + '-map'
            authIdElem = doc.documentElement().firstChildElement('mapcanvas').firstChildElement('destinationsrs').firstChildElement('spatialrefsys').firstChildElement('authid')
            if not authIdElem.isNull():
                crs = QgsCRSCache.instance().crsByAuthId(authIdElem.text())
            else:
                crs = QgsCRSCache.instance().crsByEpsgId(4326)

            extent = QgsRectangle()
            root = doc.documentElement()
            canvas = root.firstChildElement('mapcanvas')
            e = canvas.firstChildElement('extent')
            xMin = float(e.firstChildElement('xmin').text())
            xMax = float(e.firstChildElement('xmax').text())
            yMin = float(e.firstChildElement('ymin').text())
            yMax = float(e.firstChildElement('ymax').text())

            extent.set(xMin, yMin, xMax, yMax)

            crsTransform = QgsCoordinateTransform(crs, QgsCoordinateReferenceSystem(4326))
            outExtent = crsTransform.transformBoundingBox(extent)

            QgsMessageLog.logMessage('Creating map', 'Publish2NGW', QgsMessageLog.INFO)
            QApplication.processEvents()
            finished = False
            while not finished:
                try:
                    mapTree = self.paramsFromLayerTree(projectTree)
                    if mapTree is None:
                        QgsMessageLog.logMessage('Unable to create web-map: there are no styles.', 'Publish2NGW', QgsMessageLog.INFO)
                        self.canceled()
                        return

                    url = self.url + '/resource/' + str(groupId) + '/child/'
                    params = dict(resource=dict(cls='webmap', display_name=mapTitle, parent=dict(id=groupId)), webmap=dict(extent_left=outExtent.xMinimum(), extent_right=outExtent.xMaximum(), extent_top=outExtent.yMaximum(), extent_bottom=outExtent.yMinimum(), root_item=dict(item_type='root', children=mapTree)))
                    m = requests.post(url, auth=(self.user, self.password), data=json.dumps(params))
                    finished = True
                except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
                    ret = QMessageBox.question(self, self.tr('Retry'), self.tr('Unable to publish. Retry in 30 sec?'), QMessageBox.Retry | QMessageBox.Cancel, QMessageBox.Cancel)
                    if ret == QMessageBox.Retry:
                        time.sleep(30)
                        continue
                    else:
                        QgsMessageLog.logMessage('Canceled by user', 'Publish2NGW', QgsMessageLog.INFO)
                        ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                        if ret == QMessageBox.Yes:
                            url = self.url + '/resource/0/child/' + groupId
                            requests.delete(url, auth=(self.user, self.password))
                        self.canceled()
                        return
                except requests.exceptions.RequestException, e:
                    QgsMessageLog.logMessage(e.message, 'Publish2NGW', QgsMessageLog.INFO)
                    ret = QMessageBox.question(self, self.tr('Cleanup'), self.tr('Publishing error. Drop resource group?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
                    if ret == QMessageBox.Yes:
                        url = self.url + '/resource/0/child/' + groupId
                        requests.delete(url, auth=(self.user, self.password))
                    self.canceled()
                    return
            self.published(m)

    def published(self, wmap):
        ret = QMessageBox.question(self, self.tr('Finished'), self.tr('Publishing completed.\n\nOpen map?'), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if ret == QMessageBox.Yes:
            QDesktopServices.openUrl(QUrl(self.url + '/resource/' + str(wmap.json()['id']) + '/display'))
        self.btnOk.setEnabled(True)
        self.btnClose.setEnabled(True)
        self.progressBar.setRange(0, 1)
        self.progressBar.setValue(0)
        self.progressBar.setFormat('')

    def canceled(self):
        QMessageBox.warning(self, self.tr('Finished'), self.tr('Publishing failed. See log for more details'))
        self.btnOk.setEnabled(True)
        self.btnClose.setEnabled(True)
        self.progressBar.setRange(0, 1)
        self.progressBar.setValue(0)
        self.progressBar.setFormat('')

    def addLayer(self, parent, name, layer):
        layerName = layer.name()
        layerType = layer.type()
        provider = layer.providerType()

        auth = (self.user, self.password)

        try:
            if layerType == QgsMapLayer.VectorLayer:
                if provider == 'ogr':
                    source = self.exportToShapeFile(layer)
                    filePath = self.compressShapeFile(source)
                    with open(filePath, 'rb') as f:
                        fl = requests.put(self.url + '/file_upload/upload', auth=auth, data=f)

                    url = self.url + '/resource/' + str(parent) + '/child/'
                    params = dict(resource=dict(cls='vector_layer', display_name=name), vector_layer=dict(srs=dict(id=3857), source=fl.json()))
                    res = requests.post(url, auth=auth, data=json.dumps(params))
                    return res
                elif provider == 'postgres':
                    metadata = layer.source().split(' ')
                    regex = re.compile('^host=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    host = tmp[pos + 1:]
                    regex = re.compile('^dbname=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    dbname = tmp[pos + 2:-1]
                    regex = re.compile('^user=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    userName = tmp[pos + 2:-1]
                    regex = re.compile('^password=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    password = tmp[pos + 2:-1]
                    regex = re.compile('^key=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    key = tmp[pos + 2:-1]
                    regex = re.compile('^table=.*')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    tmp = metadata[pos]
                    pos = tmp.find('=')
                    tmp = tmp[pos + 2:-1].split('.')
                    schema = tmp[0][:-1]
                    table = tmp[1][1:]
                    regex = re.compile('^\(.*\)')
                    pos = metadata.index([m.group(0) for l in metadata for m in [regex.search(l)] if m][0])
                    column = metadata[pos][1:-1]

                    url = self.url + '/resource/' +str(parent) +'/child/'
                    connName = host + '-' + dbname + '-' + datetime.datetime.now().isoformat()
                    params = dict(resource=dict(cls='postgis_connection', display_name=connName), postgis_connection=dict(hostname=host, database=dbname, username=userName, password=password))
                    c = requests.post(url, auth=auth, data=json.dumps(params))
                    params = dict(resource=dict(cls='postgis_layer', display_name=name), postgis_layer=dict(srs=dict(id=3857), fields='update', connection=c.json(), table=table, schema=schema, column_id=key, column_geom=column))
                    res = requests.post(url, auth=auth, data=json.dumps(params))
                    return res
                else:
                    QgsMessageLog.logMessage('Unable to publish layer %s: unsupported data provider: %s.' % (layerName, provider), 'PublishToNGW', QgsMessageLog.INFO)
                    return None
            elif layerType == QgsMapLayer.RasterLayer:
                if provider == 'gdal':
                    filePath = layer.source()
                    with open(filePath, 'rb') as f:
                        fl = requests.put(self.url + '/file_upload/upload', auth=auth, data=f)

                    url = self.url + '/resource/' + str(parent) + '/child/'
                    params = dict(resource=dict(cls='raster_layer', display_name=name), raster_layer=dict(srs=dict(id=3857), source=fl.json()))
                    res = requests.post(url, auth=auth, data=json.dumps(params))
                    return res
                elif provider == 'wms':
                    metadata = layer.source()
                    regex = re.compile('format=.*?&')
                    m = regex.search(metadata)
                    tmp = metadata[m.start():m.end() - 1]
                    pos = tmp.find('=')
                    imgFormat = tmp[pos + 1:]
                    regex = re.compile('layers=.*?&')
                    m = regex.findall(metadata)
                    tmp = []
                    for i in m:
                        pos = i.find('=')
                        tmp.append(i[pos+1:-1])
                    layers = ','.join(tmp)
                    regex = re.compile('url=.*')
                    m = regex.search(metadata)
                    tmp = metadata[m.start():m.end()]
                    pos = tmp.find('=')
                    uri = tmp[pos + 1:]
                    regex = re.compile('//.*/')
                    m = regex.search(uri)
                    host = uri[m.start():m.end()][2:-1]
                    url = self.url + '/resource/' + str(parent) + '/child/'
                    connName = host + '-' + datetime.datetime.now().isoformat()
                    params = dict(resource=dict(cls='wmsclient_connection', display_name=connName), wmsclient_connection=dict(url=uri, version='1.1.1', capcache='query'))
                    c = requests.post(url, auth=auth, data=json.dumps(params))
                    params = dict(resource=dict(cls='wmsclient_layer', display_name=name), wmsclient_layer=dict(srs=dict(id=3857), wmslayers=layers, imgformat=imgFormat, connection=c.json()))
                    res = requests.post(url, auth=auth, data=json.dumps(params))
                    return res
                else:
                    QgsMessageLog.logMessage('Unable to publish layer %s: unsupported data provider: %s.' % (layerName, provider), 'Publish2NGW', QgsMessageLog.INFO)
                    return None
            else:
                QgsMessageLog.logMessage('Unable to publish layer %s: unsupported layer type %s' % (layerName, layerType), 'Publish2NGW', QgsMessageLog.INFO)
                return None
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
            if hasattr(e, 'message'):
                QgsMessageLog.logMessage(str(e.message), 'Publish2NGW', QgsMessageLog.INFO)
            else:
                QgsMessageLog.logMessage(unicode(e), 'Publish2NGW', QgsMessageLog.INFO)
            raise
        except requests.exceptions.RequestException, e:
            QgsMessageLog.logMessage('Unable to publish layer %s: %s' % (layerName, e.message), 'Publish2NGW', QgsMessageLog.INFO)
            return None

    def addStyle(self, resource, layer):
        layerId = resource.json()['id']
        layerName = layer.name()
        layerType = layer.type()
        provider = layer.providerType()

        auth = (self.user, self.password)
        styleName = layerName + '-style'

        try:
            if layerType == QgsMapLayer.VectorLayer:
                tmp = self.tempFileName('.qml')
                msg, saved = layer.saveNamedStyle(tmp)

                with open(tmp, 'rb') as f:
                    styleFile = requests.put(self.url + '/file_upload/upload', auth=auth, data=f)

                url = self.url + '/mapserver/qml-transform'
                params = dict(file=dict(upload_meta=[styleFile.json()]))

                hdrAccept = {'Accept': 'application/json'}
                ngwStyle = requests.post(url, auth=auth, headers=hdrAccept, data=json.dumps(params))

                url = self.url + '/resource/' + str(layerId) +'/child/'
                params = dict(resource=dict(cls='mapserver_style', display_name=styleName, parent=dict(id=layerId)), mapserver_style=dict(xml=ngwStyle.json()))
                res = requests.post(url, auth=auth, data=json.dumps(params))
                return res
            elif layerType == QgsMapLayer.RasterLayer:
                if provider == 'gdal':
                    url = self.url + '/resource/' + str(layerId) +'/child/'
                    params = dict(resource=dict(cls='raster_style', display_name=styleName, parent=dict(id=layerId)))
                    res = requests.post(url, auth=auth, data=json.dumps(params))
                    return res
                elif provider == 'wms':
                    return resource
                else:
                    QgsMessageLog.logMessage('Unable to publish style for layer %s: unsupported data provider: %s.' % (layerName, provider), 'Publish2NGW', QgsMessageLog.INFO)
                    return None
            else:
                QgsMessageLog.logMessage('Unable to publish style for layer %s: unsupported layer type %s' % (layerName, layerType), 'Publish2NGW', QgsMessageLog.INFO)
                return None
        except (requests.exceptions.ConnectionError, requests.exceptions.Timeout), e:
            if hasattr(e, 'message'):
                QgsMessageLog.logMessage(unicode(e.message), 'Publish2NGW', QgsMessageLog.INFO)
            else:
                QgsMessageLog.logMessage(unicode(e), 'PublishToNGW', QgsMessageLog.INFO)
            raise
        except requests.exceptions.RequestException, e:
            QgsMessageLog.logMessage('Unable to publish layer %s: %s' % (layerName, e.message), 'Publish2NGW', QgsMessageLog.INFO)
            return None

    def updateLayerData(self, data, layerId, styleId):
        for item in data:
            if item['itemType'] == 'layer' and item['id'] == layerId:
                item['styleId'] = styleId
            elif item['itemType'] == 'group':
                item['layers'] = self.updateLayerData(item['layers'], layerId, styleId)
        return data

    def layerTree(self, doc):
        tree = []

        legend = doc.documentElement().firstChildElement('legend')
        child = legend.firstChildElement()
        while not child.isNull():
            e = child.toElement()
            itemType = e.tagName()
            if itemType == 'legendlayer':
                layer = dict()
                layer['itemType'] = 'layer'
                fileNodes = e.elementsByTagName('legendlayerfile')
                lid = fileNodes.at(0).toElement().attribute('layerid')
                layer['id'] = lid
                layer['name'] = e.attribute('name')
                layer['enabled'] = 'true' if e.attribute('checked') == 'Qt::Checked' else 'false'
                tree.append(layer)
            elif itemType == 'legendgroup':
                group = dict()
                group['itemType'] = 'group'
                group['name'] = e.attribute('name')
                group['open'] = e.attribute('open')
                group['layers'] = []

                legendLayer = e.firstChildElement()
                while not legendLayer.isNull():
                    layer = dict()
                    layer['itemType'] = 'layer'
                    fileNodes = legendLayer.elementsByTagName('legendlayerfile')
                    lid = fileNodes.at(0).toElement().attribute('layerid')
                    layer['id'] = lid
                    layer['name'] = legendLayer.attribute('name')
                    layer['enabled'] = 'true' if legendLayer.attribute('checked') == 'Qt::Checked' else 'false'

                    group['layers'].append(layer)

                    legendLayer = legendLayer.nextSiblingElement()
                tree.append(group)

            child = child.nextSiblingElement()

        return tree

    def fullLayerPath(self, source, filePath):
        if not source.startswith(('./', '../')):
            return source

        src = source
        prj = filePath

        if sys.platform == 'win32':
            src = src.replace('\\', '/')
            prj = prj.replace('\\', '/')
            uncPath = prj.startswith('//')

        layerParts = [s for s in src.split('/') if s]
        projectParts = [s for s in prj.split('/') if s]

        if sys.platform == 'win32' and uncPath:
            projectParts.insert(0, '')
            projectParts.insert(0, '')

        projectParts = projectParts[:-1]
        projectParts.extend(layerParts)
        projectParts = [elem for elem in projectParts if elem != '.']

        while '..' in projectParts:
            i = projectParts.index('..')
            projectParts.pop(i - 1)
            projectParts.pop(i - 1)

        if sys.platform != 'win32':
            projectParts.insert(0, '')

        return '/'.join(projectParts)

    def tempFileName(self, suffix):
        fName = os.path.join(
            tempfile.gettempdir(), unicode(uuid.uuid4()).replace('-', '') + suffix)
        return fName

    def exportToShapeFile(self, layer):
        tmp = self.tempFileName('.shp')
        QgsVectorFileWriter.writeAsVectorFormat(layer, tmp, 'utf-8', layer.crs())
        return tmp

    def compressShapeFile(self, filePath):
        tmp = self.tempFileName('.zip')
        basePath = os.path.splitext(filePath)[0]
        baseName = os.path.splitext(os.path.basename(filePath))[0]

        zf = zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED)
        for i in glob.iglob(basePath + '.*'):
            ext = os.path.splitext(i)[1]
            zf.write(i, baseName + ext)

        zf.close()
        return tmp

    def paramsFromLayerTree(self, tree):
        params = []
        for item in tree:
            if item['itemType'] == 'layer':
                if 'styleId' not in item:
                    return params
                layer = dict(item_type='layer', display_name=item['name'], layer_style_id=item['styleId'], layer_enabled=item['enabled'], layer_adapter='image', children=[])
                params.append(layer)
            elif item['itemType'] == 'group':
                group = dict(item_type='group', display_name=item['name'], group_expanded=item['open'], children=self.paramsFromLayerTree(item['layers']))
                params.append(group)
        return params
