// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

// BarHeightView is used to display the current value of an item in a vertical bar
// relative to the min and max values for that item
// dim1Attr must have numeric data
// dim2Attr is an optional categorical attribute

class MinMax {
  float _min;
  float _max;
  MinMax(float minimum, float maximum) {
    _min = minimum;
    _max = maximum;
  }

  float min() {
    return _min;
  }
  float max() {
    return _max;
  }
}

class BarHeightView extends Delv2DView {
  HashMap<String, MinMax> _minMaxMap;
  String _hovered_type;
  float _hovered_val;
  boolean _val_hovered;
  float _hovered_min;
  float _hovered_max;

  BarHeightView() {
    this("BarHeight");
  }

  BarHeightView(String name) {
    super(name);
    _minMaxMap = new HashMap<String, MinMax>();
    _hovered_type = "";
    _val_hovered = false;
  }

  void reloadData(String source) {
    if (_delvIF == null) {
      return;
    }

    if (!source.equals(_name)) {
      String[] categories;
      float[] minVals;
      float[] maxVals;
      if (!_dim2Attr.equals("")) {
          categories = _dataIF.getAllCategories(_datasetName, _dim2Attr);
        }
        else {
          categories = new String[1];
          categories[0] = "default";
        }

        minVals = new float[categories.length];
        maxVals = new float[categories.length];
        for (int i = 0; i < categories.length; i++) {
          minVals[i] = MAX_FLOAT;
          maxVals[i] = -MAX_FLOAT;
        }

        String[] vals;
        vals = _dataIF.getAllItems(_datasetName, _dim1Attr);
        String[] cats;
        if (!_dim2Attr.equals("")) {
          cats = _dataIF.getAllItems(_datasetName, _dim2Attr);
        } else {
          cats = new String[1];
          cats[0] = "default";
        }
        for (int i = 0; i < vals.length; i++) {
          float val = float(vals[i]);
          String cat;
          if (!_dim2Attr.equals("")) {
            cat = cats[i];
          } else {
            cat = cats[0];
          }
          for (int j = 0; j < categories.length; j++) {
            if (cat.equals(categories[j])) {
              if (val < minVals[j]) {
                minVals[j] = val;
              }
              if (val > maxVals[j]) {
                maxVals[j] = val;
              }
              break;
            }
          }
        }
        setMinMax(categories, minVals, maxVals);
    }

  }

  void connectSignals() {
    if (_delvIF == null) {
      return;
    }
    super.connectSignals();
    _delvIF.connectToSignal("hoveredCategoryChanged", _name, "onHoveredCategoryChanged");
  }

  void onHoveredCategoryChanged(String invoker, String dataset, String attribute) {
    if (!invoker.equals(_name)) {
      if (dataset.equals(_datasetName)) {
        if (attribute.equals(_dim2Attr)) {
          updateHoveredCategory(_dataIF.getHoveredCategory(_datasetName, _dim2Attr));
        } else {
          updateHoveredCategory("default");
        }
      }
    }
  }

  void hoveredIdUpdated() {
    String cat = _dataIF.getItem(_datasetName, _dim2Attr, _hoverId);
    String val = _dataIF.getItem(_datasetName, _dim1Attr, _hoverId);
    updateHoveredVal(val, cat);
  }

  void updateHoveredVal(String val, String cat) {
    setHoveredType(cat);
    if (!val.equals("")) {
      setHoveredVal(float(val));
    } else {
      noHoveredVal();
    }
 }

  void updateHoveredCategory(String cat) {
    setHoveredType(cat);
  }

  void setHoveredVal(float val) {
    _hovered_val = val;
    _val_hovered = true;
    draw();
  }

  void noHoveredVal() {
    _val_hovered = false;
    draw();
  }

  void setHoveredType(String type) {
    _hovered_type = type;
    if (!_hovered_type.equals("")) {
      MinMax val = _minMaxMap.get(_hovered_type);
      _hovered_min = val.min();
      _hovered_max = val.max();
    }
    draw();
  }

  void setMinMax(String[] names, float[] mins, float[] maxs) {
    _minMaxMap = new HashMap<String, MinMax>();
    for (int i = 0; i < names.length; i++) {
      MinMax val = new MinMax(mins[i], maxs[i]);
      _minMaxMap.put(names[i], val);
    }
  }

  void render() {
    int x, y;
    x = y = 0;

    stroke( REGION_LINE_COLOR );
    strokeWeight( 1 );
    line( x, y-20, x+_w, y-20 );
    fill( REGION_LINE_COLOR );
    textFont( _pixel_font_8 );
    textAlign( RIGHT, BOTTOM );
    text( "bar height", x+_w, y-22 );

    // the bar legend
    x += LEGEND_COLOR_PICKER_OFFSET;
    y = 10;
//     int rh = 40;
//     int rw = 26;
    int rh = _h-20;
    int rw = 26;
    rectMode( CORNER );
    noStroke();
    fill( REGION_MAX_VALUE_BAND_COLORS[0] );
    rect( x, y, rw, rh/2 );
    fill( REGION_MAX_VALUE_BAND_COLORS[1] );
    rect( x, y+rh/2, rw, rh/2 );

    strokeWeight( REGION_LINE_WEIGHT );
    stroke( REGION_HALF_VALUE_LINE_COLOR );
    line( x, y+rh/2, x+rw, y+rh/2 );

    stroke( DEFAULT_COLOR );
    line( x, y, x+rw+10, y );
    line( x, y+rh, x+rw+10, y+rh );

    if ( !_hovered_type.equals("") )
    {

      textFont( _pixel_font_8 );
      fill( LABEL_COLOR );

      textAlign( LEFT, BOTTOM );
      text( _hovered_max, x+rw+12, y );

      textAlign( LEFT, BOTTOM );
      text( _hovered_min, x+rw+12, y+rh );

      // if an item is rolled over, show it in the legend
      if ( _val_hovered ) {
        float height = round((1.0 - (_hovered_val - _hovered_min)/(_hovered_max - _hovered_min)) * rh);
        if (_hovered_val == _hovered_max) {
          height = 0;
        }
        y += height;

        stroke( ROLLED_OVER_FEATURE_LINE_COLOR );
        line( x+8, y, x+rw+10, y );
        fill( DEFAULT_COLOR );
        rect( x+8, y, 10, rh-height );
        textAlign( LEFT, BOTTOM );
        fill( LABEL_COLOR );
        text( _hovered_val, x+rw+12, y );
      }
    }
  }

}
