# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'WebViewWindow.ui'
#
# Created: Wed Aug 22 09:17:32 2012
#      by: PyQt4 UI code generator 4.6.1-snapshot-20091014
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

class Ui_WebViewWindow(object):
    def setupUi(self, WebViewWindow):
        WebViewWindow.setObjectName("WebViewWindow")
        WebViewWindow.resize(640, 480)
        self.centralwidget = QtGui.QWidget(WebViewWindow)
        self.centralwidget.setObjectName("centralwidget")
        WebViewWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtGui.QMenuBar(WebViewWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 640, 22))
        self.menubar.setObjectName("menubar")
        WebViewWindow.setMenuBar(self.menubar)
        self.statusbar = QtGui.QStatusBar(WebViewWindow)
        self.statusbar.setObjectName("statusbar")
        WebViewWindow.setStatusBar(self.statusbar)

        self.retranslateUi(WebViewWindow)
        QtCore.QMetaObject.connectSlotsByName(WebViewWindow)

    def retranslateUi(self, WebViewWindow):
        pass

