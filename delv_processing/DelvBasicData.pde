// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================
import java.util.TreeMap;

class DelvItemId {
  // want these all to be public
  String name;
  boolean visible;
  boolean selected;

  DelvItemId(String id) {
    name = id;
    visible = true;
    selected = false;
  }

  void toggleVisibility() {
    visible = !visible;
  }

  void toggleSelection() {
    selected = !selected;
  }

} // end class DelvItemId

interface DelvRange {}

class DelvCategoricalRange implements DelvRange {
  ArrayList<String> _categories;
  HashMap<String, Boolean> _visible;

  DelvCategoricalRange() {
    // keeping this separate because _categories needs to be in the correct sorted order
    // (or does it, not sure this is true).
    // ( TODO maybe a sorted hash map would be better?)
    _categories = new ArrayList<String>();
    _visible = new HashMap<String, Boolean>();
  }

  void addCategory(String cat) {
    boolean found = false;
    for (String c : _categories) {
      if (c.equals(cat)) {
        found = true;
        break;
      }
    }
    if (!found) {
      _categories.add(cat);
    }
    _visible.put(cat, true);
  }

  // void setCategories(String[] cats) { }
  String[] getCategories() {
    return _categories.toArray(new String[_categories.size()]);
  }

  String[] getVisibleCategories() {
    ArrayList<String> vis = new ArrayList<String>();
    for (String cat : _categories) {
      if (_visible.get(cat)) {
        vis.add(cat);
      }
    }
    return vis.toArray(new String[vis.size()]);
  }

  String[] getInvisibleCategories() {
    ArrayList<String> vis = new ArrayList<String>();
    for (String cat : _categories) {
      if (!_visible.get(cat)) {
        vis.add(cat);
      }
    }
    return vis.toArray(new String[vis.size()]);
  }

  void toggleVisibility(String cat) {
    _visible.put(cat, !_visible.get(cat));
  }

  boolean isCategoryVisible(String cat) {
    return _visible.get(cat);
  }

} // end class DelvCategoricalRange

class DelvContinuousRange implements DelvRange {
  float _min;
  float _max;
  boolean _hasMin;
  boolean _hasMax;

  DelvContinuousRange() {
    _hasMin = false;
    _hasMax = false;
  }

  boolean hasMin() {
    return _hasMin;
  }
  boolean hasMax() {
    return _hasMax;
  }

  float getMin() {
    return _min;
  }
  float getMax() {
    return _max;
  }

  void setMin(float val) {
    _min = val;
    _hasMin = true;
  }
  void setMax(float val) {
    _max = val;
    _hasMax = true;
  }

  void updateMin(float val) {
    if (!_hasMin || val < _min) {
      _min = val;
      _hasMin = true;
    }
  }
  void updateMax(float val) {
    if (!_hasMax || val < _max) {
      _max = val;
      _hasMax = true;
    }
  }

  void update(float val) {
    updateMin(val);
    updateMax(val);
  }

  boolean isInRange(float val) {
    if (!_hasMin) {
      if (!_hasMax) {
        return true;
      } else {
        return (val <= _max);
      }
    } else if (!_hasMax) {
      return (_min <= val);
    } else {
      return (_min <= val && val <= _max);
    }
  }

} // end class DelvContinuousRange

class DelvBasicAttribute {


  String _name;
  HashMap<String, String> _items;
  // TODO should decide a better name and probably store as double
  // And really this is a horrible hack.  Storage should be based on Attribute type, create some actual classes here
  //TreeMap<String, Float[] > _floatArrayItems;
  HashMap<String, Integer> _floatArrayMap;
  float[][] _floatArrayItems;
  HashMap<String, Float>  _floatItems;
  AttributeType _type;
  // TODO color map
  DelvColorMap _colorMap;
  // TODO range
  DelvRange _fullRange;
  DelvRange _visibleRange;
  String _highlightCategory;
  String _hoverCategory;

  DelvBasicAttribute(String name, AttributeType type, DelvColorMap color_map, DelvRange data_range) {
    _name = name;
    _items = new HashMap<String, String>();
    _floatArrayMap = new HashMap<String, Integer>();
    _floatArrayItems = new float[0][];
    _floatItems = new HashMap<String, Float>();
    _type = type;
    _colorMap = color_map;
    _fullRange = data_range;
    _visibleRange = data_range;
    _highlightCategory = "";
    _hoverCategory = "";
  }

  void setItem(String id, String item) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _items.put(id, item);
      ((DelvCategoricalRange)_fullRange).addCategory(item);
      ((DelvCategoricalRange)_visibleRange).addCategory(item);
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      Float val = parseFloat(item);
      _floatItems.put(id, val);
      ((DelvContinuousRange)_fullRange).update(val);
    } else if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      // TODO fix this
      println("Cannot set a FLOAT_ARRAY from String");
    }
  }
  void setFloatItem(String id, Float item) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      _floatItems.put(id, item);
      ((DelvContinuousRange)_fullRange).update(item);
    }
  }
  void setFloatArrayItem(String id, float[] item) {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      Integer idx;
      if (!_floatArrayMap.containsKey(id)) {
        int old_size = _floatArrayItems.length;
        float[][] tmpArray = new float[old_size+1][];
        System.arraycopy(_floatArrayItems, 0, tmpArray, 0, old_size);
        _floatArrayItems = tmpArray;
        _floatArrayMap.put(id, old_size);
        idx = old_size;
      }
      else {
      idx = _floatArrayMap.get(id);
      }
      _floatArrayItems[idx] = item;
    }
  }

  // String[] getAllIdsAndItems(String id) { }

  String getItem(String id) {
    if (_items.containsKey(id)) {
      return "" + _items.get(id);
    } else if (_floatItems.containsKey(id)) {
      return "" + _floatItems.get(id);
    } else {
      return "";
    }
  }
  Float getItemAsFloat(String id) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      return _floatItems.get(id);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      if (_items.containsKey(id)) {
        return parseFloat(_items.get(id));
      } else {
        return 0.0f;
      }
    } else {
      return 0.0f;
    }
  }
  float[] getItemAsFloatArray(String id) {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      Integer idx = _floatArrayMap.get(id);
      return _floatArrayItems[idx];
      // TODO does this make sense for any other type?
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      if (_items.containsKey(id)) {
        String item = _items.get(id);
        String[] vals = splitTokens( item, "," );
        float[] nums = new float[vals.length];
        for (int i = 0; i < vals.length; i++) {
          nums[i] = parseFloat(vals[i]);
        }
        return nums;
      } else {
        return new float[0];
      }
    } else {
      return new float[0];
    }
  }

  String[] getAllItems() {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      String[] items = new String [_floatItems.size()];
      int cnt = 0;
      for (Float item : _floatItems.values()) {
        items[cnt++] = "" + item;
      }
      return (items);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      String[] items = new String[_items.size()];
      int cnt = 0;
      for (String item : _items.values()) {
        items[cnt++] = item;
      }
      return (items);
    }
    return new String[0];
  }
  Float[] getAllItemsAsFloat() {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      Float[] items = new Float[_floatItems.size()];
      int cnt = 0;
      for (Float item : _floatItems.values()) {
        items[cnt++] = item;
      }
      return (items);
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      // TODO handle case where type doesn't convert well better
      Float[] items = new Float[_items.size()];
      int cnt = 0;
      for (String item : _items.values()) {
        items[cnt++] = parseFloat(item);
      }
      return (items);
    }
    return (new Float[0]);
  }
  float[][] getAllItemsAsFloatArray() {
    if (_type.equals(AttributeType.FLOAT_ARRAY)) {
      return _floatArrayItems;
      // TODO does this make sense for any other type?
    } else if (_type.equals(AttributeType.CATEGORICAL)) {
      float[][] items = new float[_items.size()][];
      int cnt = 0;
      for (String item : _items.values()) {
        String[] vals = splitTokens( item, "," );
        float[] nums = new float[vals.length];
        for (int i = 0; i < vals.length; i++) {
          nums[i] = parseFloat(vals[i]);
        }
        items[cnt++] = nums;
      }
      return (items);
    }
    return (new float[0][0]);
  }

  void updateHighlightedCategory(String cat) {
    _highlightCategory = cat;
  }

  void updateHoveredCategory(String cat) {
    _hoverCategory = cat;
  }

  String getHighlightedCategory() {
    return _highlightCategory;
  }

  String getHoveredCategory() {
    return _hoverCategory;
  }

  void toggleVisibility(String cat) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      ((DelvCategoricalRange)_visibleRange).toggleVisibility(cat);
    }
  }

  String[] getAllCategories() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_fullRange).getCategories();
    } else {
      return new String[0];
    }
  }

  String[] getVisibleCategories() {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_visibleRange).getVisibleCategories();
    } else {
      return new String[0];
    }
  }

  String[][] getAllCategoryColors() {
    String[] cats = getAllCategories();
    String[][] colors = new String[cats.length][3];
    for (int i = 0; i < cats.length; i++) {
      color c = _colorMap.getColor(cats[i]);
      colors[i][0] = "" + red(c);
      colors[i][1] = "" + green(c);
      colors[i][2] = "" + blue(c);
    }
    return colors;
  }

  String[][] getVisibleCategoryColors() {
    String[] cats = getVisibleCategories();
    String[][] colors = new String[cats.length][3];
    for (int i = 0; i < cats.length; i++) {
      color c = _colorMap.getColor(cats[i]);
      colors[i][0] = "" + red(c);
      colors[i][1] = "" + green(c);
      colors[i][2] = "" + blue(c);
    }
    return colors;
  }

  String[] getItemColor(String id) {
    color c = _colorMap.getColor(getItem(id));

    String[] colorStr = new String[3];
    colorStr[0] = "" + red(c);
    colorStr[1] = "" + green(c);
    colorStr[2] = "" + blue(c);
    return colorStr;
  }

  void setCategoryColor(String cat, String[] rgbColor) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      _colorMap.setColor(cat, color(parseInt(rgbColor[0]), parseInt(rgbColor[1]), parseInt(rgbColor[2])));
    }
  }

  void updateVisibility(String item) {
    if (_type.equals(AttributeType.CONTINUOUS)) {
      ((DelvContinuousRange)_visibleRange).update(parseFloat(item));
    }
  }

  // DelvRange getVisibleRange() {
  //   if (_type.equals(AttributeType.CONTINUOUS)) {
  //     return _visibleRange;
  //   }
  // }

  // void setVisibleRange(DelvRange vrange) {
  //   if (_type.equals(AttributeType.CONTINUOUS)) {
  //     _visibleRange = vrange;
  //   }
  // }

  boolean isItemVisible(String id) {
    if (_type.equals(AttributeType.CATEGORICAL)) {
      return ((DelvCategoricalRange)_visibleRange).isCategoryVisible(_items.get(id));
    } else if (_type.equals(AttributeType.CONTINUOUS)) {
      return ((DelvContinuousRange)_visibleRange).isInRange(_floatItems.get(id));
    } else {
      // TODO fix this, UNSTRUCTURED data is always visible for now
      return true;
    }
  }


} // end class DelvBasicAttribute

class DelvBasicDataSet {
  String _name;
  ArrayList<DelvItemId> _itemIds;
  HashMap<String, DelvBasicAttribute> _attributes;
  String _highlightId;
  String _hoverId;

  DelvBasicDataSet(String name) {
    _name = name;
    _itemIds = new ArrayList<DelvItemId>();
    _attributes = new HashMap<String, DelvBasicAttribute>();
    _highlightId = "";
    _hoverId = "";
  }

  void addId(String id) {
    DelvItemId newId = new DelvItemId(id);
    _itemIds.add(newId);
  }

  boolean hasId(String id) {
    for (DelvItemId item : _itemIds) {
      if (id.equals(item.name)) {
        return true;
      }
    }
    return false;
  }

  String[] getSelectedIds() {
    ArrayList<String> selected = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.selected) {
        selected.add(id.name);
      }
    }
    return selected.toArray(new String[selected.size()]);
  }

  String[] getVisibleIds() {
    ArrayList<String> visible = new ArrayList<String>();
    for (DelvItemId id : _itemIds) {
      if (id.visible) {
        visible.add(id.name);
      }
    }
    return visible.toArray(new String[visible.size()]);
  }

  String getHighlightedId() {
    return _highlightId;
  }
  String getHoveredId() {
    return _hoverId;
  }

  int getNumIds() {
    return _itemIds.size();
  }

  String getNextId() {
    return "" + _itemIds.size();
  }

  void setItem(String attr, String id, String item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setItem(id, item);
  }
  void setFloatItem(String attr, String id, Float item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setFloatItem(id, item);
  }
  void setFloatArrayItem(String attr, String id, float[] item) {
    if (!hasId(id)) {
      addId(id);
    }
    _attributes.get(attr).setFloatArrayItem(id, item);
  }

  void addAttribute(DelvBasicAttribute attr) {
    _attributes.put(attr._name, attr);
  }

  Boolean hasAttribute(String attr) {
    return _attributes.containsKey(attr);
  }

  String[] getAttributes() {
    return _attributes.keySet().toArray(new String[0]);
  }

  String[] getAllCategories(String attr) {
   return _attributes.get(attr).getAllCategories();
  }

  String[] getVisibleCategories(String attr) {
    return _attributes.get(attr).getVisibleCategories();
  }

  String[][] getAllCategoryColors(String attr) {
    return _attributes.get(attr).getAllCategoryColors();
  }

  String[][] getVisibleCategoryColors(String attr) {
    return _attributes.get(attr).getVisibleCategoryColors();
  }
  String[] getItemColor(String attr, String id) {
    return _attributes.get(attr).getItemColor(id);
  }
  String getHighlightedCategory(String attr) {
    return _attributes.get(attr).getHighlightedCategory();
  }
  String getHoveredCategory(String attr) {
    return _attributes.get(attr).getHoveredCategory();
  }

  String[] getAllItems(String attr) {
    return _attributes.get(attr).getAllItems();
  }
  Float[] getAllItemsAsFloat(String attr) {
    return _attributes.get(attr).getAllItemsAsFloat();
  }
  float[][] getAllItemsAsFloatArray(String attr) {
    return _attributes.get(attr).getAllItemsAsFloatArray();  
  }

  String getItem(String attr, String id) {
    return _attributes.get(attr).getItem(id);
  }
  Float getItemAsFloat(String attr, String id) {
    return _attributes.get(attr).getItemAsFloat(id);
  }
  float[] getItemAsFloatArray(String attr, String id) {
    return _attributes.get(attr).getItemAsFloatArray(id);
  }

  String[] getAllIds(String attr) {
    String[] ids = new String[_itemIds.size()];
    for (int i = 0; i < _itemIds.size(); i++) {
      ids[i] = _itemIds.get(i).name;
    }
    return ids;
  }

  // String[] getAllItemsAndIds(String attr) {
  //   return _attributes.get(attr).getAllIdsAndItems();
  // }

  void updateCategoryVisibility(String attr, String cat) {
    _attributes.get(attr).toggleVisibility(cat);
    determineItemVisibility();
  }

  void updateCategoryColor(String attr, String cat, String[] rgbColor) {
    _attributes.get(attr).setCategoryColor(cat, rgbColor);
  }

  void updateHighlightedCategory(String attr, String cat) {
    _attributes.get(attr).updateHighlightedCategory(cat);
  }

  void updateHoveredCategory(String attr, String cat) {
    _attributes.get(attr).updateHoveredCategory(cat);
  }



  void determineItemVisibility() {
    for (DelvItemId id : _itemIds) {
      id.visible = true;
      for (DelvBasicAttribute attr : _attributes.values()) {
        if (!attr.isItemVisible(id.name)) {
          id.visible = false;
          break;
        }
      }
    }
  }

  void updateSelectedIds(String[] ids) {
    for (DelvItemId id : _itemIds) {
      id.selected = false;
      for (int i = 0; i < ids.length; i++) {
        if (id.name.equals(ids[i])) {
          id.selected = true;
          break;
        }
      }
    }
  }

  void updateHighlightedId(String id) {
    _highlightId = id;
  }

  void updateHoveredId(String id) {
    _hoverId = id;
  }

  

} // end class DelvBasicDataSet

class DelvBasicData implements DelvData {
  Delv _delvIF;
  HashMap <String, DelvBasicDataSet> _data;

  DelvBasicData() {
    _data = new HashMap<String, DelvBasicDataSet>();
  }
  // TODO should data interface and delv interface be so tightly coupled? (each with a reference to the other?)
  void setDelvIF(Delv dlv) {
    _delvIF = dlv;
  }
  void updateCategoryVisibility(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateCategoryVisibility(attribute, category);
    _delvIF.emitSignal("categoryVisibilityChanged",invoker, dataset, attribute);
  }
  void updateCategoryColor(String invoker, String dataset, String attribute, String category, String[] rgbColor) {
    _data.get(dataset).updateCategoryColor(attribute, category, rgbColor);
    _delvIF.emitSignal("categoryColorsChanged", invoker, dataset, attribute);
  }
  void updateHighlightedCategory(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateHighlightedCategory(attribute, category);
    _delvIF.emitSignal("highlightedCategoryChanged",invoker, dataset, attribute);
  }
  void updateHoveredCategory(String invoker, String dataset, String attribute, String category) {
    _data.get(dataset).updateHoveredCategory(attribute, category);
    _delvIF.emitSignal("hoveredCategoryChanged",invoker, dataset, attribute);
  }
  void updateHighlightedId(String invoker, String dataset, String id) {
    _data.get(dataset).updateHighlightedId(id);
    _delvIF.emitSignal("highlightedIdChanged",invoker, dataset, id);
  }
  void updateHoveredId(String invoker, String dataset, String id) {
    _data.get(dataset).updateHoveredId(id);
    _delvIF.emitSignal("hoveredIdChanged",invoker, dataset, id);
  }
  void updateSelectedIds(String invoker, String dataset, String[] ids) {
    _data.get(dataset).updateSelectedIds(ids);
    _delvIF.emitSignal("selectedIdsChanged",invoker, dataset, ids);
  }

  void setItem(String dataset, String attribute, String identifier, String item) {
    _data.get(dataset).setItem(attribute, identifier, item);
  }
  void setFloatItem(String dataset, String attribute, String identifier, Float item) {
    _data.get(dataset).setFloatItem(attribute, identifier, item);
  }
  void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item) {
    _data.get(dataset).setFloatArrayItem(attribute, identifier, item);
  }

  Boolean hasAttribute(String dataset, String attribute) {
    return _data.get(dataset).hasAttribute(attribute);
  }

  String[] getAttributes(String dataset) {
    return _data.get(dataset).getAttributes();
  }

  String[] getVisibleCategories(String dataset, String attribute) {
    return _data.get(dataset).getVisibleCategories(attribute);
  }

  String[] getAllCategories(String dataset, String attribute) {
    return _data.get(dataset).getAllCategories(attribute);
  }

  String[][] getAllCategoryColors(String dataset, String attribute) {
    return _data.get(dataset).getAllCategoryColors(attribute);
  }
  String[][] getVisibleCategoryColors(String dataset, String attribute) {
    return _data.get(dataset).getVisibleCategoryColors(attribute);
  }
  String[] getItemColor(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemColor(attribute, identifier);
  }

  String[] getAllItems(String dataset, String attribute) {
    return _data.get(dataset).getAllItems(attribute);
  }
  Float[] getAllItemsAsFloat(String dataset, String attribute) {
    return _data.get(dataset).getAllItemsAsFloat(attribute);
  }
  float[][] getAllItemsAsFloatArray(String dataset, String attribute) {
    return _data.get(dataset).getAllItemsAsFloatArray(attribute);
  }

  String[] getAllIds(String dataset, String attribute) {
    return _data.get(dataset).getAllIds(attribute);
  }

  String getItem(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItem(attribute, identifier);
  }
  Float getItemAsFloat(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemAsFloat(attribute, identifier);
  }
  float[] getItemAsFloatArray(String dataset, String attribute, String identifier) {
    return _data.get(dataset).getItemAsFloatArray(attribute, identifier);
  }

  String getHighlightedId(String dataset) {
    return _data.get(dataset).getHighlightedId();
  }

  String getHoveredId(String dataset) {
    return _data.get(dataset).getHoveredId();
  }

  String getHighlightedCategory(String dataset, String attribute) {
    return _data.get(dataset).getHighlightedCategory(attribute);
  }
  String getHoveredCategory(String dataset, String attribute) {
    return _data.get(dataset).getHoveredCategory(attribute);
  }

  DelvBasicDataSet addDataSet(String dataset) {
    DelvBasicDataSet ds = new DelvBasicDataSet(dataset);
    _data.put(dataset, ds);
    return ds;
  }
} // end class DelvBasicData
