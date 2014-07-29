// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

// AlignmentView is used to select between left, center, right, and stretch
// alignment.  It will emit an alignmentChanged signal, thus it probably only makes
// sense to have one Alignment per application.

class AlignmentView extends DelvBasicView {
  int _alignment_selector_w;
  int _alignment_selector_h;
  String[] _alignment_choices;
  String _selected_alignment;
  boolean _alignment_selected;
  int[] _alignment_selector_line_w;
  int _max_alignment_selector_line_w;

  AlignmentView() {
    this("Alignment");
  }

  AlignmentView(String name) {
    super(name);

    _alignment_choices = new String[4];
    _alignment_choices[0] = "left";
    _alignment_choices[1] = "center";
    _alignment_choices[2] = "right";
    _alignment_choices[3] = "stretch";

    _selected_alignment = _alignment_choices[0];
    _alignment_selector_line_w = new int[5];
    _alignment_selector_line_w[0] = _alignment_selector_line_w[4] = 10;
    _alignment_selector_line_w[1] = _alignment_selector_line_w[3] = 6;
    _alignment_selector_line_w[2] = 8;
    _max_alignment_selector_line_w = 10;
    _alignment_selector_w = 4*ALIGNMENT_SELECTOR_BOX_W;
    _alignment_selector_h = ALIGNMENT_SELECTOR_BOX_W;

  }

  // TODO we have to override the following because we aren't displaying data, thus we may need to break DelvBasicView into an even more basic data attr less view first
  void updateSelections() {}

  void alignmentChanged(String alignment) {
    if (!alignment.equals("")) {
      // an example of how to emit a custom signal to other delv views
      _delvIF.emitSignal("alignmentChanged", _name, "", alignment);
    }
  }

  void render() {
    int x, y;
    x = 0;
    y = 15; // to compensate for height of "justify"

    stroke( REGION_LINE_COLOR );
    strokeWeight( 1 );
    line( x, y-5, x+_alignment_selector_w, y-5 );
    fill( REGION_LINE_COLOR );
    textFont( _pixel_font_8 );
    textAlign( RIGHT, BOTTOM );
    text( "justify", x+_alignment_selector_w, y-7 );

    for ( int i = 0; i < _alignment_choices.length; i++ )
    {
      renderAnAlignmentSelector( i, x, y );
      x += ALIGNMENT_SELECTOR_BOX_W;
    }
  }

  void renderAnAlignmentSelector( int alignment, int x, int y )
  {
    strokeWeight(1);
    stroke( ALIGNMENT_SELECTOR_LINE_COLOR );
    if ( _selected_alignment.equals(_alignment_choices[alignment]) ) fill( ALIGNMENT_SELECTOR_SELECTED_FILL_COLOR );
    else fill( ALIGNMENT_SELECTOR_FILL_COLOR );
    rect( x, y, ALIGNMENT_SELECTOR_BOX_W, ALIGNMENT_SELECTOR_BOX_W );

    y += (ALIGNMENT_SELECTOR_BOX_W - 12)/2;

    switch( alignment )
    {
    case 0: // left
      x += (ALIGNMENT_SELECTOR_BOX_W - _max_alignment_selector_line_w)/2;
      for ( int i = 0; i < 5; i++ )
      {
        line( x, y, x+_alignment_selector_line_w[i], y );
        y += 3;
      }
      break;

    case 1: // center
      x += (ALIGNMENT_SELECTOR_BOX_W - _max_alignment_selector_line_w)/2 + _max_alignment_selector_line_w/2;
      for ( int i = 0; i < 5; i++ )
      {
        line( x-_alignment_selector_line_w[i]/2, y, x+_alignment_selector_line_w[i]/2, y );
        y += 3;
      }
      break;

    case 2: // right
      x += (ALIGNMENT_SELECTOR_BOX_W - _max_alignment_selector_line_w)/2 + _max_alignment_selector_line_w;
      for ( int i = 0; i < 5; i++ )
      {
        line( x, y, x-_alignment_selector_line_w[i], y );
        y += 3;
      }
      break;

    case 3: // stretch
      x += (ALIGNMENT_SELECTOR_BOX_W - _max_alignment_selector_line_w)/2;
      for ( int i = 0; i < 5; i++ )
      {
        line( x, y, x+_max_alignment_selector_line_w, y );
        y += 3;
      }
      break;
    }
  }

  void mousePressedInView( int mx, int my, boolean rightPressed )
  {
    _alignment_selected = false;
    // check if we are in the alignment selector region
    if ( (mx >= 0) && (mx <= _alignment_selector_w) &&
         (my >= 0) && (my <= _alignment_selector_h) ) {
      _alignment_selected = overAlignmentSelector( mx, my );
    }
  }

  boolean overAlignmentSelector( int mx, int my )
  {
    int x = ALIGNMENT_SELECTOR_BOX_W;
    for ( int i = 0; i < _alignment_choices.length; i++ )
    {
      if ( mx <= x )
      {
        _selected_alignment = _alignment_choices[i];
        return true;
      }
      x += ALIGNMENT_SELECTOR_BOX_W;
    }
    return false;
  }

  void mouseReleasedInView(int mx, int my) {
    if (_alignment_selected) {
      alignmentChanged(_selected_alignment);
      draw();
    }
    _alignment_selected = false;
  }

}
