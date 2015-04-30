from org.eclipse.swt import *
from org.eclipse.swt.graphics import *
from org.eclipse.swt.layout import *
from org.eclipse.swt.widgets import *
from org.eclipse.swt.custom import StackLayout

# TODO this import should be temporary
from org.eclipse.swt.browser import *

# Following is for swing integration
from org.eclipse.swt.awt import *

# And swing components
from javax.swing import JFrame, JPanel, JApplet, UIManager
from java.awt import FlowLayout

# and general java stuff
from java.lang import *

# custom views etc
from DelvProcessing import *
import inSite

if __name__ == "__main__":
  # Following from http://www.eclipse.org/articles/Article-Swing-SWT-Integration/
  # To reduce flicker on resize:
  System.setProperty("sun.awt.noerasebackground", "true")
  # To get Swing look and feel to match SWT:
  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName())  
  
  # # TODO better to have swing or swt on the main thread?
  # display = Display()
  # shell = Shell(display)
  # # StackLayout, only one is active at a time, Fill vs Grid vs other?
  # shell.setLayout(GridLayout())

  # browser = Browser(shell, SWT.NONE)
  # browser.setText("hello world!")
  # browser.setSize(400,500)

  #composite = Composite(shell, SWT.EMBEDDED | SWT.NO_BACKGROUND)
  #frame = SWT_AWT.new_Frame(composite)
  #frame=JFrame(title="Cars", resizable=0,defaultCloseOperation=JFrame.EXIT_ON_CLOSE)
  frame=JFrame(title="Cars", resizable=1,defaultCloseOperation=JFrame.EXIT_ON_CLOSE)
  #frame.setSize(200,300)
  panel = JPanel()
  applet = delvAppletFromP5Applet(inSite, "ColorLegendWithDropdownView", "CarsLegend")
  #applet = delvAppletFromP5Applet(inSite, "ColorPickerLegendView", "CarsLegend")
  #applet = JApplet()
  #dapp = DelvApplet("CarsLegend", inSite, "ColorLegendWithDropdownView")
  #applet = dapp.getApplet()

  print "adding applet to panel"
  panel.add(applet)
  layout = FlowLayout()
  frame.setLayout(layout)
  frame.add(panel)

  print "about to init applet"
  applet.init()
  print "waiting for applet to finish"
  while applet.defaultSize and not applet.finished:
    pass
  print "applet finished"
  #dapp.setup()

  # TODO move some of following and some of above into DelvVis
  #data = dataFromP5Applet(inSite, "InSiteData", "InSite")
  #delv = delvFromP5Applet(inSite, data)
  data = dataFromP5Applet(applet, "InSiteData", "InSite")
  delv = delvFromP5Applet(applet, data)
  data.setDelvIF(delv) # TODO do this here or inside above method?
  # TODO who decides when to load the data?
  data.loadData()
    
  # Don't do this until after calling init above
  view = applet.getView()
  print type(view).__mro__
  view.bindDelv(delv)
  view.dataIF(data.getName())
  view.datasetName("Regions")
  view.dataAttr("motif_type")
  view.setup()
  #view.resize(applet.w,applet.h)

  print applet.g
  applet.reloadData("cars app")

  # shell.pack()
  # shell.open()
  # while not shell.isDisposed():
  #   if not display.readAndDispatch():
  #     display.sleep

  # display.dispose()

  frame.pack()
  frame.visible=1                  
  print "Should display now"
  # TODO: address this hack?
  applet.allow_view_resize()

