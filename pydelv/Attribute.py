# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
import ColorMap as cm
import DataRange as dr

UNSTRUCTURED = "UNSTRUCTURED"
CATEGORICAL = "CATEGORICAL"
CONTINUOUS = "CONTINUOUS"
Types = [ UNSTRUCTURED, CATEGORICAL, CONTINUOUS ]

class AttributeException(Exception):
    def __init__(self, msg):
        self.msg = "AttributeException: " + msg
    
    def __str__(self):
        return self.msg

# keep type property instead of subclassing because we may want to dynamically switch
# between categorical and continuous data
class Attribute():
    def __init__(self, name, attr_type, color_map, data_range):
        self.name = name
        self.items = {}
        if attr_type not in Types:
            raise AttributeException("Attempting to create attribute %s of type %s which is unrecognized.  Valid attribute types are %s" % (name,
                                                                                                                                           attr_type,
                                                                                                                                           Types))
        else:
            self.type = attr_type
        self.colorMap = color_map
        self.fullRange = data_range
        self.visibleRange = data_range
        self.highlightedCategory = None
        self.hoverCategory = None

    def __str__(self):
        return "%s (%s):\n%s" % (self.name, self.type, self.items)

    def setItem(self, id, item):
        self.items[id] = item
        if self.type == CATEGORICAL:
            self.fullRange.addCategory(item)
            self.visibleRange.addCategory(item)
        elif self.type == CONTINUOUS:
            self.fullRange.update(item)
        else:
            pass

    def getAllIdsAndItems(self):
        return self.items

    def getItemByID(self, id):
        return self.items[id]

    def setHighlightedCategory(self, category):
        self.highlightedCategory = category

    def setHoverCategory(self, category):
        self.hoverCategory = category
    
    def getHighlightedCategory(self):
        return self.highlightedCategory

    def getHoverCategory(self):
        return self.hoverCategory

    def toggleVisibility(self, category):
        if self.type == CATEGORICAL:
            self.visibleRange.toggleVisibility(category)
        else:
            raise AttributeException("Attempting to toggle visibility for attribute %s, type %s, but visibility can only be toggled for CATEGORICAL attributes." % (name,
                                                                                                                                                                    self.type))

    def getAllCategories(self):
        if self.type == CATEGORICAL:
            return self.fullRange.getCategories()
        else:
            raise AttributeException("Attempting to get all categories for attribute %s, type %s, but categories are only meaningful for CATEGORICAL attributes." % (name,
                                                                                                                                                                     self.type))

    def getVisibleCategories(self):
        if self.type == CATEGORICAL:
            return self.visibleRange.getVisibleCategories()
        else:
            raise AttributeException("Attempting to get visible categories for attribute %s, type %s, but category visibility is only meaningful for CATEGORICAL attributes." % (name,
                                                                                                                                                                                 self.type))
    def getAllCategoryColors(self):
        if self.type == CATEGORICAL:
            cats = self.getAllCategories()
            colors = []
            for cat in cats:
                colors.append( [ str(c) for c in self.colorMap.getColor(cat) ] )
            return colors
        else:
            raise AttributeException("Attempting to get colors for all categories for attribute %s, type %s, but categories are only meaningful for CATEGORICAL attributes." % (name,
                                                                                                                                                                     self.type))


    def getVisibleCategoryColors(self):
        if self.type == CATEGORICAL:
            cats = self.getVisibleCategories()
            colors = []
            for cat in cats:
                colors.append( [ str(c) for c in self.colorMap.getColor(cat) ] )
            return colors
        else:
            raise AttributeException("Attempting to get colors for visible categories for attribute %s, type %s, but categories are only meaningful for CATEGORICAL attributes." % (name,
                                                                                                                                                                     self.type))

    def setCategoryColor(self, category, color):
        if self.type == CATEGORICAL:
            self.colorMap.setColor(category, color)
        else:
            raise AttributeException("Attempting to set a category color for attribute %s, type %s, but categories are only meaningful for CATEGORICAL attributes." % (name,
                                                                                                                                                                     self.type))
        

    def updateVisibility(self, item):
        if self.type == CONTINUOUS:
            self.visibleRange.update(item)
        else:
            raise AttributeException("Attempting to update visibility for attribute %s, type %s, but visibility can only be updated for CONTINUOUS attributes." % (name,
                                                                                                                                                                   self.type))

    def getVisibleRange(self):
        if self.type == CONTINUOUS:
            return self.visibleRange
        else:
            raise AttributeException("Attempting to get visible range for attribute %s, type %s, but range visibility is only meaningful for CONTINUOUS attributes." % (name,
                                                                                                                                                                        self.type))
    def setVisibleRange(self, vrange):
        if self.type == CONTINUOUS:
            self.visibleRange = vrange
        else:
            raise AttributeException("Attempting to set visible range for attribute %s, type %s, but range visibility is only meaningful for CONTINUOUS attributes." % (name,
                                                                                                                                                                        self.type))

    def isItemVisible(self, id):
        if self.type == CATEGORICAL:
            return self.visibleRange.isCategoryVisible(self.items[id])
        elif self.type == CONTINUOUS:
            return self.visibleRange.isInRange(self.items[id])
        else:
            # TODO fix this, UNSTRUCTURED data is always visible for now
            return True
        
