# This is a widget that can wrap any Delv view into a Swing panel.
# Right now, this is implemented in Jython, but perhaps it would be better to be in Java eventually.

from processing.core import *

#class DelvApplet(PApplet):
class DelvApplet:
  def __init__(self, name, sketchApplet, mainViewName, delvIF=None, dataIF=None):
    print "in DelvApplet.__init__"
    print "About to construct sketchApplet"
    self.sketch = sketchApplet()
    #PApplet.__init__(self)
    #self.width = 100
    #self.height = 100
    self.name = name
    self.viewName = mainViewName
    self.dataIF = dataIF
    self.delvIF = delvIF
    self.view = None
    # self.init()
    # while self.defaultSize and not self.finished:
    #   pass
    # self.size(self.width, self.height)
    # print "About to construct sketchApplet"
    # self.name = name
    # self.sketch = sketchApplet()
    # self.viewName = mainViewName
    # # TODO provide some validity checking on viewConstructor
    # self.viewConstructor = getattr(self.sketch, self.viewName)
    # self.dataIF = dataIF
    # self.delvIF = delvIF

  def init(self):
    self.sketch.setup = self.setup
    self.sketch.resize = self.resize
    self.sketch.draw = self.draw
    self.sketch.redraw = self.redraw
    self.sketch.mouseDragged = self.mouseDragged
    self.sketch.mouseMoved = self.mouseMoved
    self.sketch.mouseClicked = self.mouseClicked
    self.sketch.mousePressed = self.mousePressed
    self.sketch.mouseReleased = self.mouseReleased
    self.sketch.init()

  def getApplet(self):
    return self.sketch
    
  def getView(self):
    return self.view
      
  def setup(self):
    # Do we really want to call sketch.init() if we're just using a component?
    #self.sketch.init()
    print "in DelvApplet.setup()"
    #self.size(self.w, self.h)
    #self.sketch = self.sketchApplet()

    #self.sketch.size(self.w, self.h, PConstants.JAVA2D)
    # TODO add a more general way to create fonts here
    #self.sketch.createFont("Verdana", 12, True)
    print "sketch verdana 12:", self.sketch._verdana_font_12
    print "About to construct view"
    # TODO provide some validity checking on viewConstructor
    self.viewConstructor = getattr(self.sketch, self.viewName)
   
    # TODO should we always assume dataIF is passed in, or should we allow
    # to construct it somehow like:
    if self.dataIF is None:
      self.dataIF = getattr(self.sketch, 'InSiteData')(self.sketch, 'InSite')
      self.dataIF.load_from_file('/Users/krismz/Software/delv/examples/test_data/config.txt')
    if self.delvIF is None:
      self.delvIF = getattr(self.sketch, 'DelvImpl')(self.sketch, self.dataIF)
    else:
      self.delvIF = delvIF

    #print "g =", self.g
      
    self.view = self.viewConstructor(self.sketch, self.name + '_' + self.viewName)
    self.view.bindDelv(self.delvIF)
    self.view.dataIF(self.dataIF.getName())
    self.view.setup()
    self.view.connectSignals()
    #self.view.reloadData(self.name)
    print "Leaving setup"

  def resize(self, width, height):
    # TODO figure out how to handle resize in context of Swing signals etc
    self.w = width
    self.h = height
    if self.view is not None:
      self.view.resize(self.w, self.h)
    else:
      print "resize called, but view not constructed yet"
    #PApplet.resize(self, width, height)

  def draw(self): 
    self.view.draw()
  def redraw(self):
    self.view.draw()
  def mouseDragged(self):
    self.view.mouseDragged()
    self.draw()
  def mouseMoved(self):
    self.view.mouseMoved()
    self.draw()
  def mouseClicked(self):
    self.view.mouseClicked()
    self.draw()
  def mousePressed(self):
    self.view.mousePressed()
    self.draw()
  def mouseReleased(self):
    self.view.mouseReleased()
    self.draw()
