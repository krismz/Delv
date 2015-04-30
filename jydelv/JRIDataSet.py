# ======================================================================
# Copyright (c) 2015, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================

# R attributes accessed via JRI

import Attribute

class JRIAttribute(Attribute):
  def __init__(self, r_engine, name, attr_type, color_map, data_range):
    Attribute.__init__(self, name, attr_type, color_map, data_range)
    self.engine = r_engine
  def __str__(self):
    return "%s (%s)" % (self.name, self.type)

  def setDataFrame(self, frame, column):
    self.frame = frame
    self.column = column

  def setItem(self, id, item):
    engine.assign(
