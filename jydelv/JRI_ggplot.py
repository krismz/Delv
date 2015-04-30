# Use JRI interface to communicate w/ ggplot
# works from jython
from ggplot import ggplot

class JRI_ggplot(ggplot):
  def __init__(self, svgElem, Rengine):
    ggplot.__init__(self, svgElem)
    self.Rengine = Rengine

  def setup():
    pass

  def 
