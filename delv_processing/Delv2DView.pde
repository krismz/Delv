// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

// A view that can render two dimensions of data
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

class Delv2DView extends Delv1DView {
  String _dim2Attr;
  String[] _dim2;

  Delv2DView() {
    this("Delv2D");
  }
  Delv2DView(String name) {
    super(name);
    _dim2 = new String[0];
  }

  String dim2Attr() {
    return _dim2Attr;
  }

  Delv2DView dim2Attr(String attr) {
    _dim2Attr = attr;
    return this;
  }

  void setDim2(String[] dim) {
    _dim2 = dim;
    dim2Updated();
    draw();
  }

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _dataIF.getAllItems(_datasetName, _dim2Attr);
      setDim2(data);
    }
    super.reloadData(source);
  }

  void dim2Updated() {}

}
