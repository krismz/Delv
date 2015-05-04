# jython
#
# some functions to pull Delv, Views, and Data from jars exported from Processing
#
from processing.core import PApplet, PConstants
from processing.event import MouseEvent as p5MouseEvent
from java.awt.event import MouseEvent as javaMouseEvent

class DelvP5AppletView(object):
    def __init__(self, viewConstructorName, viewName):
      self.viewConstructorName = viewConstructorName
      self.viewName = viewName
      self.view = None
      self.resizeView = False

    def getView(self):
      if self.view is None:
        viewConstructor = getattr(self, self.viewConstructorName)
        self.view = viewConstructor(self, self.viewName)
        #self.view._p = self
           
      return self.view

    def allow_view_resize(self):
      self.resizeView = True
      
    def setup(self):
      self.size(100,200,self.OPENGL)

    def resize(self, width, height):
      PApplet.resize(self,width,height)
      # TODO figure out how to handle resize in context of Swing signals etc
      self.w = width
      self.h = height
      if self.view is not None:
        self.view.resize(self.w, self.h, False)

    def draw(self):
      self.view.draw()
    def redraw(self):
      self.view.draw()
    def mouseMoved(self,evt):
      if type(evt) is javaMouseEvent:
        PApplet.mouseMoved(self, evt)
      elif type(evt) is p5MouseEvent:
        self.view.mouseMoved()
        self.draw()
    def mouseClicked(self,evt):
      if type(evt) is javaMouseEvent:
        PApplet.mouseClicked(self, evt)
      elif type(evt) is p5MouseEvent:
        self.view.mouseClicked()
        self.draw()
    def mousePressed(self,evt):
      if type(evt) is javaMouseEvent:
        PApplet.mousePressed(self, evt)
      elif type(evt) is p5MouseEvent:
        self.view.mousePressed()
        self.draw()
    def mouseReleased(self,evt):
      if type(evt) is javaMouseEvent:
        PApplet.mouseReleased(self, evt)
      elif type(evt) is p5MouseEvent:
        self.view.mouseReleased()
        self.draw()
    def mouseDragged(self,evt):
      if type(evt) is javaMouseEvent:
        PApplet.mouseDragged(self, evt)
      elif type(evt) is p5MouseEvent:
        self.view.mouseDragged()
        self.draw()

    def reloadData(self, source):
      self.view.reloadData(source)

    def color_(self, red, green=None, blue=None, alpha=None):
      """Need to override color implementation for Java/Jython
versions of Delv due to issues with color vs int in P5 and Java"""
      if blue is None:
        if green is None:
          # one arg version: color(grey)
          alpha = 255
        else:
          # two arg version: color(grey, alpha)
          alpha = green
        green = red
        blue = red
      if alpha is None:
        alpha = 255
      return self.colorJ_(red, green, blue, alpha)

    def alpha_(self, clr):
      return self.alphaJ_(clr)
    def red_(self, clr):
      return self.redJ_(clr)
    def green_(self, clr):
      return self.greenJ_(clr)
    def blue_(self, clr):
      return self.blueJ_(clr)
      
class DelvMetaApplet(type):
    def __new__(cls, name, bases, dct):
        dct['setup'] = DelvP5AppletView.setup
        dct['draw'] = DelvP5AppletView.draw
        dct['redraw'] = DelvP5AppletView.redraw
        dct['resize'] = DelvP5AppletView.resize
        dct['mouseDragged']=DelvP5AppletView.mouseDragged
        dct['mouseMoved']=DelvP5AppletView.mouseMoved
        dct['mouseClicked']=DelvP5AppletView.mouseClicked
        dct['mousePressed']=DelvP5AppletView.mousePressed
        dct['mouseReleased']=DelvP5AppletView.mouseReleased
        dct['mouseDragged']=DelvP5AppletView.mouseDragged
        dct['reloadData']=DelvP5AppletView.reloadData
        dct['color_']=DelvP5AppletView.color_
        dct['alpha_']=DelvP5AppletView.alpha_
        dct['red_']=DelvP5AppletView.red_
        dct['green_']=DelvP5AppletView.green_
        dct['blue_']=DelvP5AppletView.blue_
        return type.__new__(cls, name, bases, dct)
    
    def __init__(cls, name, bases, dct):
        super(DelvMetaApplet, cls).__init__(name, bases, dct)


def delvAppletFromP5Applet(appletConstructor, viewConstructorName, viewName=None):
  """Create a delv applet from a Processing applet constructor"""
  if viewName is None:
    viewName = viewConstructorName
    
  appClass = DelvMetaApplet(viewName + "AppletClass", (DelvP5AppletView, appletConstructor,), {})
  applet = appClass(viewConstructorName, viewName)
  return applet

def dataFromP5Applet(applet, dataClassName, dataName):
  dataConstructor = getattr(applet, dataClassName)
  data = dataConstructor(applet, dataName)
  return data 

def delvFromP5Applet(applet, data):
  delvConstructor = getattr(applet, "DelvImpl")
  delv = delvConstructor(applet, data)
  return delv
