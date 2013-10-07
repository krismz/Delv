// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

// A view that can render the categories for
// one dimension of data.  It converts category selections into
// data filtering messages (category visibility).  For
// other behaviors of a category view, implement a different base view.
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

class DelvCategoryView extends DelvBasicView {
  String _cat1Attr;
  String[] _cat1;
  String[] _visibleCat1;
  color[] _cat1Colors;
  color[] _visibleCat1Colors;
  String _selectCat;
  String _hoverCat;
  String _highlightCat;
  
  DelvCategoryView() {
    this("DelvCategory");
  }

  DelvCategoryView(String name) {
    super(name);
    _cat1 = new String[0];
    _visibleCat1 = new String[0];
    _selectCat = "";
    _hoverCat = "";
    _highlightCat = "";
  }

  String cat1Attr() {
    return _cat1Attr;
  }
  DelvCategoryView cat1Attr(String attr) {
    _cat1Attr = attr;
    return this;
  }

  void setCat1(String[] cats) {
    _cat1 = cats;
    cat1Updated();
    draw();
  }
  void setVisibleCat1(String[] cats) {
    _visibleCat1 = cats;
    visibleCat1Updated();
    draw();
  }

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] cats;
      cats = _dataIF.getAllCategories(_datasetName, _cat1Attr);
      setCat1(cats);
      updateColors();
      updateVisibility();
    }
    super.reloadData(source);
  }

  void updateVisibility() {
    String[] selections;
    selections = _dataIF.getVisibleCategories(_datasetName, _cat1Attr);
    setVisibleCat1(selections);
  }

  void updateColors() {
    if (!_colorAttr.equals("")) {
      String[][] colorStrs;
      colorStrs = _dataIF.getAllCategoryColors(_datasetName, _colorAttr);
      _cat1Colors = new color[colorStrs.length];
      for (int i = 0; i < colorStrs.length; i++) {
        String[] cStr = colorStrs[i];
        color c = color(int(cStr[0]), int(cStr[1]), int(cStr[2]));
        _cat1Colors[i] = c;
      }
      cat1ColorsUpdated();

      colorStrs = _dataIF.getVisibleCategoryColors(_datasetName, _colorAttr);
      _visibleCat1Colors = new color[colorStrs.length];
      for (int i = 0; i < colorStrs.length; i++) {
        String[] cStr = colorStrs[i];
        color c = color(int(cStr[0]), int(cStr[1]), int(cStr[2]));
        _visibleCat1Colors[i] = c;
      }
      visibleCat1ColorsUpdated();
    }
  }

  void connectSignals() {
    if (_delvIF == null) {
      return;
    }

    _delvIF.connectToSignal("categoryVisibilityChanged", _name, "onCategoryVisibilityChanged");
    _delvIF.connectToSignal("hoveredCategoryChanged", _name, "onHoveredCategoryChanged");
    _delvIF.connectToSignal("hoveredIdChanged", _name, "onHoveredIdChanged");
    _delvIF.connectToSignal("highlightedCategoryChanged", _name, "onHighlightedCategoryChanged");
    _delvIF.connectToSignal("categoryColorsChanged", _name, "onCategoryColorsChanged");
  }

 void onCategoryVisibilityChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name + ".onCategoryVisibilityChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name + ".onCategoryVisibilityChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if ((dataset.equals(_datasetName)) && (attribute.equals(_cat1Attr))) {
        updateVisibility();
      }
    }
  }
  void onHoveredIdChanged(String invoker, String dataset, String identifier) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name+".onHoveredIdChanged(" + dataset + ", " + identifier + ") triggered by self");
    } else {
      _delvIF.log(_name+".onHoveredIdChanged(" + dataset + ", " + identifier + ") triggered by " + invoker);
      if (dataset.equals(_datasetName)) {
        _hoverCat = _dataIF.getItem(_datasetName, _cat1Attr, identifier);
        hoveredCatUpdated();
      }
    }
  }
  void onHoveredCategoryChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name+".onHoveredCategoryChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name+".onHoveredCategoryChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if (dataset.equals(_datasetName) && attribute.equals(_cat1Attr)) {
        _hoverCat = _dataIF.getHoveredCategory(_datasetName, _cat1Attr);
        hoveredCatUpdated();
      }
    }
  }
  void onHighlightedCategoryChanged(String invoker, String dataset, String attribute) {
    if (invoker.equals(_name)) {
      _delvIF.log(_name + ".onHighlightedCategoryChanged(" + dataset + ", " + attribute + ") triggered by self");
    } else {
      _delvIF.log(_name + ".onHighlightedCategoryChanged(" + dataset + ", " + attribute + ") triggered by " + invoker);
      if (dataset.equals(_datasetName) && attribute.equals(_cat1Attr)) {
        _highlightCat = _dataIF.getHighlightedCategory(_datasetName, _cat1Attr);
        highlightedCatUpdated();
      }
    }
  }

  void onCategoryColorsChanged(String invoker, String dataset, String attribute) {
    if (!invoker.equals(_name) &&
        dataset.equals(_datasetName) &&
        attribute.equals(_cat1Attr)) {
          updateColors();
    }
  }


  public void selectedCat(String cat) {
    selectedCat(cat, true);
  }
  public void selectedCat(String cat, boolean doDraw) {
    // TODO decide whether selectionChanged should only be issued for different
    // selections vs repeats of the same.
    // if (!(cat.equals(_selectCat))) {
    _selectCat = cat;
    // TODO distinguish between Item selection, Category selection, and Attribute selection
    // TODO can category selection mean something else besides visibility?
    _dataIF.updateCategoryVisibility(_name, _datasetName, _cat1Attr, cat);
    if (doDraw) {
      draw();
    }
    // }
  }

  public void hoveredCat(String cat) {
    hoveredCat(cat, true);
  }
  public void hoveredCat(String cat, boolean doDraw) {
    if (!(cat.equals(_hoverCat))) {
      _hoverCat = cat;
      _dataIF.updateHoveredCategory(_name, _datasetName, _cat1Attr, cat);
      if (doDraw) {
        draw();
      }
    }
  }

  public void highlightedCat(String cat) {
    highlightedCat(cat, true);
  }
  public void highlightedCat(String cat, boolean doDraw) {
    if (!(cat.equals(_highlightCat))) {
      _highlightCat = cat;
      _dataIF.updateHighlightedCategory(_name, _datasetName, _cat1Attr, cat);
      if (doDraw) {
        draw();
      }
    }
  }

  


  // override these if you need to do a one-time calculation when these events happen
  public void cat1Updated() {}
  public void visibleCat1Updated() {}
  public void hoveredCatUpdated() {}
  public void highlightedCatUpdated() {}
  public void cat1ColorsUpdated() {}
  public void visibleCat1ColorsUpdated() {}

}
