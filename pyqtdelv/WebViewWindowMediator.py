# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
from PyQt4 import QtCore, QtGui
import WebViewUtils

class WebViewWindowMediator():
    def __init__(self, WebViewWindow_UI, parent=None):
        if parent:
            self.parent = parent
        else:
            self.parent = QtGui.QMainWindow()
        self.wvw = WebViewWindow_UI
        self.wvw.setupUi(self.parent)
        self.wvw.widget = self.parent

        view = WebViewUtils.SnapSVGWebView(self.parent)
        self.setWebPageView(view)
   
    def show(self):
        self.wvw.widget.show()

    def close(self):
        self.wvw.widget.close()

    def resize(self, width, height):
        self.wvw.widget.resize(int(width), int(height))

    def setTitle(self, title):
        self.wvw.widget.setWindowTitle(QtGui.QApplication.translate("WebViewWindow", title, None, QtGui.QApplication.UnicodeUTF8))

    def exposeToJavaScript(self, name = None, obj = None):
        # expose data interface to javascript
        if name:
            self.WebPageView.addToJavaScript(name, obj);
        else:
            self.WebPageView.addToJavaScript("TheApp", self.WebPageView)

    def connectSignal(self, signal, function):
        QtCore.QObject.connect(self.WebPageView,
                               QtCore.SIGNAL(signal),
                               function)

    def connectWindowCleared(self, function):
        self.WebPageView.page().mainFrame().javaScriptWindowObjectCleared.connect(function)

    def connectLoadFinished(self, function):
        self.WebPageView.loadFinished.connect(function)
        
    def evaluateJavaScript(self, js):
        return self.WebPageView.evaluateJavaScript(js)

    def setWebPageView(self, view):
        self.WebPageView = view
        self.wvw.widget.setCentralWidget(view)

    def load(self, url):
        self.WebPageView.load(url)



