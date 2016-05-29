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
from PyQt4.QtCore import Qt
from PyQt4.QtGui import QIcon, QTreeWidgetItem

# from qgis.core import QgsMessageLog


class QNGWResourceItem():
    def __init__(self, ngw_resource, parent):
        self._ngw_resource = ngw_resource
        self._parent = parent
        self._children = []  # lazy load
        self._children_loads = False
        #print unicode(self.data(Qt.DisplayRole)), ' created!'  # debug

    def parent(self):
        return self._parent

    def row(self):
        if self._parent:
            return self._parent.get_children().index(self)
        else:
            return 0

    def get_children(self):
        if not self._children_loads:
            self._load_children()
        return self._children

    def get_child(self, row):
        if not self._children_loads:
            self._load_children()
        return self._children[row]

    def get_children_count(self):
        if not self._children_loads:
            self._load_children()
        return len(self._children)

    def _load_children(self):
        resource_children = self._ngw_resource.get_children()

        self._children = []
        for resource_child in resource_children:
            self._children.append(QNGWResourceItem(resource_child, self))

        self._children_loads = True

    def has_children(self):
        return self._ngw_resource.common.children

    def data(self, role):
        if role == Qt.DisplayRole:
            return self._ngw_resource.common.display_name
        if role == Qt.DecorationRole:
            return QIcon(self._ngw_resource.icon_path)
        if role == Qt.ToolTipRole:
            return self._ngw_resource.type_title
        if role == Qt.UserRole:
            return self._ngw_resource


class QNGWResourceItemExt(QTreeWidgetItem):
    CHILDREN_NOT_LOAD = 1
    CHILDREN_LOADING = 2
    CHILDREN_LOADED = 3

    NGWResourceRole = Qt.UserRole
    NGWResourceChildrenLoadRole = Qt.UserRole + 1

    def __init__(self, ngw_resource):
        QTreeWidgetItem.__init__(self)
        self.set_ngw_resource(ngw_resource)

    def set_ngw_resource(self, ngw_resource):
        if ngw_resource is not None:
            self.setText(0, ngw_resource.common.display_name)
            self.setIcon(0, QIcon(ngw_resource.icon_path))
            self.setToolTip(0, ngw_resource.type_title)
            self.setData(0, self.NGWResourceRole, ngw_resource)

        self.setData(0, self.NGWResourceChildrenLoadRole, self.CHILDREN_NOT_LOAD)

    # def has_children(self):
    #     ngw_resource = self.data(0, self.NGWResourceRole)
    #     if ngw_resource is None:
    #         return False
    #     return ngw_resource.common.children


class AuxiliaryItem(QTreeWidgetItem):
    def __init__(self, info):
        QTreeWidgetItem.__init__(self, [info])
