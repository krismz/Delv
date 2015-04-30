# High level interface to construct ggplots
# Specific calls are constructed from either c_ggplot or JRI_ggplot, etc
from DelvView import DelvView

class ggplot(DelvView):
  def __init__(self, svgElem):
    self.svgElem=svgElem
    self.width=20
    self.height=10

  def resize(self, width, height):
    self.width = width
    self.height = height

# TODO refactor as necessary
