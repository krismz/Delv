# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
from PyQt4 import QtCore, QtWebKit

class SVGWebView(QtWebKit.QWebView):
    def __init__(self, parent=None, url=None):
        super(SVGWebView, self).__init__(parent)
        self.urlChanged.connect(self.updateSource)
        if url:
            #self.setUrl(url)
            self.load(url)
        
    def updateSource(self):
        print "In SVGWebView::updateSource()"
        self.webpage = self.page()
        self.frame = self.webpage.mainFrame()
        
class DemoSVGWebView(SVGWebView):
    """ This web view is tailored to work with the SVG from
http://www.petercollingridge.co.uk/data-visualisation/introduction-svg-scripting-interactive-map
"""
    def __init__(self, parent=None, url=None):
        super(DemoSVGWebView, self).__init__(parent, url)

    def mousePressEvent(self, event):
        print "Mouse press! ", event.pos()
        curElement = self.frame.hitTestContent(event.pos()).element()
        print "Mouse pointing to", curElement.attribute("id"), curElement.attribute("onmouseover"), curElement.attribute("class")
        curName = curElement.attribute("id")
        curClass = curElement.attribute("class")
        # following two evaluateJavaScript calls don't do anything
#         curElement.evaluateJavaScript("displayName(%s---%s)" % (curName,
#                                                                 curClass))
#         curElement.evaluateJavaScript("colourCountry(%s,%s)" % (curName,
#                                                                 5))
        curElement.setAttributeNS('','class',curClass + ' colour5')
        event.accept()

class SnapSVGWebView(SVGWebView):
    def __init__(self, parent=None, url=None):
        super(SnapSVGWebView, self).__init__(parent, url)
        # TODO figure out how to pass args with signal
#        self.elementSelected = QtCore.pyqtSignal()

# don't provide this function if you want any mouse actions to propagate to the javascript layer
# as for some reason QWebView will never propagate even if event.ignore() or !event.isAccepted()
#     def mousePressEvent(self, event):
#         print "Mouse press! ", event.pos()
#         htc = self.frame.hitTestContent(event.pos())
#         self.curElement = htc.element()
#         event.bbox = htc.boundingRect()
# #        curElement = self.frame.hitTestContent(event.pos()).enclosingBlockElement()
#         print "Mouse pointing to curElement: ", self.curElement.attribute("id")
#         for name in self.curElement.attributeNames():
#             print name, " = ", self.curElement.attribute(name)

# #        curName = curElement.attribute("id")
#         curClass = self.curElement.attribute("class")
#         # following two evaluateJavaScript calls don't do anything
# #         curElement.evaluateJavaScript("displayName(%s---%s)" % (curName,
# #                                                                 curClass))
# #         curElement.evaluateJavaScript("colourCountry(%s,%s)" % (curName,
# #                                                                 5))
# #        curElement.setAttributeNS('','class',curClass + ' colour5')
#         self.curElement.setAttribute('fill','rgb(128,0,255)')
# #        self.curElement.setAttributeNS('','class',curClass+' hilite')
# #        self.emit(QtCore.SIGNAL("elementSelected"), self.curElement, event)
#         self.emit(QtCore.SIGNAL("elementSelected"), self.curElement, None)
# #        event.accept()
#         event.ignore()

    def addToJavaScript(self, name, obj):
        return self.page().mainFrame().addToJavaScriptWindowObject(name, obj)

    def evaluateJavaScript(self, js):
        print "js: ", js
        return self.frame.evaluateJavaScript(js)

    def getWidth(self):
        return self.frame.documentElement().attribute("width")

    def getHeight(self):
        return self.frame.documentElement().attribute("height")
