// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

public class ColorPickerLegendView extends DelvCategoryView {
  int _color_picker_w, _color_picker_h;
  int[] _color_picker_origin;
  int _item_legend_w, _item_legend_h;
  int[] _item_legend_origin;
  boolean _color_picker_one_row;
  boolean _color_selected;
  boolean _legend_item_color_selected;
  boolean _clear_button_selected;
  int _selected_color, _selected_legend_item_color;
  int[] _color_selected_box_offset, _legend_item_color_box_offset, _legend_item_color_box;
  int _mx, _my;

//////////////////
  boolean _item_rolled_over;
  String _rolled_over_item;

  public ColorPickerLegendView() {
    this("ColorPickerLegend");
  }

  public ColorPickerLegendView(String name) {
    super(name);
    _mx = _my = 0;
    _color_picker_origin = new int[2];
    _item_legend_origin = new int[2];
    _color_selected_box_offset = new int[2];
    _legend_item_color_box_offset = new int[2];
    _legend_item_color_box = new int[2];
    _color_selected = _legend_item_color_selected = _clear_button_selected = false;
    _item_rolled_over = false;
    _rolled_over_item = "";

    _item_legend_w = 2*FEATURE_LEGEND_BORDER_W + FEATURE_LEGEND_BOX_W + FEATURE_LEGEND_BOX_OFFSET;
    _item_legend_w = 100;

    _item_legend_origin[0] = 0;
    _item_legend_origin[1] = FEATURE_LEGEND_TEXT_OFFSET;
    _color_picker_origin[0] = _item_legend_origin[0] + FEATURE_LEGEND_BORDER_W;
    _color_picker_origin[1] = _item_legend_origin[1] + LEGEND_COLOR_PICKER_OFFSET;

    // set the color picker height and width (assume 1 row of color boxes and then test
    _color_picker_h = COLOR_PICKER_BOX_W + COLOR_PICKER_BUTTON_OFFSET + CLEAR_BUTTON_H;
    _color_picker_w = NUM_ITEM_COLORS*COLOR_PICKER_BOX_W + (NUM_ITEM_COLORS-1)*COLOR_PICKER_BOX_OFFSET;
    _color_picker_one_row = true;
    if ( _item_legend_w < _color_picker_w )
    {
      _color_picker_w -= ((NUM_ITEM_COLORS/2)*COLOR_PICKER_BOX_W + (NUM_ITEM_COLORS/2)*COLOR_PICKER_BOX_OFFSET);
      _color_picker_one_row = false;
      _color_picker_h += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET);
    }

    _item_legend_w = max( _item_legend_w, _color_picker_w );

    // compute the item legend height (which eventually may use the color picker info
    computeLegendParameters();

  }

  public String dataAttr() {
    return catAttr();
  }
  public ColorPickerLegendView dataAttr(String attr) {
    catAttr(attr);
    colorAttr(attr);
    return this;
  }

  void filterCatsUpdated() {
    computeLegendParameters();
  }

  void hoveredCatUpdated() {
    //_rolled_over_item = _hoverCat;
  }

  // this will need to be called when the number of visible items change
  void computeLegendParameters()
  {
    // count the number of visible item types
    int num_visible_items = _filterCats.length;

    // compute the item legend height
    _item_legend_h = 2*FEATURE_LEGEND_BORDER_W + num_visible_items*FEATURE_LEGEND_BOX_H +
      (num_visible_items-1)*FEATURE_LEGEND_BOX_OFFSET;

    _color_picker_origin[1] = _item_legend_origin[1] + _item_legend_h + LEGEND_COLOR_PICKER_OFFSET;
  }

  public void render() {
    //
    // render the color picker
    //
    pushMatrix();
    translate( _color_picker_origin[0], _color_picker_origin[1] );

    // render the color choices
    int x = 0;
    int y = 0;
    noStroke();

    for ( int i = 0; i < (NUM_ITEM_COLORS/2); i++ )
    { 
      fill( ITEM_COLOR[i] );
      rect( x, y, COLOR_PICKER_BOX_W, COLOR_PICKER_BOX_W );
      x += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    if ( !_color_picker_one_row )
    {
      x = 0;
      y += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    for ( int i = (NUM_ITEM_COLORS/2); i < NUM_ITEM_COLORS; i++ )
    { 
      fill( ITEM_COLOR[i] );
      rect( x, y, COLOR_PICKER_BOX_W, COLOR_PICKER_BOX_W );
      x += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    // render the clear button
    x = 0;
    y += (COLOR_PICKER_BOX_W + COLOR_PICKER_BUTTON_OFFSET );
    if ( !_clear_button_selected )
    {
      fill( COLOR_PICKER_BUTTON_FILL_COLOR );
      stroke( COLOR_PICKER_LINE_COLOR );
    }
    else
    {
      fill( COLOR_PICKER_BUTTON_SELECTED_FILL_COLOR );
      stroke( COLOR_PICKER_SELECTED_LINE_COLOR );
    }
    textFont( _pixel_font_8 );
    rect( x, y, textWidth("clear")+4, CLEAR_BUTTON_H );
    if ( !_clear_button_selected ) fill( COLOR_PICKER_BUTTON_TEXT_COLOR );
    else fill ( COLOR_PICKER_SELECTED_LINE_COLOR );
    textAlign( LEFT, CENTER );
    text( "clear", x+3, y+COLOR_PICKER_BOX_W/2-1 );

    popMatrix();

    //
    // render the item legend
    //
    pushMatrix();
    translate( _item_legend_origin[0], _item_legend_origin[1] );

    // render the item types
    x = FEATURE_LEGEND_BORDER_W;
    y = FEATURE_LEGEND_BORDER_W;

    String item;
    textAlign( LEFT, CENTER );
    strokeWeight( 1 );
    for ( int i = 0; i < _filterCats.length; i++ )
    {
      item = _filterCats[i];
      if ( _legend_item_color_selected && (_selected_legend_item_color == i) ) fill( DEFAULT_COLOR );
      else fill( _filterCatColors[i] );
      if ( _rolled_over_item.equals(item) || _hoverCat.equals(item) ) stroke( COLOR_PICKER_SELECTED_LINE_COLOR );
      else noStroke();
      rect( x, y, FEATURE_LEGEND_BOX_W, FEATURE_LEGEND_BOX_H );

      if ( _rolled_over_item.equals(item) || _hoverCat.equals(item) )
      {
        textFont( _pixel_font_8b );
        fill( COLOR_PICKER_SELECTED_LINE_COLOR );
      }
      else
      {
        textFont( _pixel_font_8 );
        fill( FEATURE_LEGEND_TEXT_COLOR );
      }
      text( item, x+FEATURE_LEGEND_BOX_OFFSET+FEATURE_LEGEND_BOX_W, y+FEATURE_LEGEND_BOX_H/2-2 );

      y += FEATURE_LEGEND_BOX_OFFSET+FEATURE_LEGEND_BOX_H;
    }
    popMatrix();

    //
    // render the selected color picker under the mouse
    //
    if ( _color_selected )
    {
      x = _mx + _color_selected_box_offset[0];
      y = _my + _color_selected_box_offset[1];
      stroke( COLOR_PICKER_SELECTED_LINE_COLOR );
      strokeWeight( 1 );
      fill( ITEM_COLOR[_selected_color] );
      rect( x, y, COLOR_PICKER_BOX_W, COLOR_PICKER_BOX_W );
    }
    else if ( _legend_item_color_selected )
    {
      x = _mx + _legend_item_color_box_offset[0];
      y = _my + _legend_item_color_box_offset[1];
      stroke( COLOR_PICKER_SELECTED_LINE_COLOR );
      strokeWeight( 1 );
      fill( _filterCatColors[_selected_legend_item_color] );
      rect( x, y, FEATURE_LEGEND_BOX_W, FEATURE_LEGEND_BOX_H );
    }

  }

  public void setup() {
    _w = 20;
    _h = 20;
  }

  boolean overItemLegend( int mx, int my )
  {
    int x, y;

    // check for rollover of the legend
    x = 0;
    y = FEATURE_LEGEND_BORDER_W;

    String item;
    for ( int i = 0; i < _filterCats.length; i++ )
    {
      item = _filterCats[i];

      if ( (mx >= x) && (mx <= x+_item_legend_w) && (my >= y) && (my <= y+FEATURE_LEGEND_BOX_H) )
      {
        hoverCat(item, false);
        hoveredCatUpdated();
        return true;
      }

      y += FEATURE_LEGEND_BOX_OFFSET+FEATURE_LEGEND_BOX_H;
    }
    hoverCat("", false);
    hoveredCatUpdated();

    return false;
  }

  boolean itemLegendPressed( int mx, int my, boolean rightPressed )
  {
    int x, y;

    // check for the item types color boxes being pressed
    x = FEATURE_LEGEND_BORDER_W;
    y = FEATURE_LEGEND_BORDER_W;

    String item;
    for ( int i = 0; i < _filterCats.length; i++ )
    {
      item = _filterCats[i];

      if ( (mx >= x) && (mx <= x+FEATURE_LEGEND_BOX_W) && (my >= y) && (my <= y+FEATURE_LEGEND_BOX_H) )
      {
        if ( _filterCatColors[i] == DEFAULT_COLOR ) return false;

        _legend_item_color_selected = true;
        _selected_legend_item_color = i;

        _legend_item_color_box[0] = x;
        _legend_item_color_box[1] = y;
        _legend_item_color_box_offset[0] = x - mx;
        _legend_item_color_box_offset[1] = y - my;

        return true;
      }

      y += FEATURE_LEGEND_BOX_OFFSET+FEATURE_LEGEND_BOX_H;
    }

    return false;
  }

  boolean colorPickerPressed( int mx, int my )
  {
    int x = 0;
    int y = 0;

    for ( int i = 0; i < (NUM_ITEM_COLORS/2); i++ )
    {
      if ( (my >= y) && (my <= y+COLOR_PICKER_BOX_W) && (mx >= x) && (mx <= x+COLOR_PICKER_BOX_W) )
      {
        _color_selected = true;
        _selected_color = i;

        _color_selected_box_offset[0] = x - mx;
        _color_selected_box_offset[1] = y - my;

        return true;
      }
      x += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    if ( !_color_picker_one_row )
    {
      x = 0;
      y += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    for ( int i = (NUM_ITEM_COLORS/2); i < NUM_ITEM_COLORS; i++ )
    {
      if ( (my >= y) && (my <= y+COLOR_PICKER_BOX_W) && (mx >= x) && (mx <= x+COLOR_PICKER_BOX_W) )
      {
        _color_selected = true;
        _selected_color = i;

        _color_selected_box_offset[0] = x - mx;
        _color_selected_box_offset[1] = y - my;

        return true;
      }
      x += (COLOR_PICKER_BOX_W + COLOR_PICKER_BOX_OFFSET );
    }

    // check if the clear button is pressed
    x = 0;
    y += (COLOR_PICKER_BOX_W + COLOR_PICKER_BUTTON_OFFSET );
    textFont( _pixel_font_8 );
    if ( (mx >= x) && (mx <= (x+textWidth("clear")+4)) && (my >= y) && (my <= y+COLOR_PICKER_BOX_W) )
    {
      _clear_button_selected = true;
      return true;
    }

    return false;
  }

  boolean colorReleasedOverItemLegend( int mx, int my, color c )
  {
    int x = FEATURE_LEGEND_BORDER_W;
    int y = FEATURE_LEGEND_BORDER_W;

    for ( int i = 0; i < _filterCats.length; i++ )
    {
      if ( (mx >= x) && (mx <= x+FEATURE_LEGEND_BOX_W) && (my >= y) && (my <= y+FEATURE_LEGEND_BOX_H) )
      {
        _filterCatColors[i] = c;
        coloredCat(_filterCats[i], c, false);
        return true;
      }

      y += FEATURE_LEGEND_BOX_OFFSET+FEATURE_LEGEND_BOX_H;
    }

    return false;
  }

  boolean legendItemColorReleased( int mx, int my )
  {
    // TODO sort out _selected_legend_item_color vs _selected_color
    // first check if we have dropped it over another legend box
    colorReleasedOverItemLegend( mx, my, _filterCatColors[_selected_legend_item_color] );

    int x_diff = abs( (mx+_legend_item_color_box_offset[0])-_legend_item_color_box[0] );
    int y_diff = abs( (my+_legend_item_color_box_offset[1])-_legend_item_color_box[1] );
    if ( (x_diff > FEATURE_LEGEND_BOX_W) || (y_diff > FEATURE_LEGEND_BOX_H) )
    {
      _filterCatColors[_selected_legend_item_color] = DEFAULT_COLOR;
      return true;
    }
    return false;
  }

  public void mouseOutOfView() {
    if (_item_rolled_over) {
      hoverCat("", false);
      hoveredCatUpdated();
    }
    _item_rolled_over = false;
    _rolled_over_item = "";
  }
  
  void mouseMovedInView( int mx, int my )
  {
    _item_rolled_over = false;
    _rolled_over_item = "";
    _mx = mx;
    _my = my;

    // TODO don't forget to handle dropbox in combination view
    if ( (mx >= _item_legend_origin[0]) && (mx <= _item_legend_origin[0]+_item_legend_w) &&
         (my >= _item_legend_origin[1]) && (my <= _item_legend_origin[1]+_item_legend_h) ) {
      overItemLegend( mx-_item_legend_origin[0], my-_item_legend_origin[1] );
    }
  }

  void mousePressedInView( int mx, int my, boolean rightPressed )
  {
    _mx = mx;
    _my = my;

    _color_selected = _legend_item_color_selected = _clear_button_selected = false;
    if ( (mx >= _item_legend_origin[0]) && (mx <= _item_legend_origin[0]+_item_legend_w) &&
         (my >= (_item_legend_origin[1]-FEATURE_LEGEND_TEXT_OFFSET)) &&
         (my <= _item_legend_origin[1]+_item_legend_h) ) {
      itemLegendPressed( mx-_item_legend_origin[0], my-_item_legend_origin[1], rightPressed );
    }

    else if ( (mx >= _color_picker_origin[0]) && (mx <= _color_picker_origin[0]+_color_picker_w) &&
              (my >= _color_picker_origin[1]) && (my <= _color_picker_origin[1]+_color_picker_h) ) {
      colorPickerPressed( mx-_color_picker_origin[0], my-_color_picker_origin[1] );
    }

  }

  void mouseReleasedInView( int mx, int my )
  {
    _mx = mx;
    _my = my;

    if ( _legend_item_color_selected ) {
      if (legendItemColorReleased( mx-_item_legend_origin[0], my-_item_legend_origin[1] )) {
        coloredCat(_filterCats[_selected_legend_item_color], _filterCatColors[_selected_legend_item_color], false);
      }
    }

    else if ( _clear_button_selected )
    {
      //clearColors();
      for ( int i = 0; i < _filterCats.length; i++ )
      {
        // TODO but we need to update _cat1Colors too
        // TODO really this color thing is hacky, we should be using the color map object instead
        _filterCatColors[i] = DEFAULT_COLOR;
        // TODO send just one notification or one per change?
        // TODO only notify if actually changed?
        coloredCat(_filterCats[i], DEFAULT_COLOR, false);
      }
    }

    else if ( (mx >= _item_legend_origin[0]) && (mx <= _item_legend_origin[0]+_item_legend_w) && 
    (my >= _item_legend_origin[1]) && (my <= _item_legend_origin[1]+_item_legend_h) ) {
      if ( _color_selected ) {
        colorReleasedOverItemLegend( mx-_item_legend_origin[0], my-_item_legend_origin[1], ITEM_COLOR[_selected_color] );
      }
    }
    _color_selected = _legend_item_color_selected = _clear_button_selected = false;

  }

  void mouseDraggedInView( int mx, int my )
  {
    _mx = mx;
    _my = my;
    _item_rolled_over = false;
    _rolled_over_item = "";
    if ( (mx >= _item_legend_origin[0]) && (mx <= _item_legend_origin[0]+_item_legend_w) &&
    (my >= _item_legend_origin[1]) && (my <= _item_legend_origin[1]+_item_legend_h) ) {
      overItemLegend( mx-_item_legend_origin[0], my-_item_legend_origin[1] );
    }
  }

}
