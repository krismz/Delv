// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================
class Template200View extends Delv2DView {
  float column_width;
  float column_width_with_space;
  int height_multiplier;

  Template200View(String name) {
    super(name);
    column_width = 0;
    column_width_with_space = 0;
    height_multiplier = 0;
  }

  void render() {
    // TODO should these length checks be in the parent class?
    if (_dim1.length == 0) {
      return;
    }
    color back = color(255);
    color fore = color(178,178,178);
    fill(fore);
    smooth();

    textFont(_verdana_font_12);
    textAlign(LEFT, CENTER);

    int largest = int(_dim1[0]);
    // TODO convention for which attribute gets assigned dim1 vs dim2?
    for (int a = 1; a < _dim1.length; a++){
      if(int(_dim1[a]) > largest){
        largest = int(_dim1[a]);
      }
    }
    height_multiplier = round(0.7 * _h / largest);

    int space_available;
    if(_dim1.length < 10)
    {
      space_available = round(0.72 * _w);
    }
    else {
      space_available = round(0.8 * _w);
    }
    column_width = (space_available - (_dim1.length - 1) * 5) / (_dim1.length - 1);
    column_width_with_space = column_width + 5;

    float height_counter = 0;
    ellipseMode(CORNERS);
    for(int a =1; a < _dim1.length; a++)
    {
      height_counter = 0;
      while(height_counter < int(_dim1[a]) * height_multiplier)
      {
       ellipse(0.1 * _w + column_width_with_space * (a -1), 0.85 * _h - height_counter, 0.1*_w + column_width_with_space * (a -1) + column_width, 0.85 * _h - height_counter - column_width);
        height_counter += column_width_with_space;
      }
      fill(back);
      rect(0.1*_w + column_width_with_space * (a -1), 0.85 * _h - int(_dim1[a]) * height_multiplier - column_width_with_space, column_width, column_width);
      fill(fore);

      rotate(HALF_PI);
      translate(0,-_w);
      text(_dim2[a], 0.86*_h, 0.9*_w - (column_width_with_space / 2 + column_width_with_space * (a - 1)));
      translate(0,_w);
      rotate(-HALF_PI);
    }

    textFont(_verdana_font_30);
    textAlign(LEFT, BASELINE);
    text(_label, 0.1*_w, 0.05*_h);
    // int font_size = 13;
    // textFont(myFont, font_size);  
    // textblock(blurb, .1*_w, .07*_h, .7*_h);
  }

  int overPoint(int mx, int my) {
    float x = 0.1 * _w + column_width_with_space;
    int tol = 3;
    int idx = -1;
    // TODO, really should be able to find closest data point based on
    // mx, instead of iterating through
    for (int i = 0; i < _dim1.length; i++) {
      float y = _h - float(_dim1[i]) * height_multiplier;
      if ((mx > x) &&
          (mx < x + column_width_with_space)) {
        idx = i;
        break;
      }
      x = x + column_width_with_space;
    }
    return idx;
  }

  // TODO HERE HERE HERE some part of mouseMovedInView or overPoint is broken
  void mouseMovedInView(int mx, int my) {
    int hidx;
    hidx = overPoint(mx, my);
    if (hidx >= 0) {
      hoverOn(hidx);
    } else {
      hoverOff();
    }
  }

}
