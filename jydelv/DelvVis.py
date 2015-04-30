# jython
# provide a jython DelvVis implementation
# allows JFrames and Browsers to be mixed and matched

class DelvVis(object):
  # TODO put the annoying IF on the end of data to get dataIF?
  def __init__(self, data, delvConstructor):
    self.data = data
    self.delv = delvConstructor(self.data)
    self.views = {}
    self.frames = {}
    self.browsers = {}
    
