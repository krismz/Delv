// A simple test interface that reads in two column data from pointFile
// and stores it in a dataset called Points with attributes ids, pt0, and pt1

class SimpleTestData implements DelvData {
  Delv _delvIF;
  String _name;
  String _pointFile;
  String _dataset;
  String _highlightedID;
  String _hoveredID;
  ArrayList<String> _ids;
  ArrayList<String> _col0;
  ArrayList<String> _col1;

  SimpleTestData(String name, String pointFile) {
    _name = name;
    _pointFile = pointFile;
    _highlightedID = "";
    _hoveredID = "";
    _dataset = "Points";
    _ids = new ArrayList<String>();
    _col0 = new ArrayList<String>();
    _col1 = new ArrayList<String>();
    readPoints(_pointFile);
  }

  void setName(String name) {
    _name = name;
  }
  String getName() {
    return _name;
  }

  // TODO should data interface and delv interface be so tightly coupled? (each with a reference to the other?)
  void setDelvIF(Delv dlv) {
    _delvIF = dlv;
  }

  void readPoints(String filename) {
    String [] rows = loadStrings( filename );
    int rowcounter = 0;
    int itemcounter = 0;
    String[] cols;

    while ( rowcounter < rows.length )
    {
      cols = splitTokens( rows[rowcounter++] );

      if ( cols.length == 0 )
        continue;

      else if (cols.length == 2 )
      {
        // ids will be one-based, and not contiguous
        _ids.add("" + itemcounter);
        itemcounter++;
        _col0.add(cols[0]);
        _col1.add(cols[1]);
      }
    }
  }



  void updateCategoryVisibility(String invoker, String dataset, String attribute, String selection) {
    _delvIF.log("updateCategoryVisibility not implemented yet.");
  }
  void updateCategoryColor(String invoker, String dataset, String attribute, String selection, String[] rgbColor) {
    _delvIF.log("updateCategoryColor not implemented yet.");
  }
  void updateHighlightedCategory(String invoker, String dataset, String attribute, String selection) {
    _delvIF.log("updateHighlightedCategory not implemented yet.");
  }
  void updateHoveredCategory(String invoker, String dataset, String attribute, String selection) {
    _delvIF.log("updateHoveredCategory not implemented yet.");
  }
  void updateHighlightedId(String invoker, String dataset, String id) {
    if (dataset.equals(_dataset)) {
      _highlightedID = id;
      _delvIF.emitSignal("highlightedIdChanged",invoker, dataset, id);
    }
  }
  void updateHoveredId(String invoker, String dataset, String id) {
    if (dataset.equals(_dataset)) {
      _hoveredID = id;
      _delvIF.emitSignal("hoveredIdChanged",invoker, dataset, id);
    }
  }
  void updateSelectedIds(String invoker, String dataset, String[] ids) {
    _delvIF.log("updateSelectedIds not implemented yet.");
  }

  String[] getAllCategories(String dataset, String attribute) {
    _delvIF.log("getAllCategories not implemented yet.");
    return new String[0];
  }
  String[] getVisibleCategories(String dataset, String attribute) {
    _delvIF.log("getVisibleCategories not implemented yet.");
    return new String[0];
  }
  String[][] getAllCategoryColors(String dataset, String attribute) {
    _delvIF.log("getAllCategoryColors not implemented yet.");
    return new String[0][3];
  }
  String[][] getVisibleCategoryColors(String dataset, String attribute) {
    _delvIF.log("getVisibleCategoryColors not implemented yet.");
    return new String[0][3];
  }
  String[] getItemColor(String dataset, String attribute, String identifier) {
    _delvIF.log("getItemColor not implemented yet.");
    return new String[3];
  }

  void setItem(String dataset, String attribute, String identifier, String item) {
    _delvIF.log("setItem not implemented yet.");
  }
  void setFloatItem(String dataset, String attribute, String identifier, Float item) {
    _delvIF.log("setFloatItem not implemented yet.");
  }
  void setFloatArrayItem(String dataset, String attribute, String identifier, float[] item) {
    _delvIF.log("setFloatArrayItem not implemented yet.");
  }

  Boolean hasAttribute(String dataset, String attribute) {
    _delvIF.log("hasAttribute not implemented yet.");
    return false;
  }
  String[] getAttributes(String dataset) {
    _delvIF.log("getAttributes not implemented yet.");
    return new String[0];
  }

  String[] getAllItems(String dataset, String attribute) {
    if (dataset.equals(_dataset)) {
      if (attribute.equals("pt0")) {
        return _col0.toArray(new String[_col0.size()]);
      } else if (attribute.equals("pt1")) {
        return _col1.toArray(new String[_col1.size()]);
      } else if (attribute.equals("ids")) {
        return _ids.toArray(new String[_ids.size()]);
      } else {
        return new String[0];
      }
    } else {
      return new String[0];
    }
  }
  Float[] getAllItemsAsFloat(String dataset, String attribute) {
    if (dataset.equals(_dataset)) {
      if (attribute.equals("pt0")) {
        Float[] items = new Float[_col0.size()];
        int count = 0;
        for (String item : _col0) {
          items[count] = parseFloat(item);
        }
        return items;
      } else if (attribute.equals("pt1")) {
        Float[] items = new Float[_col1.size()];
        int count = 0;
        for (String item : _col1) {
          items[count] = parseFloat(item);
        }
        return items;
      } else if (attribute.equals("ids")) {
        Float[] items = new Float[_ids.size()];
        int count = 0;
        for (String item : _ids) {
          items[count] = parseFloat(item);
        }
        return items;
      } else {
        return new Float[0];
      }
    } else {
      return new Float[0];
    }
  }
  float[][] getAllItemsAsFloatArray(String dataset, String attribute) {
    _delvIF.log("getAllItemsAsFloatArray not implemented yet.");
    return new float[0][0];
  }

  String[] getAllIds(String dataset, String attribute) {
    if (dataset.equals(_dataset)) {
      return _ids.toArray(new String[_ids.size()]);
    } else {
      return new String[0];
    }
 }
  String getItem(String dataset, String attribute, String identifier) {
    String item = "";
    if (dataset.equals(_dataset)) {
      int idx = -1;

      for ( String id : _ids ) {
        if ( id.equals(identifier) ) {
          idx = parseInt(id);
          break;
        }
      }

      if (idx >= 0) {
        if (attribute.equals("pt0")) {
          item = _col0.get(idx);
        } else if (attribute.equals("pt1")) {
          item = _col1.get(idx);
        }
      }
    }
    return item;
  }
  Float getItemAsFloat(String dataset, String attribute, String identifier) {
    return parseFloat(getItem(dataset, attribute, identifier));
  }
  float[] getItemAsFloatArray(String dataset, String attribute, String identifier) {
    _delvIF.log("getItemAsFloatArray not implemented yet.");
    return new float[0];
  }

  String getHighlightedId(String dataset) {
    if (dataset.equals(_dataset)) {
      return _highlightedID;
    } else {
      return "";
    }
  }
  String getHoveredId(String dataset) {
    if (dataset.equals(_dataset)) {
      return _hoveredID;
    } else {
      return "";
    }
  }
  String getHighlightedCategory(String dataset, String attribute) {
    _delvIF.log("getHighlightedCategory not implemented yet.");
    return "";
  }
  String getHoveredCategory(String dataset, String attribute) {
    _delvIF.log("getHoveredCategory not implemented yet.");
    return "";
  }

}
