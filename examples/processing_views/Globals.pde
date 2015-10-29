/* @pjs font="./data/pf_tempesta_seven.ttf"; */
/* @pjs font="./data/pf_tempesta_seven_bold.ttf"; */
/* @pjs font="Verdana.ttf"; */
// TODO figure out how to handle font paths for Processing and Javascript
///* @pjs font="./snapvis_views/Processing/data/pf_tempesta_seven.ttf"; */
///* @pjs font="./snapvis_views/Processing/data/pf_tempesta_seven_bold.ttf"; */

// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

// General triangle button draw function
void drawTriangle(int x, int y, boolean drop_down){
    noStroke();
    fill( DROP_DOWN_FILL_COLOR );
    if ( drop_down ) 

	// point up
	triangle( x+DROP_DOWN_BOX_W/2, y, x+DROP_DOWN_BOX_W, y+DROP_DOWN_BOX_W, x, y+DROP_DOWN_BOX_W );
    
    // side triangle
    //triangle( x, y, x+DROP_DOWN_BOX_W, y, x+DROP_DOWN_BOX_W/2, y+DROP_DOWN_BOX_W );	
    else 	
	// point down
	triangle( x, y, x+DROP_DOWN_BOX_W, y, x+DROP_DOWN_BOX_W/2, y+DROP_DOWN_BOX_W);

}

// Converts time point in 24 hours (ie 23:23) to minutes in the day
long convertTimeToMinutes(String time){    
    return Long.parseLong(time.split(":")[0].trim())*60 + Long.parseLong(time.split(":")[1].trim());
}

DelvView _view;

// Other variables
public static long _max_region_length;
public static String _region_length_unit;
public static int _scroll_start_y = 0;
//public static int _scroll_max_y;
public static boolean _scroll = false;
public static int _render_region_height;

// Fonts
// TODO these font names aren't great, change when eliminating Globals.pde
public final PFont _pixel_font_8 = createFont( "PFTempestaSeven", 9, false );
public final PFont _pixel_font_8b = createFont( "PFTempestaSeven-Bold", 10, false );
public final PFont _verdana_font_12 = createFont( "Verdana", 12, true );
public final PFont _verdana_font_16 = createFont( "Verdana", 16, true );
public final PFont _verdana_font_30 = createFont( "Verdana", 30, true );
public static final int _pixel_font_8_height = 8;
public static final int _verdana_font_12_height = 12;

// Flags
public static int _region_alignment;
public static boolean _show_bar_heights;
public static boolean _render_cutoff_box = true;
public static boolean _clear_button_selected;
public static boolean _draw_color_legend_highlight;

//
// COLORS
//
public final color BACKGROUND_COLOR = color_( 255 );
public final color DEFAULT_COLOR = color_( 210 );
public final color LABEL_COLOR = color_( 100 )/*#1F78B4*/;
public final color HIGHLIGHT_LABEL_COLOR = color_(25, 250, 250);
public final color SELECT_LABEL_COLOR = color_(185, 2, 17);
public final color BARHEIGHT_SELECT_COLOR = color_(193, 8, 8);
public final color REGION_LINE_COLOR = color_( 100 );
public final color[] REGION_MAX_VALUE_BAND_COLORS = { color_(235), color_(235) };
public final color REGION_MAX_VALUE_LINE_COLOR = color_( 235 );
public final color REGION_HALF_VALUE_LINE_COLOR = color_( 255 );
public final color SCALE_BAR_COLOR = color_( 100 );

public final color FEATURE_DEFAULT_COLOR = color_( 210 );
public final color FEATURE_CLEAR_COLOR = color_( 1 );
public final color[] FEATURE_COLORS = { #1F78B4,   // blue
                                        #33A02C,   // green
                                        #E31A1C,   // red
                                        #FF7F00,   // orange
                                        #6A3D9A,   // purple
					FEATURE_DEFAULT_COLOR, // clear old color
                                        #A6CEE3,   // lt blue
                                        #B2DF8A,   // lt green
                                        #FB9A99,   // lt red
                                        #FDBF6F,   // lt orange
                                        #CAB2D6,   // lt purple
					FEATURE_CLEAR_COLOR};  // clear all colors

public final color FEATURE_HIGHLIGHT_COLOR = color_(100);
public final color CONDITIONING_LINE_COLOR = color_( 100 );

public final color ALIGNMENT_SELECTOR_LINE_COLOR = color_( 100 );
public final color ALIGNMENT_SELECTOR_FILL_COLOR = color_( 255 );
public final color ALIGNMENT_SELECTOR_SELECTED_FILL_COLOR = color_( 220 );

public final color SCROLLBAR_LINE_COLOR = color_(192);
public final color SCROLLBAR_FILL_COLOR = color_(150);

public final color DROP_DOWN_FILL_COLOR = color_( 100 )/*#A6CEE3*/;
public final color DROP_DOWN_PRESSED_LINE_COLOR = #1F78B4;
public final color DROPBOX_FILL_COLOR = color_( 255 );
public final color DROPBOX_LINE_COLOR = color_( 100 )/*#1F78B4*/;
public final color DROPBOX_TEXT_COLOR = color_( 100 )/*#1F78B4*/;

public final color COLOR_PICKER_BUTTON_FILL_COLOR = color_( 255 );
public final color COLOR_PICKER_BUTTON_SELECTED_FILL_COLOR = color_( 220 );
public final color COLOR_PICKER_LINE_COLOR = color_( 100 );
public final color COLOR_PICKER_BUTTON_TEXT_COLOR = color_( 100 );
public final color COLOR_PICKER_SELECTED_LINE_COLOR = color_( 0 );
public final color HIGHLIGHTED_COLOR = #E31A1C;
public final color SPATIAL_BOX_COLOR = color_( 215 );
 
public final color STRIKE_THROUGH_COLOR = color_(196,47,47);
//
// SIZES
//
public static final int WINDOW_BORDER_WIDTH = 30;

public static final int REGION_HEIGHT = 40;
public static final int REGION_MIN_HEIGHT = 10;

public static final int REGION_OFFSET = 10;
public static final int GROUP_OFFSET = 15;
public static final int REGION_LINE_WEIGHT = 1;
public static final int SCALE_BAR_OFFSET = 15;
public static final int SCALE_BAR_H = 9;
public static final int SCALE_BAR_LINE_WEIGHT = 1;

public static final int CONDITIONING_VIEW_REGION_VIEW_OFFSET = 4;

public static final int CONDITIONING_NODE_WIDTH = 20;
public static final int CONDITIONING_LEVEL_OFFSET = 25;
public static final int CONDITIONING_LINE_WEIGHT = 1;
public static final int CONDITIONING_LINE_WEIGHT_BOLD = 2;

public static final int ALIGNMENT_SELECTOR_BOX_W = 20;
public static final int ALIGNMENT_SELECTOR_OFFSET = 20;

public static final int SCROLLBAR_LINE_WEIGHT = 1;
public static final int LEGEND_COLOR_PICKER_OFFSET = 10;

public static final int FEATURE_LEGEND_BOX_OFFSET = 5;
public static final int FEATURE_LEGEND_BORDER_W = 10;
public static final int FEATURE_LEGEND_BOX_W = 20;
public static final int FEATURE_LEGEND_BOX_H = 10;
public static final int FEATURE_LEGEND_TEXT_OFFSET = 16;
public static final int FEATURE_LEGEND_OFFSET = 40;

public static final int COLOR_PICKER_BOX_W = 10;
public static final int COLOR_PICKER_BOX_OFFSET = 3;
public static final int COLOR_PICKER_BUTTON_OFFSET = 10;
public static final int CLEAR_BUTTON_H = 12;

public static final int DROP_DOWN_BOX_W = 8;
public static final int DROP_DOWN_BOX_OFFSET = 4;
public static final int DROPBOX_BORDER = 5;
public static final int DROPBOX_LINE_H = 8;
public static final int DROPBOX_LINE_OFFSET = 6;
public static final int DROPBOX_RADIO_BUTTON_W = 6;
public static final int DROPBOX_RADIO_BUTTON_OFFSET = 4;

public static final int LEGEND_WIDTH = 100+DROP_DOWN_BOX_W;

public static final int SCROLL_WIDTH = 25;

public static final int SPATIAL_BOX_W = 20;
public static final int SPATIAL_BOX_H = 12;

//
// ENUMERATIONS
//
public static final int REGION_ALIGNMENT_LEFT = 0;
public static final int REGION_ALIGNMENT_CENTER = 1;
public static final int REGION_ALIGNMENT_RIGHT = 2;
public static final int REGION_ALIGNMENT_STRETCH = 3;

public static final int MOUSE_MOVED    = 17;
public static final int MOUSE_PRESSED  = 18;
public static final int MOUSE_RELEASED = 19;
public static final int MOUSE_DRAGGED  = 20;

public static final int TEXT_OFFSET = 3;

// ABOVE are from Kristi's version of InSite

// 
// KMZ HARD-CODED HACKS
//
public static final int NUM_COND_VARS = 1;
public final color DEBUG_COLOR = color_(193, 8, 8);

// BELOW are from Miriah's version of InSite
public float _global_min_v = 0.0;
public String _region_label, _type_label;
public static final int REGION_TAG_OFFSET = 4;
public static final int FEATURE_ABOVE_HEIGHT = 30;
public final color REGION_TAG_TEXT_COLOR = color_( 100 );
public final color FEATURE_OUTLINE_COLOR = REGION_MAX_VALUE_BAND_COLORS[0];
public static final int FEATURE_MIN_WIDTH = 2;
public final color ROLLED_OVER_FEATURE_LINE_COLOR = color_( 0 );
public static final int ROLLED_OVER_FEATURE_LINE_WEIGHT = 1;
public final color FEATURE_LINE_COLOR = color_( 175 );
public static final int FEATURE_LINE_WEIGHT = 1;
public static final int FEATURE_BELOW_HEIGHT = 8;
public final color ROLL_OVER_TEXT_BOX_COLOR = color_( 255, 170 );
public final color ROLL_OVER_TEXT_BOX_TEXT_COLOR = color_( ROLLED_OVER_FEATURE_LINE_COLOR );
public static long _regions_max_len;
public static final int REGION_TAG_VERT_OFFSET = 6;
public final color REGION_VIEW_OUTLINE_COLOR = color_( 220 );
public final color SCROLL_BAR_HIGHLIGHT_COLOR = color_( 0 );
public static final int REGION_SCROLLBAR_OFFSET = 20;
public static final int REGION_SCROLLBAR_W = 8;

public final color FEATURE_LEGEND_LINE_COLOR = color_( 200 );
public final color FEATURE_LEGEND_TEXT_COLOR = color_( 100 );
public final color FEATURE_LEGEND_BOX_LINE_COLOR = color_( 170 );

public final color[] ITEM_COLOR = { #1F78B4,
                                    #33A02C,
                                    #E31A1C,
                                    #FF7F00,
                                    #6A3D9A,
                                    #A6CEE3,
                                    #B2DF8A,
                                    #FB9A99,
                                    #FDBF6F,
                                    #CAB2D6 };
public final int NUM_ITEM_COLORS = ITEM_COLOR.length;

