# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
class ItemId():
    def __init__(self, id):
        self.name = id
        self.visible = True
        self.selected = False

    def __str__(self):
        msg = "Item %s is " % self.name
        if not self.visible:
            msg += "not "
        msg += "visible and is "
        if not self.selected:
            msg += "not "
        msg += "selected."
        return msg

    def toggleVisibility(self):
        self.visible = not self.visible

    def toggleSelection(self):
        self.selected = not self.selected
