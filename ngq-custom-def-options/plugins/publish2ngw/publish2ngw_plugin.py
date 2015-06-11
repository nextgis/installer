# -*- coding: utf-8 -*-

"""
***************************************************************************
    publish2ngw_plugin.py
    ---------------------
    Date                 : September 2014
    Copyright            : (C) 2014 by NextGIS
    Email                : info at nextgis dot com
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

__author__ = 'Alexander Bruy'
__date__ = 'September 2014'
__copyright__ = '(C) 2014, NextGIS'

# This will get replaced with a git SHA1 when you do a git archive

__revision__ = '$Format:%H$'


import os

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from qgis.core import *

from publishdialog import PublishDialog
from aboutdialog import AboutDialog

import resources_rc


class Publish2NGWPlugin:
    def __init__(self, iface):
        self.iface = iface

        self.qgsVersion = unicode(QGis.QGIS_VERSION_INT)

        pluginPath = os.path.abspath(os.path.dirname(__file__))
        overrideLocale = QSettings().value('locale/overrideFlag', False, bool)
        if not overrideLocale:
            locale = QLocale.system().name()[:2]
        else:
            locale = QSettings().value('locale/userLocale', '')

        translationPath = pluginPath + '/i18n/qscatter_' + locale + '.qm'

        if QFileInfo(translationPath).exists():
            self.translator = QTranslator()
            self.translator.load(self.localePath)
            QCoreApplication.installTranslator(self.translator)

    def initGui(self):
        if int(self.qgsVersion) < 20000:
            qgisVersion = self.qgsVersion[0] + '.' + self.qgsVersion[2] \
                + '.' + self.qgsVersion[3]
            QMessageBox.warning(self.iface.mainWindow(), 'Publish2NGW',
                QCoreApplication.translate('Publish2NGW',
                    'QGIS %s detected.\nThis version of Publish2NGW '
                    'requires at least QGIS 2.0. Plugin will not be '
                    'enabled.' % (qgisVersion)))
            return None

        self.actRun = QAction(QCoreApplication.translate(
            'Publish2NGW', 'Publish2NGW'), self.iface.mainWindow())
        self.actRun.setIcon(QIcon(':/icons/publish2ngw.svg'))
        self.actRun.setWhatsThis(QCoreApplication.translate(
            'Publish2NGW', 'Publish project on NextGIS Web'))

        self.actAbout = QAction(QCoreApplication.translate(
            'Publish2GW', 'About Publish2NGW...'),
            self.iface.mainWindow())
        self.actAbout.setIcon(QIcon(':/icons/about.png'))
        self.actAbout.setWhatsThis(
            QCoreApplication.translate('Publish2NGW', 'About Publish to NGW'))

        self.iface.addPluginToWebMenu(QCoreApplication.translate(
            'Publish2NGW', 'Publish2NGW'), self.actRun)
        self.iface.addPluginToWebMenu(QCoreApplication.translate(
            'Publish2NGW', 'Publish2NGW'), self.actAbout)

        self.iface.addWebToolBarIcon(self.actRun)

        self.actRun.triggered.connect(self.run)
        self.actAbout.triggered.connect(self.about)

    def unload(self):
        self.iface.removeWebToolBarIcon(self.actRun)

        self.iface.removePluginWebMenu(QCoreApplication.translate(
            'Publish2NGW', 'Publish2NGW'), self.actRun)
        self.iface.removePluginWebMenu(QCoreApplication.translate(
            'Publish2NGW', 'Publish2NGW'), self.actAbout)

    def run(self):
        dlg = PublishDialog(self.iface)
        dlg.exec_()

    def about(self):
        dlg = AboutDialog()
        dlg.exec_()
