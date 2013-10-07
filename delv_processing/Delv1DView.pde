// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

// A view that can render one dimension of data
// Since it inherits from DelvBasicView, it also
// has access to the colorAttr

class Delv1DView extends DelvBasicView {
  String _dim1Attr;
  String[] _dim1;

  Delv1DView() {
    this("Delv1D");
  }

  Delv1DView(String name) {
    super(name);
    _dim1 = new String[0];
  }

  String dim1Attr() {
    return _dim1Attr;
  }
  Delv1DView dim1Attr(String attr) {
    _dim1Attr = attr;
    return this;
  }

  void setDim1(String[] dim) {
    _dim1 = dim;
    dim1Updated();
    draw();
  }

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] data;
      // TODO need to get Visible Items or Filtered Items or something else
      data = _dataIF.getAllItems(_datasetName, _dim1Attr);
      setDim1(data);
      String[] ids;
      ids = _dataIF.getAllIds(_datasetName, _dim1Attr);
      setIds(ids);
    }
    super.reloadData(source);
  }

  void dim1Updated() {}

}
