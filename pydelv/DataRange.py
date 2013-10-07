# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
class DataRange:
    def __init__(self):
        pass

class CategoricalDataRange(DataRange):
    def __init__(self):
        self.categories = []
        self.visible = {}

    def addCategory(self, category):
        if category not in self.categories:
            self.categories.append(category)
            self.visible[category] = True

    def setCategories(self, categories):
        self.categories = list(set(categories))
        for category in self.categories:
            self.visible[category] = True

    def getCategories(self):
        return self.categories

    def getVisibleCategories(self):
        return [ c for c in self.visible if self.visible[c] ]

    def getInvisibleCategories(self):
        return [ c for c in self.visible if not self.visible[c] ]

    def toggleVisibility(self, category):
        self.visible[category] = not self.visible[category]

    def isCategoryVisible(self,category):
        return self.visible[category]

class ContinuousDataRange(DataRange):
    def __init__(self):
        self.min = None
        self.max = None

    def getMin(self):
        return self.min

    def getMax(self):
        return self.max

    def setMin(self, value):
        self.min = value
    
    def setMax(self, value):
        self.max = value

    def updateMin(self, value):
        if self.min == None or value < self.min:
            self.min = value
    
    def updateMax(self, value):
        if self.max == None or value > self.max:
            self.max = value

    def update(self, value):
        self.updateMin(value)
        self.updateMax(value)

    def isInRange(self, value):
        if self.min == None:
            if self.max == None:
                return True
            else:
                return value <= self.max
        elif self.max == None:
            return self.min <= value
        else:
            return (self.min <= value) and (value <= self.max)
    
