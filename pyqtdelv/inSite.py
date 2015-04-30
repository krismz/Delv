# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
import os
import sys
from PyQt4 import QtCore
from PyQt4 import QtGui
from PyQt4 import QtSvg
from PyQt4 import QtWebKit

# wait to import until after the sys.path has been set appropriately

fullpath = os.path.split(os.path.abspath(__file__))[0]
parentdir = os.path.split(fullpath)[0]
print "fullpath: ", fullpath
print "parentdir: ", parentdir
sys.path.append(os.path.join(parentdir, 'Utilities'))
sys.path.append(os.path.join(parentdir, 'UI'))
sys.path.append(os.path.join(parentdir, 'pydelv'))

import WebViewUtils
import WebViewWindow
from WebViewWindowMediator import *
import DataInterface

# inherit from QObject if want to be passed to javascript
class MainWindow(QtCore.QObject):
#class MainWindow():
    def __init__(self, url, demo_type):
        QtCore.QObject.__init__(self)
        if demo_type.lower() == "insite":
            self.dataIF = DataInterface.InsiteDataInterface()
        elif demo_type.lower() == "d3":
            self.dataIF = DataInterface.D3DataInterface()
        else:
            self.dataIF = DataInterface.DataInterface()
        self.dataIF.dataChanged.connect(self.testFun)
        self.dataIF.loadData()

        self.wvwm = WebViewWindowMediator(WebViewWindow.Ui_WebViewWindow(), None)
        if demo_type.lower() == "insite":
            self.wvwm.setTitle("InSite")
        elif demo_type.lower() == "d3":
            self.wvwm.setTitle("Delv - Dynamic Linked Visualizations")

        self.wvwm.resize(1600,1400)

        self.wvwm.connectSignal("elementSelected",self.elementSelected)
        self.wvwm.connectLoadFinished(self.loadFinished)
        self.wvwm.connectWindowCleared(self.onWindowCleared)
        self.connect(self,QtCore.SIGNAL("testEventForPython"),self.testFun)
        self.connect(self, QtCore.SIGNAL("sketchesLoaded"),self.onSketchesLoaded)

        if url:
            self.wvwm.load(url)

    def onWindowCleared(self):
        self.wvwm.exposeToJavaScript("QtWin", self)
#        self.wvwm.exposeToJavaScript()
        self.wvwm.exposeToJavaScript("dataIF",self.dataIF)

    def load(self, url):
        self.wvwm.load(url)

    def show(self):
        self.wvwm.show()

    @QtCore.pyqtSlot(str, str)
    def emitEvent(self, event, args):
        self.emit(QtCore.SIGNAL(event), args)

    def testFun(self, details):
        print "testFun received event with details:", details

    @QtCore.pyqtSlot(str)
    def onSketchesLoaded(self, invoker):
        print "MainWindow.onSketchesLoaded", invoker
        self.dataIF.triggerDataLoaded(invoker)

    def loadFinished(self, success):
        print "MainWindow.loadFinished"
        self.wvwm.evaluateJavaScript("delv.connectToQt();")
#        self.wvwm.resize(1600,1400)
        # can't load data until processing sketches have been loaded, so wait for onSketchesLoaded to be triggered instead
        
    def elementSelected(self, element, event):
        print "PyQt MainWindow received elementSelected"
        name = str(element.attribute("id"))
#         js = """
#   var svgNS = "http://www.w3.org/2000/svg";
  
#   var curElement = document.getElementById("%s");

#   var bb = curElement.getBBox();
#   var rect = document.createElementNS(svgNS, "rect");
#   rect.setAttribute("id", "bboxRect")
#   rect.setAttribute("x", bb.x);
#   rect.setAttribute("y", bb.y);
#   rect.setAttribute("width", bb.width);
#   rect.setAttribute("height", bb.height);
#   rect.setAttribute("stroke", "black");
#   rect.setAttribute("stroke-opacity", "1");

#   curElement.appendChild(rect);
# """ % (str(name))
#         result = self.wvwm.evaluateJavaScript(js)
        print "name: ", name

def runMain(svg, demo_type):

    try:
        app_type = sys.frozen
    except:
        app_type = "command-line"
    if app_type != "macosx_app":
        app = QtGui.QApplication(sys.argv)
    else:
        app = QtGui.QApplication([])
    QtWebKit.QWebSettings.globalSettings().setAttribute(QtWebKit.QWebSettings.DeveloperExtrasEnabled, True)
    if svg:
        win = MainWindow(QtCore.QUrl("file://%s" % svg), demo_type)
    else:
        #win = MainWindow(QtCore.QUrl("file:///Users/krismz/Software/SVGAnnotation/simple_link.svg"), demo_type)
        win = MainWindow(QtCore.QUrl("file:///Users/krismz/Software/SVGAnnotation/mtcars_link.svg"), demo_type)
        #win = MainWindow(QtCore.QUrl("file:///Users/krismz/Software/SVGAnnotation/usa_election.svg"), demo_type)

    win.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    filename = ""
    if len(sys.argv) > 1:
        filename = sys.argv[1]
        
    demo_type = "insite"
    if len(sys.argv) > 2:
        demo_type = sys.argv[2]

    runMain(filename, demo_type)
