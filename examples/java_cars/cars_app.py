from org.eclipse.swt import SWT
#from org.eclipse.swt.graphics import *
from org.eclipse.swt.layout import GridLayout, GridData
from org.eclipse.swt.widgets import Display, Shell, Composite
from org.eclipse.swt.custom import StackLayout
from org.eclipse.swt.events import ControlAdapter

# TODO this import should be temporary
from org.eclipse.swt.browser import Browser

# Following is for swing integration
from org.eclipse.swt.awt import SWT_AWT

# and general java stuff
from java.lang import System

# clear background on resize
class CleanResizeListener(ControlAdapter):
  def __init__(self):
    self.oldRect = None

  def controlResized(self,e):
    # Prevent garbage from Swing lags during resize. Fill exposed areas 
    # with background color. 
    composite = e.widget
    newRect = composite.getClientArea()
    if self.oldRect is not None:
      heightDelta = newRect.height - self.oldRect.height
      widthDelta = newRect.width - self.oldRect.width;
      if heightDelta > 0 or widthDelta > 0:
        gc = GC(composite);
      try:
        gc.fillRectangle(newRect.x, self.oldRect.height, newRect.width, heightDelta)
        gc.fillRectangle(self.oldRect.width, newRect.y, widthDelta, newRect.height)
      except:
        gc.dispose()
      self.oldRect = newRect


if __name__ == "__main__":
  
  # # TODO better to have swing or swt on the main thread?
  display = Display()
  shell = Shell(display)
  # StackLayout, only one is active at a time, Fill vs Grid vs other?
  gl = GridLayout()
  gl.numColumns = 3
  shell.setLayout(gl)

  # WARNING!! The following Swing / AWT imports MUST happen AFTER
  # the SWT display has been created!
  
  # And swing components
  from javax.swing import JFrame, JPanel, JApplet, UIManager
  from java.awt import FlowLayout, Dimension

  # custom views etc
  from DelvProcessing import *
  import inSite
  import org.rosuda.JRI.Rengine as Rengine
  from JRI_ggplot import JRI_ggplot
  
  # Following from http://www.eclipse.org/articles/Article-Swing-SWT-Integration/
  # To reduce flicker on resize:
  System.setProperty("sun.awt.noerasebackground", "false")
  # To get Swing look and feel to match SWT:
  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName())  

  browser = Browser(shell, SWT.RESIZE)
  #browser.setText("hello world!")
  # TODO get the url to lineup a better way
  browser.setUrl('file:///Users/krismz/Software/delv/examples/java_cars/lineup.js/demo/index.html')
  bgd = GridData(SWT.FILL, SWT.FILL, True, True)
  #bgd.widthHint = 1500
  ##bgd.heightHint = 1200
  ##bgd.widthHint = 1200
  #bgd.heightHint = 800
  bgd.horizontalSpan = 3
  browser.setLayoutData(bgd)

  browser2 = Browser(shell, SWT.RESIZE)
  browser2.setUrl('file:///Users/krismz/Software/delv/examples/java_cars/parallel_coords.html')
  pgd = GridData(SWT.FILL, SWT.FILL, True, False)
  #pgd.widthHint = 804
  #pgd.heightHint = 504
  browser2.setLayoutData(pgd)

  browser3 = Browser(shell, SWT.RESIZE)
  jggplot = JRI_ggplot(None, Rengine(["--vanilla"], False, None))
  jggplot.Rengine.eval('mtcars$cyl <- factor(mtcars$cyl,levels=c(4,6,8),labels=c("4cyl","6cyl","8cyl"))')
  #browser3.setUrl(jggplot.qplot("cyl","mpg","mtcars")
  browser3.setUrl(jggplot.qplot("wt","mpg","mtcars", 'geom=c("point", "smooth"), method="lm", formula=y~x, color=cyl, main="Regression of MPG on Weight", xlab="Weight", ylab="Miles per Gallon"'))

  #jgd = GridData(SWT.FILL, SWT.FILL, True, True)
  jgd = GridData()
  jgd.widthHint = 404 #504
  jgd.heightHint = 404 #504
  browser3.setLayoutData(jgd)

  
  composite = Composite(shell, SWT.EMBEDDED | SWT.RESIZE)
  # TODO keep this resize listener?
  #composite.addControlListener(CleanResizeListener())
  #cgd = GridData(SWT.FILL, SWT.FILL, True, True)
  cgd = GridData()
  cgd.widthHint = 100
  #cgd.heightHint = 200
  cgd.heightHint = 404 #504
  composite.setLayoutData(cgd)
  frame = SWT_AWT.new_Frame(composite)
  # Do this instead if running without SWT
  #frame=JFrame(title="Cars", resizable=1,defaultCloseOperation=JFrame.EXIT_ON_CLOSE)
  #frame.setSize(200,300)
  panel = JPanel()
  panel.setPreferredSize(Dimension(250,190))
  applet = delvAppletFromP5Applet(inSite, "ColorLegendWithDropdownView", "CarsLegend")

  panel.add(applet)
  layout = FlowLayout()
  frame.setLayout(layout)
  frame.add(panel)

  applet.init()
  while applet.defaultSize and not applet.finished:
    pass

  # TODO move some of following and some of above into DelvVis
  #data = dataFromP5Applet(applet, "InSiteData", "InSite")
  data = dataFromP5Applet(applet, "DelvCSVData", "P5Data")
  delv = delvFromP5Applet(applet, data)
  data.setDelvIF(delv) # TODO do this here or inside above method?
  # TODO who decides when to load the data?
  data.newDataSetFromFile("test_data/cars.csv", "Cars")
  data.loadData()
    
  # Don't do this until after calling init above
  view = applet.getView()
  view.bindDelv(delv)
  view.dataIF(data.getName())
  #view.datasetName("Regions")
  #view.dataAttr("motif_type")
  #view.label("TF")
  view.datasetName("Cars")
  view.dataAttr("cylinders")
  view.label("Cyl")
  view.setup()

  applet.reloadData("cars app")

  #shell.setSize(1500,800)
  shell.pack()
  shell.open()
  while not shell.isDisposed():
    if not display.readAndDispatch():
      #print "display.sleep"
      display.sleep()
    #else:
      #print "display.readAndDispatch"
  # do this if not using SWT
  #frame.pack()
  #frame.visible=1                  
  # TODO: address this hack?
  display.dispose()


