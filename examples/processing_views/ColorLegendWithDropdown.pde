// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

public class ColorLegendWithDropdownView extends DelvCompositeView {

  ColorPickerLegendView _legend_view;
  DropDownView _dropdown_view;
  String _dataAttr;

  public ColorLegendWithDropdownView() {
    this("ColorLegendWithDropdown");
  }

  public ColorLegendWithDropdownView(String name) {
    super(name);
    _dropdown_view = new DropDownView(name+"Menu");
    _legend_view = new ColorPickerLegendView(name+"Picker");
    // TODO order is important here! (especially for rendering!!!)
    addView(_legend_view);
    addView(_dropdown_view);
    _dataAttr = "";
  }

  public String dataAttr() {
    return _dataAttr;
  }
  public ColorLegendWithDropdownView dataAttr(String attr) {
    _dataAttr = attr;
    _legend_view.dataAttr(attr);
    _dropdown_view.catAttr(attr);
    return this;
  }

  public void mouseMoved() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseMovedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }
  public void mousePressed() {
    // TODO better to press mouseButton in directly?
    if ( mouseCapture(mouseX, mouseY) )
      mousePressedInView(mouseX - _origin[0], mouseY - _origin[1], mouseButton == RIGHT);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseReleased() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseReleasedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }
  public void mouseDragged() {
    if ( mouseCapture(mouseX, mouseY) )
      mouseDraggedInView(mouseX - _origin[0], mouseY - _origin[1]);
    else
      mouseOutOfView();
    draw();
  }

  public void mouseMovedInView(int mx, int my) {
    if (_dropdown_view.isDroppedDown()) {
      _dropdown_view.mouseMovedInView(mx, my);
      _legend_view.mouseOutOfView();
    }
    else {
      _legend_view.mouseMovedInView(mx, my);
      _dropdown_view.mouseOutOfView();
    }
  }
  public void mousePressedInView(int mx, int my, boolean rightPressed) {
    _dropdown_view.mousePressedInView(mx, my, rightPressed);
    if (!(_dropdown_view.isDroppedDown())) {
      _legend_view.mousePressedInView(mx, my, rightPressed);
    }
  }
  public void mouseReleasedInView(int mx, int my) {
    boolean wasDropped = _dropdown_view.isDroppedDown();
    _dropdown_view.mouseReleasedInView(mx, my);
    if (!wasDropped) {
      _legend_view.mouseReleasedInView(mx, my);
    }
  }
  public void mouseDraggedInView(int mx, int my) {
    if (!(_dropdown_view.isDroppedDown())) {
      _legend_view.mouseDraggedInView(mx, my);
    }
  }

}
