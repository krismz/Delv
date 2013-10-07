# ======================================================================
# Copyright (c) 2013, Scientific Computing and Imaging Institute,
# University of Utah. All rights reserved.
# Author: Kris Zygmunt
# License: New BSD 3-Clause (see accompanying LICENSE file for details)
# ======================================================================
from PyQt4 import QtCore
import ColorMap as cm
import DataRange as dr
import Attribute
import DataSet as ds
import os

class DataInterfaceException(Exception):
    def __init__(self, msg):
        self.msg = "DataInterfaceException: " + msg

    def __str__(self):
        return str(self.msg)

# must be a QObject if being passed across the Qt Bridge to javascript
class DataInterface(QtCore.QObject):
  dataChanged = QtCore.pyqtSignal(str, str)
  dataLoaded = QtCore.pyqtSignal(str)

  selectedIdsChanged = QtCore.pyqtSignal(str, str, str, "QVariantList")
  highlightedIdChanged = QtCore.pyqtSignal(str, str, str, str)
  hoveredIdChanged = QtCore.pyqtSignal(str, str, str, str)

  highlightedCategoryChanged = QtCore.pyqtSignal(str, str, str, str)
  hoveredCategoryChanged = QtCore.pyqtSignal(str, str, str, str)
  categoryVisibilityChanged = QtCore.pyqtSignal(str, str, str, str)
  categoryColorsChanged = QtCore.pyqtSignal(str, str, str, str)

  def __init__(self, parent=None):
      QtCore.QObject.__init__(self, parent)
      self.data = {}
      self.delvIF = None

  def setDelvIF(self, delvIF):
      self.delvIF = delvIF
      self.connectToDelv()

  def connectToDelv(self):
      self.selectedIdsChanged.connect(self.delvIF, "handleSignal")
      self.highlightedIdChanged.connect(self.delvIF, "handleSignal")
      self.hoveredIdChanged.connect(self.delvIF, "handleSignal")

      self.highlightedCategoryChanged.connect(self.delvIF, "handleSignal")
      self.hoveredCategoryChanged.connect(self.delvIF, "handleSignal")
      self.categoryVisibilityChanged.connect(self.delvIF, "handleSignal")
      self.categoryColorsChanged.connect(self.delvIF, "handleSignal")

  def triggerDataLoaded(self, source):
      # trigger javascript datachanged event coming from source
      print "emitting dataLoaded signal for", source
      self.dataLoaded.emit(source)

  def loadData(self):
      pass

  @QtCore.pyqtSlot(str, str, "QVariantList")
  def updateSelectedIds(self, invoker, datasetname, identifiers):
      dataset = str(datasetname)
      ids = [ str(id) for id in identifiers ]
      self.data[dataset].updateSelectedIds(ids);
      self.selectedIdsChanged.emit('selectedIdsChanged', invoker, dataset, ids)

  @QtCore.pyqtSlot(str, str, str)
  def updateHighlightedId(self, invoker, datasetname, identifier):
      dataset = str(datasetname)
      id = str(identifier)
      self.data[dataset].updateHighlightedId(id);
      self.highlightedIdChanged.emit('highlightedIdChanged', invoker, dataset, id)

  @QtCore.pyqtSlot(str, str, str)
  def updateHoveredId(self, invoker, datasetname, identifier):
      dataset = str(datasetname)
      id = str(identifier)
      self.data[dataset].updateHoveredId(id);
      self.hoveredIdChanged.emit('hoveredIdChanged', invoker, dataset, id)

# TODO subtle here, decide how to track visibility changed this way correctly in DataSet.py
#   @QtCore.pyqtSlot(str, str, str)
#   def updateItemVisibility(self, invoker, datasetname, identifier):
#       dataset = str(datasetname)
#       id = str(identifier)
#       self.data[dataset].updateItemVisibility(id);
#       self.itemVisibilityChanged.emit('itemVisibilityChanged', invoker, dataset, id)

  @QtCore.pyqtSlot(str, str, str, str)
  def updateHighlightedCategory(self, invoker, datasetname, attribute, category):
      dataset = str(datasetname)
      attr = str(attribute)
      cat = str(category)
      self.data[dataset].attributes[attr].setHighlightedCategory(cat)
      self.highlightedCategoryChanged.emit('highlightedCategoryChanged', invoker, dataset, attr)

  @QtCore.pyqtSlot(str, str, str, str)
  def updateHoveredCategory(self, invoker, datasetname, attribute, category):
      dataset = str(datasetname)
      attr = str(attribute)
      cat = str(category)
      self.data[dataset].attributes[attr].setHoverCategory(cat)
      self.hoveredCategoryChanged.emit('hoveredCategoryChanged', invoker, dataset, attr)

  @QtCore.pyqtSlot(str, str, str, str)
  def updateCategoryVisibility(self, invoker, datasetname, attribute, category):
      dataset = str(datasetname)
      attr = str(attribute)
      cat = str(category)
      self.data[dataset].updateCategoryVisibility(attr, cat)
      self.categoryVisibilityChanged.emit('categoryVisibilityChanged', invoker, dataset, attr)

  @QtCore.pyqtSlot(str, str, str, str, "QVariantList")
  def updateCategoryColor(self, invoker, datasetname, attribute, category, color):
      dataset = str(datasetname)
      attr = str(attribute)
      cat = str(category)
      if color:
          col = tuple( [ int(str(c)) for c in color ] )
          self.data[dataset].attributes[attr].setCategoryColor(cat, col)
          self.categoryColorsChanged.emit('categoryColorsChanged', invoker, dataset, attr)

  @QtCore.pyqtSlot(str, str)
  def testMethod(self):
      print "in DataInterface.testMethod()"


  @QtCore.pyqtSlot(str, str, str, str)
  def setItem(self, datasetname, attribute, identifier, item):
      dataset = str(datasetname)
      attr = str(attribute)
      id = str(identifier)
      it = str(item)
      return self.data[dataset].setItem(attr, id, it)

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getAllItems(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      return self.data[dataset].getAllItems(attr)

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getAllItemsAsFloat(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      return self.data[dataset].getAllItemsAsFloat(attr)

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getAllIds(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      return self.data[dataset].getAllIds(attr)

  @QtCore.pyqtSlot(str, str, str, result="QVariant")
  def getItem(self, datasetname, attribute, identifier):
      dataset = str(datasetname)
      attr = str(attribute)
      id = str(identifier)
      return self.data[dataset].getItem(attr, id)

  @QtCore.pyqtSlot(str, str, str, result="QVariant")
  def getItemAsFloat(self, datasetname, attribute, identifier):
      dataset = str(datasetname)
      attr = str(attribute)
      id = str(identifier)
      return self.data[dataset].getItem(attr, id)

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getAllCategories(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      # return unique set of values from categorical data
      # throw exception if not categorical
      try:
          return self.data[dataset].getAllCategories(attr)
      except Exception as detail:
          print "getAllCategories received exception: %s" % detail
          return []

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getVisibleCategories(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      try:
          return self.data[dataset].attributes[attr].getVisibleCategories()
      except Exception as detail:
          print "getVisibleCategories received exception: %s" % detail
          return []

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getAllCategoryColors(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      # return unique set of values from categorical data
      # throw exception if not categorical
      try:
          return self.data[dataset].attributes[attr].getAllCategoryColors()
      except Exception as detail:
          print "getAllCategoryColors received exception: %s" % detail
          return []

  @QtCore.pyqtSlot(str, str, result="QVariantList")
  def getVisibleCategoryColors(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      try:
          return self.data[dataset].attributes[attr].getVisibleCategoryColors()
      except Exception as detail:
          print "getVisibleCategoryColors received exception: %s" % detail
          return []

  @QtCore.pyqtSlot(str, str, result="QVariant")
  def getHoveredCategory(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      try:
          return self.data[dataset].attributes[attr].getHoverCategory()
      except Exception as detail:
          print "getHoveredCategoryColors received exception: %s" % detail
          return []

  @QtCore.pyqtSlot(str, result="QVariantList")
  def getAttributes(self, datasetname):
      # return all attributes
      dataset = str(datasetname)
      return self.data[dataset].getAttributes()

  @QtCore.pyqtSlot(str, result="QVariant")
  def getHighlightedId(self, datasetname):
      dataset = str(datasetname)
      return self.data[dataset].getHighlightedId()

  @QtCore.pyqtSlot(str, result="QVariant")
  def getHoveredId(self, datasetname):
      dataset = str(datasetname)
      return self.data[dataset].getHoverId()

  @QtCore.pyqtSlot(str, str, result="QVariant")
  def getColorMap(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      return self.data[dataset].attributes[attr].colorMap

  @QtCore.pyqtSlot(str, str, result="QVariant")
  def getFullRange(self, datasetname, attribute):
      dataset = str(datasetname)
      attr = str(attribute)
      return self.data[dataset].attributes[attr].fullRange
  
class InsiteDataInterface(DataInterface):
  def __init__(self, parent=None):
      DataInterface.__init__(self, parent)

  def loadData(self):
      self.data = {}
      self.data['Regions'] = ds.DataSet('Regions')
      self.data['Annotations'] = ds.DataSet('Annotations')

      self.initTestAttributes()

      self.addTestEntry('Regions','0','dmel','mutant',1566,'binding_site', 871, 14, 'bcd', 9.60)
      self.addTestEntry('Regions','1','dmel','mutant',1566,'binding_site', 796, 14, 'bcd', 9.39)
      self.addTestEntry('Regions','2','dmel','mutant',1566,'binding_site',617,8,'cad',8.44)
      self.addTestEntry('Regions','3','dmel','mutant',1566,'binding_site',1262,8,'cad',8.28)
      self.addTestEntry('Regions','4','dmel','mutant',1566,'binding_site',542,10,'cad',8.91)
      self.addTestEntry('Regions','5','dmel','wild',1566,'binding_site',1025,7,'tll',8.93)
      self.addTestEntry('Regions','6','dmel','wild',1566,'binding_site',21,8,'hb',9.92)
      self.addTestEntry('Regions','7','dmel','wild',1566,'binding_site',413,8,'hb',9.95)
      self.addTestEntry('Regions','8','dmel','wild',1566,'binding_site',425,8,'hb',9.75)
      self.addTestEntry('Regions','9','dyak','mutant',1618,'binding_site',14,8,'hb',8.198758555)
      self.addTestEntry('Regions','10','dyak','mutant',1618,'binding_site',613,12,'hb',5.457488951)
      self.addTestEntry('Regions','11','dyak','mutant',1618,'binding_site',358,8,'hb',12.52835778)
      self.addTestEntry('Regions','12','dyak','mutant',1618,'binding_site',681,12,'hb',15.42387267)
      self.addTestEntry('Regions','13','dyak','mutant',1618,'binding_site',522,7,'hb',11.55148856)
      self.addTestEntry('Regions','14','dyak','mutant',1618,'binding_site',690,12,'hb',7.404148733)
      self.addTestEntry('Regions','15','dyak','wild',1618,'binding_site',22,8,'hb',9.92)
      self.addTestEntry('Regions','16','dyak','wild',1618,'binding_site',415,8,'hb',9.92)
      self.addTestEntry('Regions','17','dyak','wild',1618,'binding_site',427,8,'hb',9.75)
      self.addTestEntry('Regions','18','dyak','wild',1618,'binding_site',487,8,'hb',11.28)
      self.addTestEntry('Regions','19','dyak','wild',1618,'binding_site',530,8,'hb',10.81)
      self.addTestEntry('Regions','20','dyak','wild',1618,'binding_site',706,8,'hb',11.28)
      self.addTestEntry('Regions','21','dyak','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','22','a','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','23','b','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','24','c','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','25','d','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','26','e','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','27','f','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','28','g','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','29','h','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','30','i','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','31','j','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','32','k','wild',1618,'binding_site',1154,8,'hb',11.28)
      self.addTestEntry('Regions','33','l','wild',1618,'binding_site',1154,8,'hb',11.28)

      self.addTestEntry('Annotations','0','dmel','mutant',1566,'annotation',503,100,'example1')
      self.addTestEntry('Annotations','1','dmel','mutant',1566,'annotation',900,20,'example2')
      self.addTestEntry('Annotations','2','dmel','mutant',1566,'annotation',960,0,'example3')
      self.addTestEntry('Annotations','3','dmel','wild',1566,'annotation',503,100,'example1')
      self.addTestEntry('Annotations','4','dmel','wild',1566,'annotation',900,20,'example2')
      self.addTestEntry('Annotations','5','dmel','wild',1566,'annotation',960,0,'example3')
      self.addTestEntry('Annotations','6','dyak','mutant',1618,'annotation',700,55,'example4')
      self.addTestEntry('Annotations','7','dyak','mutant',1618,'annotation',1002,0,'example5')
      self.addTestEntry('Annotations','8','dyak','wild',1618,'annotation',700,55,'example4')
      self.addTestEntry('Annotations','9','dyak','wild',1618,'annotation',1002,0,'example5')

      # print 'testdata species: ', self.data['Regions'].attributes['Species']

  def initTestAttributes(self):
      self.addTestAttribute('Regions','Species',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Regions','Phenotype',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Regions','class',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Regions','start',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Regions','length',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Regions','motif_type',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Regions','strength',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Regions','totalLength',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Annotations','Species',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Annotations','Phenotype',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Annotations','class',Attribute.CATEGORICAL, cm.DiscreteColorMap(), dr.CategoricalDataRange())
      self.addTestAttribute('Annotations','start',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Annotations','length',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Annotations','description',Attribute.UNSTRUCTURED, cm.ColorMap(), dr.DataRange())
      self.addTestAttribute('Annotations','totalLength',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())

  def addTestAttribute(self, dataset, name, attr_type, color_map, data_range):
      # TODO figure out how to handle color style better
      color_map.setDefaultColor((210,210,210))

      self.data[dataset].addAttribute( Attribute.Attribute(name, attr_type, color_map, data_range) )
      

  def addTestEntry(self, dataset, id, species, pheno, totallength, cls, start, length, motif, strength=None):
      # TODO update item visibility, highlighted item, hover item, and item selection data structures
      if cls == 'binding_site':
          self.data[dataset].addId(id)
          self.data[dataset].setItem('Species', id, species)
          self.data[dataset].setItem('Phenotype', id, pheno)
          self.data[dataset].setItem('totalLength', id, totallength)
          self.data[dataset].setItem('class', id, cls)
          self.data[dataset].setItem('start', id, start)
          self.data[dataset].setItem('length', id, length)
          self.data[dataset].setItem('motif_type', id, motif)
          self.data[dataset].setItem('strength', id, strength)
      else:
          self.data[dataset].addId(id)
          self.data[dataset].setItem('Species', id, species)
          self.data[dataset].setItem('Phenotype', id, pheno)
          self.data[dataset].setItem('totalLength', id, totallength)
          self.data[dataset].setItem('class', id, cls)
          self.data[dataset].setItem('start', id, start)
          self.data[dataset].setItem('length', id, length)
          self.data[dataset].setItem('description', id, motif)
          # print "Appended length:", length, "to dataset results in:", self.data[dataset].attributes['length']
# end of InsiteDataInterface


class D3DataInterface(DataInterface):
  def __init__(self, parent=None):
      DataInterface.__init__(self, parent)

  def loadData(self):
      import json
      # TODO make this path more configurable
      fullpath = os.path.split(os.path.abspath(__file__))[0]                                                          
      parentdir = os.path.split(fullpath)[0]                                                                          
      data_path = os.path.join(parentdir, 'test_data')                                                                
      lines = open(os.path.join(data_path,'flare.json')).readlines()  
      decoded_json = json.loads(''.join(lines))
      self.convertToNodesAndLinks(decoded_json)
      #       print "loaded data: ", self.data
      # print 'node ids: ', self.data['Nodes'].itemIds
#       print 'node sizes: ', self.data['Nodes'].attributes['size']
#       print 'link ids: ', self.data['Links'].itemIds
#       print 'link starts: ', self.data['Links'].attributes['StartNode']
#       print 'link ends: ', self.data['Links'].attributes['EndNode']

  def convertToNodesAndLinks(self, hierarchical_data):
      self.data['Nodes'] = ds.DataSet('Nodes')
      self.data['Links'] = ds.DataSet('Links')
      self.initTestAttributes()

      self.linkId = 0
      self.nodeId = 0
      totalSize = self.convert_one_level(hierarchical_data, 0, None)

  def convert_one_level(self, hierarchy, level, parent=None):
      name = hierarchy['name']
      node_size = 0
      node_id = str(self.nodeId)
      self.nodeId += 1
      if hierarchy.has_key('children'):
          children = hierarchy['children']
          for child, num in zip(children, range(len(children))):
              node_size += self.convert_one_level(child, level+1, node_id)
      if hierarchy.has_key('size'):
          node_size += int(hierarchy['size'])
      self.addNode(node_id, name, node_size)
      if parent != None:
          self.addLink('%d_%d' % (level, self.linkId), parent, node_id)
          self.linkId += 1
      return node_size


  def addNode(self, id, name, size):
      self.data['Nodes'].addId(id)
      self.data['Nodes'].setItem('name', id, name)
      self.data['Nodes'].setItem('size', id, size)

  def addLink(self, id, startNode, endNode):
      self.data['Links'].addId(id)
      self.data['Links'].setItem('StartNode', id, startNode)
      self.data['Links'].setItem('EndNode', id, endNode)

  def initTestAttributes(self):
      self.addTestAttribute('Nodes','name',Attribute.UNSTRUCTURED, cm.ColorMap(), dr.DataRange())
      self.addTestAttribute('Nodes','size',Attribute.CONTINUOUS, cm.ContinuousColorMap(), dr.ContinuousDataRange())
      self.addTestAttribute('Links','StartNode',Attribute.UNSTRUCTURED, cm.ColorMap(), dr.DataRange())
      self.addTestAttribute('Links','EndNode',Attribute.UNSTRUCTURED, cm.ColorMap(), dr.DataRange())

  def addTestAttribute(self, dataset, name, attr_type, color_map, data_range):
      # TODO figure out how to handle color style better
      color_map.setDefaultColor((210,210,210))
      self.data[dataset].addAttribute( Attribute.Attribute(name, attr_type, color_map, data_range) )

