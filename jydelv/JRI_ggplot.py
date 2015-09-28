# Use JRI interface to communicate w/ ggplot
# works from jython
#from ggplot import ggplot
import tempfile
import time

#class JRI_ggplot(ggplot):
# TODO make sure all classes new-style
class JRI_ggplot:
  def __init__(self, svgElem, Rengine):
    # TODO svgElem or file names?  For now files
    #ggplot.__init__(self, svgElem)
    # Rengine created by something like Rengine(["--vanilla"],False,None)
    self.Rengine = Rengine
    # TODO how to handle R library loads like this?
    self.Rengine.eval('library(ggplot2)')
    self.Rengine.eval('library(gridSVG)')
    # TODO how to handle clean up of this temp file?
    self.file = tempfile.NamedTemporaryFile(suffix=".svg",delete=False)
    self.file.close()

  def setup(self):
    pass

  def qplot(self, x, y, data=None, qplot_args=None):
    # TODO really need to be able to pull the data from Delv instead.
    # TODO also need to write the plot to SVG and annotate it appropriately
    dataStr = ""
    if data is not None:
      dataStr = ", data=%s" % (data)
    argsStr = ""
    if qplot_args is not None:
      argsStr = ", %s" % (qplot_args)

    # TODO need some other way to keep the plot from popping up in a device.  CairoSVG?
    self.Rengine.eval("svg()")  
    result = self.Rengine.eval("print(qplot(%s, %s%s%s))" % (x, y, dataStr, argsStr))

    self.Rengine.eval('grid.export("%s")' % self.file.name)
    print "plotting to file:", self.file.name
    
    # TODO necessary?  Suspect that there is delay for writing out the R SVG
    time.sleep(5)
    
    return self.file.name
