# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'publishdialogbase.ui'
#
# Created: Fri Nov 28 20:46:11 2014
#      by: PyQt4 UI code generator 4.9.1
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_Dialog(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName(_fromUtf8("Dialog"))
        Dialog.resize(502, 208)
        self.verticalLayout = QtGui.QVBoxLayout(Dialog)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.groupBox = QtGui.QGroupBox(Dialog)
        self.groupBox.setObjectName(_fromUtf8("groupBox"))
        self.gridLayout = QtGui.QGridLayout(self.groupBox)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.cmbConnections = QtGui.QComboBox(self.groupBox)
        self.cmbConnections.setObjectName(_fromUtf8("cmbConnections"))
        self.gridLayout.addWidget(self.cmbConnections, 0, 0, 1, 3)
        self.btnNew = QtGui.QPushButton(self.groupBox)
        self.btnNew.setObjectName(_fromUtf8("btnNew"))
        self.gridLayout.addWidget(self.btnNew, 1, 0, 1, 1)
        self.btnEdit = QtGui.QPushButton(self.groupBox)
        self.btnEdit.setObjectName(_fromUtf8("btnEdit"))
        self.gridLayout.addWidget(self.btnEdit, 1, 1, 1, 1)
        self.btnDelete = QtGui.QPushButton(self.groupBox)
        self.btnDelete.setObjectName(_fromUtf8("btnDelete"))
        self.gridLayout.addWidget(self.btnDelete, 1, 2, 1, 1)
        self.verticalLayout.addWidget(self.groupBox)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.label = QtGui.QLabel(Dialog)
        self.label.setObjectName(_fromUtf8("label"))
        self.horizontalLayout.addWidget(self.label)
        self.leProject = QtGui.QLineEdit(Dialog)
        self.leProject.setObjectName(_fromUtf8("leProject"))
        self.horizontalLayout.addWidget(self.leProject)
        self.btnBrowse = QtGui.QToolButton(Dialog)
        self.btnBrowse.setObjectName(_fromUtf8("btnBrowse"))
        self.horizontalLayout.addWidget(self.btnBrowse)
        self.verticalLayout.addLayout(self.horizontalLayout)
        self.progressBar = QtGui.QProgressBar(Dialog)
        self.progressBar.setMinimum(0)
        self.progressBar.setMaximum(1)
        self.progressBar.setProperty("value", 0)
        self.progressBar.setFormat(_fromUtf8(""))
        self.progressBar.setObjectName(_fromUtf8("progressBar"))
        self.verticalLayout.addWidget(self.progressBar)
        self.buttonBox = QtGui.QDialogButtonBox(Dialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Close|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.verticalLayout.addWidget(self.buttonBox)

        self.retranslateUi(Dialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), Dialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), Dialog.reject)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

    def retranslateUi(self, Dialog):
        Dialog.setWindowTitle(QtGui.QApplication.translate("Dialog", "Publish project", None, QtGui.QApplication.UnicodeUTF8))
        self.groupBox.setTitle(QtGui.QApplication.translate("Dialog", "Connections", None, QtGui.QApplication.UnicodeUTF8))
        self.btnNew.setText(QtGui.QApplication.translate("Dialog", "New", None, QtGui.QApplication.UnicodeUTF8))
        self.btnEdit.setText(QtGui.QApplication.translate("Dialog", "Edit", None, QtGui.QApplication.UnicodeUTF8))
        self.btnDelete.setText(QtGui.QApplication.translate("Dialog", "Delete", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("Dialog", "Project file", None, QtGui.QApplication.UnicodeUTF8))
        self.btnBrowse.setText(QtGui.QApplication.translate("Dialog", "...", None, QtGui.QApplication.UnicodeUTF8))

