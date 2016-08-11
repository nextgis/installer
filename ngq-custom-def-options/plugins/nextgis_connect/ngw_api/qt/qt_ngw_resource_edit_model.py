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

from qt_ngw_resource_model_job import NGWGroupCreater, NGWResourceDelete, NGWCreateWFSForVector
from qt_ngw_resource_base_model import QNGWResourcesBaseModel


class QNGWResourcesModel(QNGWResourcesBaseModel):

    JOB_CREATE_NGW_GROUP_RESOURCE = "CREATE_NGW_GROUP_RESOURCE"
    JOB_DELETE_NGW_RESOURCE = "DELETE_NGW_RESOURCE"
    JOB_CREATE_NGW_WFS_SERVICE = "CREATE_NGW_WFS_SERVICE"

    def __init__(self, parent):
        QNGWResourcesBaseModel.__init__(self, parent)

    def tryCreateNGWGroup(self, new_group_name, parent_index):
        if not parent_index.isValid():
            parent_index = self.index(0, 0, parent_index)

        parent_index = self._nearest_ngw_group_resource_parent(parent_index)

        parent_item = parent_index.internalPointer()
        ngw_resource_parent = parent_item.data(0, parent_item.NGWResourceRole)

        if ngw_resource_parent is None:
            return False

        worker = NGWGroupCreater(new_group_name, ngw_resource_parent)
        self._stratJobOnNGWResource(
            parent_index,
            worker,
            self.JOB_CREATE_NGW_GROUP_RESOURCE,
            [self.__askReloadChildren],
        )

    def __askReloadChildren(self):
        job_index = self._getJobIndexByJob(self.sender())
        if job_index == -1:
            return

        (index, job) = self.jobs.pop(
            job_index
        )

        self._reloadChildren(index)

    def deleteResource(self, index):
        parent_index = self.parent(index)

        item = index.internalPointer()
        ngw_resource = item.data(0, item.NGWResourceRole)

        worker = NGWResourceDelete(ngw_resource)
        self._stratJobOnNGWResource(
            parent_index,
            worker,
            self.JOB_DELETE_NGW_RESOURCE,
            [self.__askReloadChildren],
        )

    def createWFSForVector(self, index, ret_obj_num):
        if not index.isValid():
            index = self.index(0, 0, index)

        parent_index = self._nearest_ngw_group_resource_parent(index)

        parent_item = parent_index.internalPointer()
        ngw_parent_resource = parent_item.data(0, Qt.UserRole)

        item = index.internalPointer()
        ngw_resource = item.data(0, Qt.UserRole)

        worker = NGWCreateWFSForVector(ngw_resource, ngw_parent_resource, ret_obj_num)
        self._stratJobOnNGWResource(
            parent_index,
            worker,
            self.JOB_CREATE_NGW_WFS_SERVICE,
            [self.__askReloadChildren],
        )
