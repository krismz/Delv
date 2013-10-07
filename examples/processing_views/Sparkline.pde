// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

class SparklineView extends Delv1DView {
  int _x_spacing;

  SparklineView(String name) {
    super(name);
    _x_spacing = 8;
  }
  SparklineView() {
    this("Sparkline");
  }

  void render() {
    int x;

    // Draw lines between data points.
    x = _x_spacing;
    for (int i=1; i<_dim1.length;i++) {
      float curr = _h - float(_dim1[i]);
      float previous = _h - float(_dim1[i-1]);
      stroke(#FF7F00);
      line(x,previous,x+_x_spacing,curr);
      x=x+_x_spacing;
    }

    // Draw value lines.
    x = _x_spacing;
    for (int i=0;i< _dim1.length;i++) {
      float y = _h - float(_dim1[i]);
      if (_hovered_idx == i) {
        textFont(_pixel_font_8);
        textAlign( LEFT, BOTTOM );
        fill(100);
        text(getId(i) + ": " + _dim1[i], x, y-2);
        stroke(#E31A1C);
      } else {
        stroke(#1F78B4);
      }
      line(x,y,x+_x_spacing/2,y);
      x = x+_x_spacing;
    }

  }

  int overPoint(int mx, int my) {
    int x = _x_spacing;
    int tol = 3;
    int idx = -1;
    // TODO, really should be able to find closest data point based on
    // mx, instead of iterating through
    for (int i = 0; i < _dim1.length; i++) {
      float y = _h - float(_dim1[i]);
      if ((my > y - tol) &&
          (my < y + tol) &&
          (mx > x) &&
          (mx < x + _x_spacing)) {
        idx = i;
        break;
      }
      x = x + _x_spacing;
    }
    return idx;
  }

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