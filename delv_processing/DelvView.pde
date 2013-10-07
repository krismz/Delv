// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================
// DelvView is needed to support having multiple processing sketches in both Processing and processing.js

interface DelvView {
  void bindDelv(Delv dlv);
  DelvView dataIF(String dataIFName);
  String name();
  DelvView name(String name);
  void connectSignals();
  void reloadData(String source);
  // TODO should resize be handled like other signals or treated specially?
  // for instance, should it be called sizeChanged?
  void resize(int w, int h);

  // TODO undo this hack
  void onDataUpdated(String invoker, String dataset, String attribute);
  void onDataUpdated(String invoker, String dataset, String[] attributes);

  void draw();
  void setup();
  void mouseMoved();
  void mouseOut();
  void mouseClicked();
  void mouseDragged();
  void mousePressed();
  void mouseReleased();
  void mouseScrolled();
}

public class DelvBasicView implements DelvView {
  // mouseScroll defined to keep Processing happy.
  // For Processing.js override by assigning processing instance to _p
  //  since _p == this in Processing
  // then always access mouseScroll through _p.mouseScroll
  int mouseScroll = 0;
  DelvBasicView _p;
  int _w = 100;
  int _h = 100; // The width and height of the view
  int[] _origin;
  int _background_color;
  String[] _ids;
  String _hoverId;
  String[] _selectIds;
  String _highlightId;
  String _colorCat;
  String _label;
  int _highlighted_idx;
  int _hovered_idx;
  int[] _selected_idx;
  Delv _delvIF;
  DelvData _dataIF;
  String _name;
  String _datasetName;
  String _colorAttr;

       // * * * Constructors * * * //
  public DelvBasicView(String name, int [] origin, int w, int h){
    _p = this;
    _name = name;
    _datasetName = "";
    _label = "";
    _origin = origin;
    _w = w;
    _h = h;
    _background_color = color(255);
    _ids = new String[0];
    _hoverId = "";
    _selectIds = new String[0];
    _highlightId = "";
    _colorCat = "";
    _highlighted_idx = -1;
    _hovered_idx = -1;
    _selected_idx = new int[0];
    _colorAttr = "";
  }
  public DelvBasicView() { this("BasicView", new int[2], 100, 100); }
  public DelvBasicView(String name) { this(name, new int[2], 100, 100); }

  public void bindDelv(Delv dlv) { _delvIF = dlv; }

  public DelvView dataIF(String dataIFName) {
    _dataIF = _delvIF.getDataIF(dataIFName);
    return this;
  }

  public String name() { return _name; }
  public DelvBasicView name(String name) {
    _name = name;
    return this;
  }

  public String datasetName() {
    return _datasetName;
  }
  public DelvBasicView datasetName(String name) {
    _datasetName = name;
    return this;
  }

  String colorAttr() {
    return _colorAttr;
  }
  DelvBasicView colorAttr(String attr) {
    _colorAttr = attr;
    return this;
  }

  void connectSignals() {
    if (_delvIF == null) {
      return;
    }
    _delvIF.connectToSignal("highlightedIdChanged", _name, "onHighlightedIdChanged");
    _delvIF.connectToSignal("hoveredIdChanged", _name, "onHoveredIdChanged");
    _delvIF.connectToSignal("selectedIdsChanged", _name, "onSelectedIdsChanged");
  }

  void selectionChanged(String selection) {
    // see if need to add any other logic here
    // TODO distinguish between Item selection, Category selection, and Attribute selection
    String[] selections = new String[1];
    selections[0] = selection;
    _dataIF.updateSelectedIds(_name, _datasetName, selections);
  }
  // public void selectionChanged(String selection) {}
  public void colorChanged(String selection, color c) {}

  // TODO undo this hack for onDataUpdated
  void onDataUpdated(String invoker, String dataset, String attribute) {}
  void onDataUpdated(String invoker, String dataset, String[] attributes) {}

  void onHighlightedIdChanged(String invoker, String dataset, String id) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setHighlightedId(id);
        // TODO any redraw notification here?
      }
    }
  }
  void onHoveredIdChanged(String invoker, String dataset, String id) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setHoveredId(id);
      }
    }
  }

  void onSelectedIdsChanged(String invoker, String dataset, String[] identifiers) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        setSelectedIds(identifiers);
      }
    }
  }

  void updateSelections() {
    // TODO handle selection updates
    // String[] selections;
    // selections = _dataIF.getSelectedIds(_datasetName);
    String id;
    id = _dataIF.getHighlightedId(_datasetName);
    setHighlightedId(id);
    id = _dataIF.getHoveredId(_datasetName);
    setHoveredId(id);
    // TODO handle color / color map updates
  }

  public void reloadData(String source) { updateSelections(); }

  public String label() {
    return _label;
  }
  public void label(String aLabel) {
    _label = aLabel;
    labelUpdated();
    draw();
  }

  // * * * Set the origin * * * //
  public void setOrigin(int [] origin){ _origin[0] = origin[0]; _origin[1] = origin[1]; }
  public void setOrigin(int x, int y){ _origin[0] = x; _origin[1] = y; }

  // * * * Get the width & height * * * //
  public int getWidth() { return _w; }
  public int getHeight() { return _h; }

  // * * * Get origin and origin plus width/height * * * //
  public int [] getOrigin() { return _origin; }
  public int getOriginPlusWidth(){  return _origin[0] + _w; }
  public int getOriginPlusHeight(){ return _origin[1] + _h; }

  // * * * Get/Set the background color * * * //
  public int getBackgroundColor() { return _background_color; }
  public DelvBasicView setBackgroundColor(int c) {
    _background_color = c;
    return this;
  }

  // * * * Get/Set the ids * * * //
  public String[] getIds() { return _ids; }
  public DelvBasicView setIds(String[] ids) {
    _ids = ids;
    idsUpdated();
    draw();
    return this;
  }
  public String getId(int idx) {
    return _ids[idx];
  }

  public void setHighlightedId(String id) {
    _highlighted_idx = -1;
    _highlightId = id;
    for ( int idx = 0; idx < _ids.length; idx++ ) {
      if (id.equals(_ids[idx])) {
        _highlighted_idx = idx;
        break;
      }
    }
    highlightedIdUpdated();
    draw();
  }
  public void setHoveredId(String id) {
    // TODO actually pick a better data structure and algorithm
    _hovered_idx = -1;
    _hoverId = id;
    for ( int idx = 0; idx < _ids.length; idx++ ) {
      if (id.equals(_ids[idx])) {
        _hovered_idx = idx;
        break;
      }
    }
    hoveredIdUpdated();
    draw();
  }
  public void setSelectedIds(String[] ids) {
    // TODO actually pick a better data structure and algorithm
    _selected_idx = new int[ids.length];
    _selectIds = ids;
    for ( int id = 0; id < ids.length; id++) {
      for ( int idx = 0; idx < _ids.length; idx++ ) {
        if (ids[id].equals(_ids[idx])) {
          _selected_idx[id] = idx;
          break;
        }
      }
    }
    selectedIdsUpdated();
    draw();
  }

  public void hoverOn(int id) {
    hoveredIdx(true, id, true);
  }
  public void hoverOn(int id, boolean doDraw) {
    hoveredIdx(true, id, doDraw);
  }
  public void hoverOff() {
    hoveredIdx(false,-1,true);
  }
  public void hoverOff(boolean doDraw) {
    hoveredIdx(false, -1, doDraw);
  }
  public void highlightOn(int id) {
    highlightedIdx(true, id, true);
  }
  public void highlightOn(int id, boolean doDraw) {
    highlightedIdx(true, id, doDraw);
  }
  public void highlightOff() {
    highlightedIdx(false,-1,true);
  }
  public void highlightOff(boolean doDraw) {
    highlightedIdx(false, -1, doDraw);
  }

  // * * * draw translates to the origin * * * //
  public void draw() {
    // Translate & render view
    pushMatrix();
    translate( _origin[0], _origin[1] );
    // Render the box around the view
    noStroke();
    fill( _background_color );
    rect(0, 0, _w, _h);
    noFill();
    render();
    popMatrix();
  }

  // * * * Check if the mouse is within this view - or its children * * * //
  public boolean mouseCapture(int mouseX, int mouseY) {
    // Check if mouse is within bounding box
    if(mouseX >= _origin[0] && mouseX <= _origin[0]+_w && 
       mouseY >= _origin[1] && mouseY <= _origin[1]+_h)
      return true;
    else
      return false;
  }

  public void resize(int w, int h) {
    if ((w != _w) || (h != _h)) {
      _w = w;
      _h = h;
      if (_p != this) {
        // in processing.js, so call size
        size(_w, _h);
      } // if in Processing do not call size!
      draw();
    }
  }

  public void mouseMoved() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseMovedInView(mouseX - _origin[0], mouseY - _origin[1]);
  }
  public void mouseOut() {
    mouseOutOfView();
  }
  public void mouseClicked() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseClickedInView(mouseX - _origin[0], mouseY - _origin[1]);
  }
  public void mousePressed() {
    // TODO better to press mouseButton in directly?
    if ( mouseCapture(mouseX, mouseY) )
      mousePressedInView(mouseX - _origin[0], mouseY - _origin[1], mouseButton == RIGHT);
  }
  public void mouseReleased() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseReleasedInView(mouseX - _origin[0], mouseY - _origin[1]);
  }
  public void mouseDragged() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseDraggedInView(mouseX - _origin[0], mouseY - _origin[1]);
  }
  public void mouseScrolled() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseScrolledInView(_p.mouseScroll);
  }

  // * * * Render the view (default just sets the background of the view) * * * //
  // override by each subclass
  public void render(){}
  public void setup(){}
  public void mouseMovedInView(int mx, int my) {}
  public void mouseOutOfView() {}
  public void mouseClickedInView(int mx, int my) {}
  public void mousePressedInView(int mx, int my, boolean rightPressed) {}
  public void mouseReleasedInView(int mx, int my) {}
  public void mouseDraggedInView(int mx, int my) {}
  public void mouseScrolledInView(int wr) {}

  // override these if you need to do a one-time calculation or update when
  // one of these events happens
  public void labelUpdated() {}
  public void idsUpdated() {}
  public void highlightedIdUpdated() {}
  public void hoveredIdUpdated() {}
  public void selectedIdsUpdated() {}

  // To work in javascript as well, cannot have method overloading!! Pick different names!
  public void hoveredId(String id) {
    hoveredId(id, true);
  }
  public void hoveredId(String id, boolean doDraw) {
    if (!(id.equals(_hoverId))) {
      _hoverId = id;
      _dataIF.updateHoveredId(_name, _datasetName, id);
      if (doDraw) {
        draw();
      }
    }
  }
  public void hoveredIdx(boolean isHovered, int id) {
    hoveredIdx(isHovered, id, true);
  }
  public void hoveredIdx(boolean isHovered, int id, boolean doDraw) {
    if (isHovered) {
      hoveredId(getId(id), doDraw);
    } else {
      hoveredId("", doDraw);
    }
  }

  // public void selectedId(String id) {
  //   selectedId(id, true);
  // }
  // public void selectedId(String id, boolean doDraw) {
  //   // TODO decide whether selectionChanged should only be issued for different
  //   // selections vs repeats of the same.
  //   // if (!(id.equals(_selectId))) {
  //   _selectId = id;
  //   // TODO distinguish between Item selection, Category selection, and Attribute selection
  //   String[] selections = new String[1];
  //   selections[0] = id;
  //   _dataIF.updateSelectedIds(_name, _datasetName, selections);
  //   if (doDraw) {
  //     draw();
  //   }
  //   // }
  // }
  // public void selectedIdx(boolean isSelected, int id) {
  //   selectedIdx(isSelected, id, true);
  // }
  // public void selectedIdx(boolean isSelected, int id, boolean doDraw) {
  //   if (isSelected) {
  //     selectedId(getId(id), doDraw);
  //   } else {
  //     selectedId("", doDraw);
  //   }
  // }


  public void highlightedId(String id) {
    highlightedId(id, true);
  }
  public void highlightedId(String id, boolean doDraw) {
    if (!(id.equals(_highlightId))) {
      _highlightId = id;
      _dataIF.updateHighlightedId(_name, _datasetName, id);
      if (doDraw) {
        draw();
      }
    }
  }
  public void highlightedIdx(boolean isHighlighted, int id) {
    highlightedIdx(isHighlighted, id, true);
  }
  public void highlightedIdx(boolean isHighlighted, int id, boolean doDraw) {
    if (isHighlighted) {
      highlightedId(getId(id), doDraw);
    } else {
      highlightedId("", doDraw);
    }
  }

  public void coloredCat(String cat, color c) {
    coloredCat(cat, c, true);
  }
  public void coloredCat(String cat, color c, boolean doDraw) {
    if (!(cat.equals(_colorCat))) {
      _colorCat = cat;
      // TODO HERE HERE HERE , how do we know when to updateCategoryColor
      // vs when to update item color or range color?
      // ANSWER (keep track of this for write-up): item colors will never be changed directly, so only ever updating categories or ranges.  So create two interfaces
      // coloredCat for updating categoryColor, and coloredRange for updating a continuous range w/ color.
      // NOTE: May also want to add a highlightColor, hoverColor, selectionColor
      // to the dataIF and have a way to update and get these colors.  Make these colors also part of the base view class.
      String[] colorStr = new String[3];
      colorStr[0] = "" + red(c);
      colorStr[1] = "" + green(c);
      colorStr[2] = "" + blue(c);
      _dataIF.updateCategoryColor(_name, _datasetName, _colorAttr, _colorCat, colorStr);
      if (doDraw) {
        draw();
      }
    }
  }

  // public void coloredIdx(int id, color c) {
  //   coloredIdx(id, c, true);
  // }
  // public void coloredIdx(int id, color c, boolean doDraw) {
  //   coloredId(getId(id), c, doDraw);
  // }

}

class DelvCompositeView extends DelvBasicView {
  ArrayList<DelvBasicView> _views;

       // * * * Constructors * * * //
  DelvCompositeView(String name, int [] origin, int w, int h){
    super(name, origin, w, h);
    _views = new ArrayList<DelvBasicView>();
  }
  DelvCompositeView() { this("CompositeView", new int[2], 100, 100); }
  DelvCompositeView(String name) { this(name, new int[2], 100, 100); }

  DelvCompositeView addView(DelvBasicView view) {
    _views.add(view);
    return this;
  }

  void bindDelv(Delv dlv) {
    for (DelvBasicView view: _views) {
      dlv.addView(view, view.name());
      view.bindDelv(dlv);
    }
    _delvIF = dlv;
  }

  DelvBasicView dataIF(String dataIFName) {
    for (DelvBasicView view: _views) {
      view.dataIF(dataIFName);
    }
    _dataIF = _delvIF.getDataIF(dataIFName);
    return this;
  }

  public DelvBasicView datasetName(String name) {
    _datasetName = name;
    for (DelvBasicView view: _views) {
      view.datasetName(name);
    }
    return this;
  }

  DelvBasicView colorAttr(String attr) {
    _colorAttr = attr;
    for (DelvBasicView view: _views) {
      view.colorAttr(attr);
    }
    return this;
  }

  public void label(String aLabel) {
    _label = aLabel;
    for (DelvBasicView view: _views) {
      view.label(aLabel);
    }
    labelUpdated();
  }

  void connectSignals() {
    for (DelvBasicView view: _views) {
      view.connectSignals();
    }
  }

  void reloadData(String source) {
    for (DelvBasicView view: _views) {
      view.reloadData(source);
    }
  }

  // * * * Set the origin * * * //
  void setOrigin(int [] origin){
    super.setOrigin(origin);
    for (DelvBasicView view: _views) {
      view.setOrigin(origin);
    }
  }
  void setOrigin(int x, int y){
    super.setOrigin(x, y);
    for (DelvBasicView view: _views) {
      view.setOrigin(x, y);
    }
  }

  void render(){
    for (DelvBasicView view: _views) {
      view.render();
    }
  }

  void setup(){
    for (DelvBasicView view: _views) {
      view.setup();
    }
  }

  void resize(int w, int h) {
    super.resize(w, h);
    for (DelvBasicView view: _views) {
      view.resize(w, h);
    }
    draw();
  }
  void mouseMoved() {
    for (DelvBasicView view : _views) {
      view.mouseMoved();
    }
  }
  void mouseClicked() {
    for (DelvBasicView view : _views) {
      view.mouseClicked();
    }
  }
  void mousePressed() {
    // TODO better to press mouseButton in directly?
    for (DelvBasicView view : _views) {
      view.mousePressed();
    }
  }
  void mouseReleased() {
    for (DelvBasicView view : _views) {
      view.mouseReleased();
    }
  }
  void mouseDragged() {
    for (DelvBasicView view : _views) {
      view.mouseDragged();
    }
  }
  void mouseScrolled() {
    for (DelvBasicView view : _views) {
      view.mouseScrolled();
    }
  }

} // end class DelvCompositeView
