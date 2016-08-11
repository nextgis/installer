# -*- coding: utf-8 -*-
"""
/***************************************************************************
    NextGIS WEB API
                              -------------------
        begin                : 2014-11-19
        git sha              : $Format:%H$
        copyright            : (C) 2014 by NextGIS
        email                : info@nextgis.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
import functools

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from ..core.ngw_connection import NGWConnection
from ..core.ngw_error import NGWError
from ..core.ngw_resource import NGWResource
from ..core.ngw_group_resource import NGWGroupResource
from ..core.ngw_resource_creator import ResourceCreator
from ..core.ngw_resource_factory import NGWResourceFactory

from qt_ngw_resource_item import QNGWResourceItemExt, AuxiliaryItem


class QNGWItem():
    type = "item"

    def __init__(self):
        self._children = []
        self._parent = None

    def parent(self):
        return self._parent

    def child(self, index):
        return self._children[index]

    def indexOfChild(self, child):
        return self._children.index(child)

    def appendChild(self, qngw_resource):
        self._children.append(qngw_resource)

    def appendChildren(self, qngw_resource_list):
        self._children.extend(qngw_resource_list)

    def childCount(self):
        return len(self._children)

    def removeChild(self, child):
        self._children.remove(child)


class QNGWItemConnection(QNGWItem):
    type = "connection"

    def __init__(self, ngw_connection):
        QNGWItem.__init__(self)
        self.ngw_connection = ngw_connection


class QNGWItemResource(QNGWItem):
    type = "resource"

    def __init__(self, ngw_resource=None):
        QNGWItem.__init__(self)
        self._ngw_resource = ngw_resource

    def resourceId(self):
        return self._ngw_resource.common.id


class QNGWResourcesModel(QAbstractItemModel):
    def __init__(self, ngw_connection_settings):
        QAbstractItemModel.__init__(self)
        self.resetModel(ngw_connection_settings)

    def resetModel(self, ngw_connection_settings):
        self.beginResetModel()

        self._ngw_connection_settings = ngw_connection_settings
        self._ngw_connection = NGWConnection(self._ngw_connection_settings)
        self._ngw_item_root = QNGWItemConnection(self._ngw_connection)

        self._workers = []
        self._threads = []

        self.endResetModel()
        self.modelReset.emit()

    def cleanModel(self):
        c = self._ngw_item_root.childCount()
        self.beginRemoveRows(QModelIndex(), 0, c - 1)
        for i in range(c - 1, -1, -1):
            self._ngw_item_root.removeChild(self._ngw_item_root.child(i))
        self.endRemoveRows()

    def index(self, row, column, parent):
        print "index"
        if not self.hasIndex(row, column, parent):
            return QModelIndex()

        if not parent.isValid():
            parent_item = self._ngw_item_root
        else:
            parent_item = parent.internalPointer()

        child_item = parent_item.child(row)
        if child_item:
            return self.createIndex(row, column, child_item)
        else:
            return QModelIndex()

    def parent(self, index):
        print "parent"
        if index and index.isValid():
            item = index.internalPointer()
        else:
            item = self._ngw_item_root

        parent_item = item.parent()
        if parent_item == self._ngw_item_root or not parent_item:
            return QModelIndex()

        return self.createIndex(
            parent_item.parent().indexOfChild(parent_item),
            index.column(),
            parent_item
        )

    def rowCount(self, parent):
        print "rowCount"
        if not parent.isValid():
            parent_item = self._ngw_item_root
        else:
            parent_item = parent.internalPointer()

        return parent_item.childCount()

    def canFetchMore(self, parent):
        print "canFetchMore"
        if not parent.isValid():
            return self._ngw_item_root.childCount() == 0
        else:
            parent_item = parent.internalPointer()

        # if isinstance(parent_item, QNGWResourceItemExt):
        #     ngw_resource = parent_item.data(0, QNGWResourceItemExt.NGWResourceRole)
        #     children_count = ngw_resource.common.children
        #     return children_count > parent_item.childCount()
        return False

    def fetchMore(self, parent):
        print "fetchMore"
        if not parent.isValid():
            self._ngw_item_root

            print "try load root resources START"
            rsc_factory = NGWResourceFactory(self._ngw_connection_settings)
            ngw_root_resource = rsc_factory.get_root_resource()
            self.thread().sleep(10)
            print "try load root resources FINNISH"

            self.beginInsertRows(parent, 0, 0)
            self._ngw_item_root.appendChild(QNGWItemResource(ngw_root_resource))
            self.endInsertRows()
            self.rowsInserted.emit(parent, 0, 0)
            self.startLoadChildren(parent)
        else:
            parent_item = parent.internalPointer()

        # if isinstance(parent_item, QNGWResourceItemExt):
        #     self.beginInsertRows(parent, 0, 0)
        #     parent_item.addChild(
        #         AuxiliaryItem("loading...")
        #     )
        #     self.endInsertRows()
        #     self.rowsInserted.emit(parent, 0, 0)
        #     self.startLoadChildren(parent)

    def columnCount(self, parent=None):
        return 1

    def data(self, index, role=None):
        print "data"
        if not index.isValid():
            return None

        if role == Qt.DisplayRole:
            return "test"

        return None
        # item = index.internalPointer()
        # return item.data(index.column(), role)

    def hasChildren(self, parent=None):
        print "hasChildren"
        if not parent.isValid():
            parent_item = self._ngw_item_root
        else:
            parent_item = parent.internalPointer()

        # if isinstance(parent_item, QNGWResourceItemExt):
        #     ngw_resource = parent_item.data(0, QNGWResourceItemExt.NGWResourceRole)
        #     children_count = ngw_resource.common.children
        #     return children_count > 0

        return parent_item.childCount() > 0

    # def _stratJobOnNGWResource(self, qobject_worker, job, callback, parent_index):
    #     # TODO clean stoped threads

    #     thread = QThread(self)
    #     qobject_worker.moveToThread(thread)
    #     thread.started.connect(qobject_worker.run)

    #     qobject_worker.started.connect(
    #         functools.partial(self.jobStarted.emit, job)
    #     )
    #     qobject_worker.statusChanged.connect(
    #         functools.partial(self.jobStatusChanged.emit, job)
    #     )
    #     qobject_worker.finished.connect(
    #         functools.partial(self.jobFinished.emit, job)
    #     )

    #     qobject_worker.errorOccurred.connect(
    #         functools.partial(self.errorOccurred.emit, job)
    #     )

    #     if job == self.JOB_NGW_RESOURCE_UPDATE:
    #         def processDoneJob(callback, index, ngw_resource):
    #             item = index.internalPointer()
    #             item.set_ngw_resource(ngw_resource)
    #             self.dataChanged.emit(index, index)
    #             callback()

    #         qobject_worker.done.connect(
    #             functools.partial(processDoneJob, callback, parent_index)
    #         )
    #     else:
    #         def processDoneJob(callback, index, *args):
    #             item = index.internalPointer()
    #             ngw_resource = item.data(0, item.NGWResourceRole)
    #             worker = NGWResourceUpdate(ngw_resource)
    #             self._stratJobOnNGWResource(
    #                 worker,
    #                 self.JOB_NGW_RESOURCE_UPDATE,
    #                 functools.partial(
    #                     callback,
    #                     *args
    #                 ),
    #                 index)

    #         qobject_worker.done.connect(
    #             functools.partial(processDoneJob, callback, parent_index)
    #         )

    #     # qobject_worker.finished.connect(thread.quit)
    #     # qobject_worker.finished.connect(qobject_worker.deleteLater)
    #     # qobject_worker.finished.connect(thread.deleteLater)

    #     thread.start()

    #     self.threads.append(thread)
    #     self.workers.append(qobject_worker)

# class NGWResourceModelJob(QObject):
#     started = pyqtSignal()
#     statusChanged = pyqtSignal(unicode)
#     errorOccurred = pyqtSignal(object)
#     finished = pyqtSignal()

#     def __init__(self):
#         QObject.__init__(self)

#     def generate_unique_name(self, name, present_names):
#         new_name = name
#         id = 1
#         if new_name in present_names:
#             while(new_name in present_names):
#                 new_name = name + "(%d)" % id
#                 id += 1
#         return new_name


# class NGWRootResourcesLoader(NGWResourceModelJob):
#     done = pyqtSignal(list)

#     def __init__(self, ngw_connection_settings):
#         NGWResourceModelJob.__init__(self)
#         self.ngw_connection_settings = ngw_connection_settings

#     def loadNGWResourceChildren(self):
#         try:
#             rsc_factory = NGWResourceFactory(self.ngw_connection_settings)
#             ngw_root_resource = rsc_factory.get_root_resource()

#             self.done.emit([ngw_root_resource])
#         except Exception as e:
#             self.errorOccurred.emit(e)

#     def run(self):
#         self.started.emit()
#         self.loadNGWResourceChildren()
#         self.finished.emit()


# class NGWResourcesLoader(NGWResourceModelJob):
#     done = pyqtSignal(list)

#     def __init__(self, ngw_parent_resource):
#         NGWResourceModelJob.__init__(self)
#         self.ngw_parent_resource = ngw_parent_resource

#     def loadNGWResourceChildren(self):
#         try:
#             ngw_resource_children = self.ngw_parent_resource.get_children()
#             if len(ngw_resource_children) == 0:
#                 return

#             self.done.emit(ngw_resource_children)
#         except Exception as e:
#             self.errorOccurred.emit(e)

#     def run(self):
#         self.started.emit()
#         self.loadNGWResourceChildren()
#         self.finished.emit()
