# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
import Attribute
import ItemId

class DataSetException(Exception):
    def __init__(self, msg):
        self.msg = "DataSetException: " + msg

    def __str__(self):
        return str(self.msg)

class DataSet():
    def __init__(self, name):
        self.name = name
        self.itemIds = []
        self.attributes = {}
        self.highlightedId = ""
        self.hoverId = ""

    def addId(self, id):
        newId = ItemId.ItemId(id)
        self.itemIds.append(newId)

    def getSelectedIds(self):
        return [ id.name for id in self.itemIds if id.selected ]

    def getVisibleIds(self):
        return [ id.name for id in self.itemIds if id.visible ]

    def getHighlightedId(self):
        return self.highlightedId

    def getHoverId(self):
        return self.hoverId

    def setItem(self, attrName, id, item):
        self.attributes[attrName].setItem(id, item)

    def addAttribute(self, attr):
        self.attributes[attr.name] = attr

    def getAttributes(self):
        return self.attributes.keys()

    def getAllCategories(self, attr):
        # return unique set of values from categorical data
      # throw exception if not categorical
      # TODO make type check safer by using a variable for initializing instead of a user-generated string
      try:
          if self.attributes[attr].type == Attribute.CATEGORICAL:
              return self.attributes[attr].getAllCategories()
          else:
              raise DataSetException("getAllCategories only works for Categorical data. Received request for attribute: %s from dataset: %s which is %s data." % (attr, dataset, self.attributes[attr].type))
      except Exception as detail:
          print "getAllCategories received exception: %s" % detail
          return []

    def getAllItems(self, attr):
        # TODO decide how to handle missing values, right now they are returned as None
        items = []
        for id in self.itemIds:
            if self.attributes[attr].items.has_key(id.name):
                items.append(self.attributes[attr].items[id.name])
            else:
                items.append(None)
        return items

    def getAllItemsAsFloat(self, attr):
        # TODO decide how to handle missing values, right now they are returned as None
        items = []
        for id in self.itemIds:
            if self.attributes[attr].items.has_key(id.name):
                items.append(float(self.attributes[attr].items[id.name]))
            else:
                items.append(None)
        return items

    def getAllIds(self, attr):
        # TODO depending on how missing values are handled, returned ids may need to be adjusted
        return [ id.name for id in self.itemIds ]

    def getAllItemsAndIds(self, attr):
        return self.attributes[attr].getAllIdsAndItems()

    def getItem(self, attr, id):
        # TODO decide how to handle missing values, right now they are returned as None
        if self.attributes[attr].items.has_key(id):
            return self.attributes[attr].items[id]
        else:
            return None

    def getItemAsFloat(self, attr, id):
        # TODO decide how to handle missing values, right now they are returned as None
        if self.attributes[attr].items.has_key(id):
            return float(self.attributes[attr].items[id])
        else:
            return None

    def updateCategoryVisibility(self, attribute, category):
        self.attributes[attribute].toggleVisibility(category)
        self.determineItemVisibility()

    def determineItemVisibility(self):
        for id in self.itemIds:
            id.visible = True
            for attr in self.attributes.keys():
                if not self.attributes[attr].isItemVisible(id.name):
                    id.visible = False
                    break
            
    def updateSelectedIds(self, ids):
        for id in self.itemIds:
            id.selected = False
            if id.name in ids:
                id.selected = True

    def updateHighlightedId(self, id):
        self.highlightedId = id

    def updateHoveredId(self, id):
        self.hoveredId = id
