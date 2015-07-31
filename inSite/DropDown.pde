// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

///////////////////////////////////
//              View             //
///////////////////////////////////

public class DropDownView extends DelvCategoryView {
  boolean is_dropped_down;
  boolean dropdown_is_rolled_over; // hover
  boolean dropdown_is_highlighted; // highlighted
  boolean dropdown_is_pressed;
  int pressed_dropdown;
  int rolled_over_dropdown;
  boolean[] cats_selected;
  int dropdown_min_width;
  int dropbox_max_width;

  public DropDownView() {
    this("DropDown");
  }

  public DropDownView(String name) {
    super(name);
    is_dropped_down = false;
    dropdown_is_rolled_over = false;
    dropdown_is_highlighted = false;
    dropdown_is_pressed = false;
    pressed_dropdown = 0;
    rolled_over_dropdown = 0;
    cats_selected = new boolean[0];
    textFont( _verdana_font_12 );
    dropdown_min_width = (int)(textWidth(_label)) + DROP_DOWN_BOX_W + DROP_DOWN_BOX_OFFSET + 2 * DROPBOX_BORDER;
    dropbox_max_width = dropdown_min_width;
  }

  public boolean isDroppedDown() {
    return is_dropped_down;
  }

  public void labelUpdated() {
    dropdown_min_width = (int)(textWidth(_label)) + DROP_DOWN_BOX_W + DROP_DOWN_BOX_OFFSET + 2 * DROPBOX_BORDER;
  }

  public void cat1Updated() {
    cats_selected = new boolean[_cat1.length];
    dropbox_max_width = 0;
    int pad = 10;
    textFont( _pixel_font_8b );
    for (int i = 0; i < _cat1.length; ++i) {
      cats_selected[i] = true;
      dropbox_max_width = max( dropbox_max_width, (int)(textWidth( _cat1[i] )) + DROPBOX_RADIO_BUTTON_W+DROPBOX_RADIO_BUTTON_OFFSET + pad);
    }
    resize();
  }

  public void visibleCat1Updated() {
    for (int i = 0; i < _cat1.length; ++i) {
      cats_selected[i] = false;
      for (int j = 0; j < _visibleCat1.length; ++j) {
        if (_visibleCat1[j].equals(_cat1[i])) {
          cats_selected[i] = true;
        }
      }
    }
  }

  public void render() {
    int x = DROPBOX_BORDER + DROP_DOWN_BOX_W + DROP_DOWN_BOX_OFFSET;
    int y = DROPBOX_BORDER;

    strokeWeight( SCALE_BAR_LINE_WEIGHT );
    stroke( SCALE_BAR_COLOR );
    textFont( _verdana_font_12 );
    textAlign( LEFT, TOP );
    fill( LABEL_COLOR );
    text( _label, x, y-4 );

    x = DROPBOX_BORDER;
    noStroke();
    fill( DROP_DOWN_FILL_COLOR );
    if ( !is_dropped_down ) {
      triangle( x+DROP_DOWN_BOX_W/2, y+DROP_DOWN_BOX_W, x+DROP_DOWN_BOX_W, y, x, y );
    }
    else
    {
      triangle( x, y+DROP_DOWN_BOX_W, x+DROP_DOWN_BOX_W, y+DROP_DOWN_BOX_W, x+DROP_DOWN_BOX_W/2, y );

      // render the drop down box
      // TODO standardize naming drop down vs drop box
      x = DROPBOX_BORDER;
      y = DROPBOX_BORDER + DROP_DOWN_BOX_W + DROPBOX_LINE_OFFSET;
      fill( DROPBOX_FILL_COLOR );
      stroke( DROPBOX_LINE_COLOR );
      strokeWeight( 1 );
      rect( x, y, _w - 2 * DROPBOX_BORDER, _cat1.length*(DROPBOX_LINE_H+DROPBOX_LINE_OFFSET) + DROPBOX_LINE_OFFSET);

      x += DROPBOX_BORDER;
      y += DROPBOX_BORDER + DROPBOX_LINE_H;
      textAlign( LEFT, BOTTOM );
      fill( DROPBOX_TEXT_COLOR );
      stroke( DROPBOX_TEXT_COLOR );
      for ( int i = 0; i < _cat1.length; i++ )
      {
        String choice = _cat1[i];

        // TODO need to be able to respond to highlights and hovers initialized by other views
        if ( dropdown_is_highlighted && (pressed_dropdown == i) )
        {
          fill( HIGHLIGHTED_COLOR );
          stroke( HIGHLIGHTED_COLOR );
        }
        else
        {
          fill( DROPBOX_TEXT_COLOR );
          stroke( DROPBOX_TEXT_COLOR );
        }

        if ( dropdown_is_rolled_over && (rolled_over_dropdown == i) )
        {
          textFont( _pixel_font_8b );
          strokeWeight( 2 );
        }
        else
        {
          textFont( _pixel_font_8 );
          strokeWeight( 1 );
        }
        text( choice, x+DROPBOX_RADIO_BUTTON_W+DROPBOX_RADIO_BUTTON_OFFSET, y+2 );

        if ( cats_selected[i] )
        {
          // TODO avoid these calls to smooth/noSmooth?
          // Right now, the fonts don't work in Java applet w/ opengl renderer unless smooth/nosmooth is called
          // so much that smoothing is disabled
          smooth();
          line( x+DROPBOX_RADIO_BUTTON_W/4, y-DROPBOX_RADIO_BUTTON_W/2, x+DROPBOX_RADIO_BUTTON_W/2, y );
          line( x+DROPBOX_RADIO_BUTTON_W/2, y, x+DROPBOX_RADIO_BUTTON_W, y-DROPBOX_RADIO_BUTTON_W );
          noSmooth();
        }

        y += DROPBOX_LINE_H + DROPBOX_LINE_OFFSET;
      }
    }
  }

  int getChoiceUnderMouse(int mx, int my) {
    // return -1 if no choice is under mouse
    int selection = -1;
    int x = DROPBOX_BORDER;
    int y = 2 * DROPBOX_BORDER + DROP_DOWN_BOX_W + DROPBOX_LINE_OFFSET;
    if (is_dropped_down && (mx >= x) && (mx <= _w - DROPBOX_BORDER))
    {
      // we're over the box from a width perspective
      // now see which selection inside the box (y direction) we're over
      for ( int i = 0; i < _cat1.length; i++ )
      {
        if ( (my >= y) && (my <= y+DROPBOX_LINE_H+DROPBOX_LINE_OFFSET) )
        {
          selection = i;
        }
        y += DROPBOX_LINE_H + DROPBOX_LINE_OFFSET;
      }
    }
    return selection;
  }

  public void mouseOutOfView() {
    dropdown_is_rolled_over = false;
  }

  public void mouseMovedInView( int mx, int my ) {
    dropdown_is_rolled_over = false;
    String hover_id = "";
    int selection = getChoiceUnderMouse(mx, my);
    if (selection >= 0)
    {
      rolled_over_dropdown = selection;
      dropdown_is_rolled_over = true;
      hover_id = _cat1[rolled_over_dropdown];
    }
    hoveredCat(hover_id);
  }

  public void mousePressedInView( int mx, int my, boolean rightPressed )
  {
    boolean dropdown_is_toggled = false;
    dropdown_is_pressed = false;

    int x, y;

    // check if the regions dropdown is pressed
    x = DROPBOX_BORDER;
    y = DROPBOX_BORDER;

    if ( (mx >= x) && (mx <= x + DROP_DOWN_BOX_W) && (my >= y) && (my <= y + DROP_DOWN_BOX_W) )
    {
      dropdown_is_toggled = true;
    }
    else
    {
      int selection = getChoiceUnderMouse(mx, my);
      if (selection >= 0)
      {
        if ( !rightPressed )
        {
          dropdown_is_pressed = true;
        }
        else
        {
          if (pressed_dropdown == selection)
            dropdown_is_highlighted = !dropdown_is_highlighted;
          else
            dropdown_is_highlighted = true;
        }
        pressed_dropdown = selection;
      }
    }

    if (dropdown_is_toggled) {
      is_dropped_down = !is_dropped_down;
    }
    draw();
  }

  public void resize() {
    resize(_w, _h, false);
  }

  public void resize(int w, int h, boolean doDraw) {
    if (dropbox_max_width <= dropdown_min_width) {
      w = dropdown_min_width;
    } else {
      w = dropbox_max_width + 2 * DROPBOX_BORDER;
    }
    h = 2 * (2*DROPBOX_BORDER + (_cat1.length)*(DROPBOX_LINE_H+DROPBOX_LINE_OFFSET));
    super.resize(w, h, doDraw);
  }

  public void mouseReleasedInView(int mx, int my) {
    if (dropdown_is_pressed) {
      cats_selected[pressed_dropdown] = ! cats_selected[pressed_dropdown];
      selectedCat(_cat1[pressed_dropdown]);
    } else {
      if (dropdown_is_highlighted) {
        highlightedCat(_cat1[pressed_dropdown]);
      }
      else
      {
        highlightedCat("");
      }
    }
    dropdown_is_pressed = false;
    draw();
  }

}
