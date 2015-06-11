# -*- coding: utf-8 -*-

"""
***************************************************************************
    newngwconnectiondialog.py
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

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from qgis.core import *
from qgis.gui import *

from ui_newngwconnectiondialogbase import Ui_Dialog


class NewNGWConnectionDialog(QDialog, Ui_Dialog):
    def __init__(self, parent, connectionName=None):
        QDialog.__init__(self, parent)
        self.setupUi(self)

        self.connectionName = connectionName

        if self.connectionName is not None:
            settings = QSettings('NextGIS', 'publish2ngw')
            key = '/connections/' + self.connectionName

            self.leName.setText(self.connectionName)
            self.leUrl.setText(settings.value(key + '/url', ''))
            self.leUser.setText(settings.value(key + '/user', ''))
            self.lePassword.setText(settings.value(key + '/password', ''))

    def accept(self):
        settings = QSettings('NextGIS', 'publish2ngw')
        if self.connectionName is not None and self.connectionName != self.leName.text():
            settings.remove('/connections/' + self.connectionName)

        key = '/connections/' + self.leName.text()
        settings.setValue(key + '/url', self.leUrl.text())
        settings.setValue(key + '/user', self.leUser.text())
        settings.setValue(key + '/password', self.lePassword.text())

        QDialog.accept(self)
