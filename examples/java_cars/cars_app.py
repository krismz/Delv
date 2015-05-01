from org.eclipse.swt import *
from org.eclipse.swt.graphics import *
from org.eclipse.swt.layout import *
from org.eclipse.swt.widgets import *
from org.eclipse.swt.custom import StackLayout
from org.eclipse.swt.events import *

# TODO this import should be temporary
from org.eclipse.swt.browser import *

# Following is for swing integration
from org.eclipse.swt.awt import *

# and general java stuff
from java.lang import *

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
  gl.numColumns = 1
  shell.setLayout(gl)

  # WARNING!! The following Swing / AWT imports MUST happen AFTER
  # the SWT display has been created!
  
  # And swing components
  from javax.swing import JFrame, JPanel, JApplet, UIManager
  from java.awt import FlowLayout, Dimension

  # custom views etc
  from DelvProcessing import *
  import inSite
  
  # Following from http://www.eclipse.org/articles/Article-Swing-SWT-Integration/
  # To reduce flicker on resize:
  System.setProperty("sun.awt.noerasebackground", "false")
  # To get Swing look and feel to match SWT:
  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName())  

  browser = Browser(shell, SWT.RESIZE)
  browser.setText("hello world!")
  bgd = GridData()
  bgd.widthHint = 400
  bgd.heightHint = 500
  browser.setLayoutData(bgd)

  composite = Composite(shell, SWT.EMBEDDED | SWT.RESIZE)
  # TODO keep this resize listener?
  #composite.addControlListener(CleanResizeListener())
  cgd = GridData()
  cgd.widthHint = 300
  cgd.heightHint = 200
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
  data = dataFromP5Applet(applet, "InSiteData", "InSite")
  delv = delvFromP5Applet(applet, data)
  data.setDelvIF(delv) # TODO do this here or inside above method?
  # TODO who decides when to load the data?
  data.loadData()
    
  # Don't do this until after calling init above
  view = applet.getView()
  view.bindDelv(delv)
  view.dataIF(data.getName())
  view.datasetName("Regions")
  view.dataAttr("motif_type")
  view.setup()

  applet.reloadData("cars app")

  shell.pack()
  shell.open()
  while not shell.isDisposed():
    if not display.readAndDispatch():
      display.sleep()

  # do this if not using SWT
  #frame.pack()
  #frame.visible=1                  
  # TODO: address this hack?
  display.dispose()


