// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

interface DelvColorMap {

  // TODO for now only assume RGB tuple, and work on defining interface needs later

  color getColor(String value);

  // TODO somewhat dangerous, decide if this method is even necessary
  // void setMap(DelvColorMap colorMap);

  void setColor(String value, color c);

  void setDefaultColor(color c);

  void drawToFile(String filename);
} // end interface ColorMap

class DelvDiscreteColorMap implements DelvColorMap {
  color _defaultColor;
  HashMap<String, Integer> _colors;

  DelvDiscreteColorMap() {
    this( color( 220, 220, 220 ) );
  }

  DelvDiscreteColorMap(color default_color) {
    _defaultColor = default_color;
    _colors = new HashMap<String, Integer>();
  }

  color getColor(String value) {
    if (_colors.containsKey(value)) {
      return _colors.get(value);
    } else {
      return _defaultColor;
    }
  }

  // void setMap(DelvColorMap colorMap);

  void setColor(String value, color c) {
    // sets color map for entry value to color color
    // overrides existing color if that value already exists
    _colors.put(value, c);
  }

  void setDefaultColor(color c) {
    _defaultColor = c;
  }

  // way to visualize color map
  void drawToFile(String filename) {
    background(255,255,255);
    //size(_colors.size() * 50, 50);
    noStroke();
    int i = 0;
    for (color c : _colors.values()) {
      fill(red(c),green(c),blue(c));
      rect(i * 50, 0, 50, 50);
      i++;
    }
    save(filename);
  }
} // end class DelvDiscreteColorMap


  class HalfOpenRange {
    float _lower;
    float _upper;
    boolean _hasLower;
    boolean _hasUpper;

    // implements a half-open range [lower, upper)
    // TODO be sure to enforce condition that both lb and ub can't be None for the same entry
    HalfOpenRange() {
      _lower = 0;
      _upper = 1;
      _hasLower = false;
      _hasUpper = false;
    }

    void setLower(float val) {
      _hasLower = true;
      _lower = val;
    }
    void setUpper(float val) {
      _hasUpper = true;
      _upper = val;
    }

    boolean overlapped(HalfOpenRange other) {
      boolean status = false;
      if ((other._hasLower && this.contains(other._lower)) || (other._hasUpper && this.contains(other._upper))) {
        status = true;
      }
      return status;
    }

    boolean contains(float value) {
      boolean status = false;
      // TODO python version had this wrapped in an if value != None check.  Is that necessary still?
      if (!_hasLower && value < _upper) {
            status = true;
      } else if (!_hasUpper && value >= _lower) {
        status = true;
      } else if (_lower <= value && value < _upper) {
        status = true;
      }
      return status;
    }
  } // end class HalfOpenRange

class DelvContinuousColorMap implements DelvColorMap {
  ArrayList<HalfOpenRange> _bounds;
  ArrayList<DelvColorFun> _colors;
  color _defaultColor;

  DelvContinuousColorMap() {
    this( color( 220 ) );
  }

  DelvContinuousColorMap(color default_color) {
    _defaultColor = default_color;
    _bounds = new ArrayList<HalfOpenRange>();
    _colors = new ArrayList<DelvColorFun>();
  }

  color getColor(String value) {
    int idx = -1;
    float val = parseFloat(value);
    for (int i = 0; i < _bounds.size(); i++) {
      if (_bounds.get(i).contains(val)) {
        idx = i;
        break;
      }
    }
    if (idx < 0) {
      return _defaultColor;
    } else {
      DelvColorFun colorfun = _colors.get(idx);
      if (colorfun != null) {
        HalfOpenRange bound = _bounds.get(idx);
        float lb = bound._lower;
        float ub = bound._upper;
        float relval = 0;
        // TODO how to handle case when _hasUpper or _hasLower is false
        if (!bound._hasLower) {
          relval = (Float)(val) / ub;
        } else if (!bound._hasUpper) {
          relval = 1 - (lb / (Float)(val));
        } else {
          relval = ((Float)(val) - lb) / (ub - lb);
        }
        return colorfun.getColor((Float)(relval));
      } else {
        return _defaultColor;
      }
    }
  }

  // TODO somewhat dangerous, decide if this method is even necessary
  // void setMap(DelvColorMap colorMap);

  void setColor(String value, color c) {
  // not provided
  }

  void setColor(HalfOpenRange contRange, DelvColorFun colorfun) {
    // if the input range overlaps an existing range, the new input range takes precedence
    int numBounds = _bounds.size();
    int insertLoc;

    if (!contRange._hasLower) {
      insertLoc = 0;
    } else {
      insertLoc = numBounds;
      for (int i = 0; i < numBounds; i++) {
        if (_bounds.get(i)._lower == contRange._lower) {
          insertLoc = i;
          break;
        } else if (contRange._lower < _bounds.get(i)._lower) {
          insertLoc = i;
          break;
        }
      }
    }

    if (insertLoc == numBounds) {
      _bounds.add(contRange);
      _colors.add(colorfun);
      return;
    }

    int finalLoc;
    if (!contRange._hasUpper) {
      finalLoc = numBounds-1;
    } else {
      finalLoc = 0;
      for (int i = 0; i < numBounds; i++) {
        if (_bounds.get(i)._upper == contRange._upper) {
          finalLoc = i+1;
          break;
        } else if (_bounds.get(i)._upper > contRange._upper) {
          finalLoc = i-1;
          break;
        }
      }
    }

    if (insertLoc < finalLoc) {
      ArrayList<HalfOpenRange> newBounds = new ArrayList<HalfOpenRange>(_bounds.subList(0,insertLoc));
      newBounds.addAll(_bounds.subList(finalLoc,_bounds.size()));
      _bounds = newBounds;

      ArrayList<DelvColorFun> newColors = new ArrayList<DelvColorFun>(_colors.subList(0,insertLoc));
      newColors.addAll(_colors.subList(finalLoc,_colors.size()));
      _colors = newColors;
    }
    if (insertLoc > 0) {
      if (_bounds.get(insertLoc-1)._upper > contRange._lower) {
        _bounds.get(insertLoc-1)._upper = contRange._lower;
      }
    }
    if (insertLoc + 1 < _bounds.size()) {
      if (_bounds.get(insertLoc+1)._lower < contRange._upper) {
        _bounds.get(insertLoc+1)._lower = contRange._upper;
      }
    }
    _bounds.add(insertLoc, contRange);
    _colors.add(insertLoc, colorfun);
  }

  void setDefaultColor(color c) {
    _defaultColor = c;
  }

  void drawToFile(String filename) {
    if (_bounds.size() == 0) {
      return;
    }
    int numsamp = 1000;
    int numbounds = _bounds.size();
    int numsampperbound = numsamp / numbounds;
    numsamp = numsampperbound * numbounds;
    ArrayList<Float> samps = new ArrayList<Float>();

    float lb;
    float ub;
    HalfOpenRange b = _bounds.get(0);
    if (!b._hasLower) {
      lb = b._upper / 10;
    } else {
      lb = b._lower;
    }

    b = _bounds.get(numbounds - 1);
    if (!b._hasUpper) {
      ub = b._lower * 10;
    } else {
      ub = b._upper;
    }

    for (int i = 0; i < numsamp; i++) {
      samps.add(lb + i * (ub-lb) / numsamp);
    }

    background(255,255,255);
    //size(numsamp, 50);
    noStroke();
    int i = 0;
    for (Float val : samps) {
      color c = getColor(""+val);
      fill(red(c),green(c),blue(c));
      rect(i * 50, 0, 50, 50);
      i++;
    }
    save(filename);
  }


} //end class DelvContinuousColorMap

// some helper color utilities
float interp1(float start, float end, float value, float maximum) {
  return start + (end - start) * value / maximum;
}

float[] interp3(float[] start, float[] end, float value, float maximum) {
  float[] r = new float[3];
  r[0] = interp1(start[0], end[0], value, maximum);
  r[1] = interp1(start[1], end[1], value, maximum);
  r[2] = interp1(start[2], end[2], value, maximum);
  return r;
}

float[] rgb2hsv(float r, float g, float b) {
  // takes r, g, b in range 0 to 1
  // returns hsv in range 0 to 1
  float minrgb = Math.min( r, Math.min(g, b) );
  float maxrgb = Math.max( r, Math.max(g, b) );
  float diff = maxrgb - minrgb;

  float[] hsv = new float[3];
  hsv[2] = maxrgb;

  if ( diff == 0 ) {
    // grayscale
    hsv[0] = 0;
    hsv[1] = 0;
  } else {
    // has color
    hsv[1] = diff / maxrgb;

    float diffR = ( ( ( maxrgb - r ) / 6 ) + ( diff / 2 ) ) / diff;
    float diffG = ( ( ( maxrgb - g ) / 6 ) + ( diff / 2 ) ) / diff;
    float diffB = ( ( ( maxrgb - b ) / 6 ) + ( diff / 2 ) ) / diff;

    if      ( r == maxrgb ) { hsv[0] = diffB - diffG; }
    else if ( g == maxrgb ) { hsv[0] = ( 1 / 3 ) + diffR - diffB; }
    else if ( b == maxrgb ) { hsv[0] = ( 2 / 3 ) + diffG - diffR; }

    if ( hsv[0] < 0 ) { hsv[0] += 1; }
    if ( hsv[0] > 1 ) { hsv[0] -= 1; }
  }
  return hsv;
}

float[] hsv2rgb(float h, float s, float v) {
  // takes h, s, v from range 0 to 1
  // returns rgb in range 0 to 1
  float[] rgb = new float[3];
  if ( s == 0 ) {
    rgb[0] = v;
    rgb[1] = v;
    rgb[2] = v;
  } else {
    float scaleH;
    float i;
    float p;
    float q;
    float t;
    scaleH = h * 6;
    if ( scaleH == 6 ) {
      //scaleH must be < 1
      scaleH = 0;
    }
    i = (float) Math.floor( scaleH );             //Or ... var_i = floor( var_h )
    p = v * ( 1 - s );
    q = v * ( 1 - s * ( scaleH - i ) );
    t = v * ( 1 - s * ( 1 - ( scaleH - i ) ) );

    if      ( i == 0 ) { rgb[0] = v ; rgb[1] = t ; rgb[2] = p; }
    else if ( i == 1 ) { rgb[0] = q ; rgb[1] = v ; rgb[2] = p; }
    else if ( i == 2 ) { rgb[0] = p ; rgb[1] = v ; rgb[2] = t; }
    else if ( i == 3 ) { rgb[0] = p ; rgb[1] = q ; rgb[2] = v; }
    else if ( i == 4 ) { rgb[0] = t ; rgb[1] = p ; rgb[2] = v; }
    else               { rgb[0] = v ; rgb[1] = p ; rgb[2] = q; }
  }
  return rgb;
}

color lerp(color start, color end, float value) {
  // assumes inputs are RGB arrays
  // use algorithm from http://stackoverflow.com/questions/168838/color-scaling-function
  // convert everything to HSV
  // interpolate
  // convert back to RGB
  float[] start_hsv = rgb2hsv(red(start)/255.0,green(start)/255.0,blue(start)/255.0);
  float[] end_hsv = rgb2hsv(red(end)/255.0,green(end)/255.0,blue(end)/255.0);
  float[] interp_hsv = interp3(start_hsv, end_hsv, value, 1);
  float[] interp_rgb = hsv2rgb(interp_hsv[0], interp_hsv[1], interp_hsv[2]);
  color rgb = color( Math.round(interp_rgb[0] * 255),
                     Math.round(interp_rgb[1] * 255),
                     Math.round(interp_rgb[2] * 255) );
  return rgb;
}

// TODO create some default color functions here
// Note:  color functions assume that value will be in the range [0,1]
// This is done in order to work with the ContinuousColorMap concept above

interface DelvColorFun {
  color getColor(float value);
}

class green_scale implements DelvColorFun {
  color getColor(float value) {
    return lerp(color(0,0,0), color(0,255,0), value);
  }
}

class green_to_red implements DelvColorFun {
  color getColor(float value) {
    return lerp(color(0,255,0), color(255,0,0), value);
  }
}

class red_to_blue implements DelvColorFun {
  color getColor(float value) {
    return lerp(color(255,0,0), color(0,0,255), value);
  }
}

class brightgreen implements DelvColorFun {
  color getColor(float value) {
    return color(0, 255, 0);
  }
}

class ColorMapWithCheckpoints implements DelvColorFun {
  ArrayList<Integer> _colors;

  ColorMapWithCheckpoints(ArrayList<Integer> colors) {
    if (colors.size() > 0) {
      _colors = colors;
    } else {
      _colors = new ArrayList<Integer>();
      _colors.add(unhex("FFFFD9"));
      _colors.add(unhex("EDF8B1"));
      _colors.add(unhex("C7E9B4"));
      _colors.add(unhex("7FCDBB"));
      _colors.add(unhex("41B6C4"));
      _colors.add(unhex("1D91C0"));
      _colors.add(unhex("225EA8"));
      _colors.add(unhex("253494"));
      _colors.add(unhex("081D58"));
    }
  }

  ColorMapWithCheckpoints() {
    this(new ArrayList<Integer>());
  }

  color getColor(float value) {
    // pass this class into ContinuousColorMap.setColor as colorfun
    // value is in range 0 to 1
    // divide this range into equal pieces depending on number of self.colors
    int numIntervals = _colors.size() - 1;
    float interval = 1.0 / numIntervals;
    color c = color(255,255,255);
    for (int i = 0; i < numIntervals; ++i) {
      if (value < (i+1) * interval) {
        c = lerp(_colors.get(i), _colors.get(i+1), (value - (i)*interval) / interval);
        break;
      }
    }
    return c;
  }
} // end class ColorMapWithCheckpoints

// TODO create some default color map constructors here
String[] categorical_map_1() {
  // from MulteeSum
  String[] cmap = {"FF7F00",
                   "6A3D9A",
                   "1F78B4",
                   "33A02C",
                   "FB9A99",
                   "A6CEE3",
                   "B2DF8A",
                   "FDBF6F",
                   "CAB2D6"};
  return cmap;
}

String[] categorical_map_2() {
  // from InSite
  String[] cmap = {"1F78B4",   // blue
                   "33A02C",   // green
                   "E31A1C",   // red
                   "FF7F00",   // orange
                   "6A3D9A",   // purple
                   "D2D2D2", // clear old color (FEATURE_DEFAULT_COLOR)
                   "A6CEE3",   // lt blue
                   "B2DF8A",   // lt green
                   "FB9A99",   // lt red
                   "FDBF6F",   // lt orange
                   "CAB2D6",   // lt purple
                   "010101"}; // clear all colors (FEATURE_CLEAR_COLOR
  return cmap;
}

DelvDiscreteColorMap create_discrete_map_from_hex(String[] cats, String[] cmap) {
  color[] cmap_rgb = new color[cmap.length];
  for (int i = 0; i < cmap.length; ++i) {
    cmap_rgb[i] = unhex(cmap[i]);
  }

  return create_discrete_map(cats, cmap_rgb);
}

DelvDiscreteColorMap create_discrete_map(String[] cats, color[] cols) {
  int num_colors = cols.length;
  DelvDiscreteColorMap disc_map = new DelvDiscreteColorMap();
  for (int i = 0; i < cats.length; i++) {
    disc_map.setColor(cats[i], cols[i % num_colors]);
  }
  return disc_map;
}

void testMaps() {
  DelvContinuousColorMap cmap1 = new DelvContinuousColorMap();
  cmap1.setDefaultColor(color(130,130,130));
  HalfOpenRange crange = new HalfOpenRange();
  crange.setUpper(.3);
  cmap1.setColor(crange, new green_scale());
  crange = new HalfOpenRange();
  crange.setLower(.5);
  crange.setUpper(.8);
  cmap1.setColor(crange, new green_to_red());
  crange = new HalfOpenRange();
  crange.setLower(.9);
  crange.setUpper(1.5);
  cmap1.setColor(crange, new red_to_blue());
  crange = new HalfOpenRange();
  crange.setLower(1.6);
  crange.setUpper(1.9);
  cmap1.setColor(crange, new brightgreen());
  cmap1.drawToFile("/tmp/custom_cont_map.png");

  DelvContinuousColorMap cmap4 = new DelvContinuousColorMap();
  DelvColorFun checkpts = new ColorMapWithCheckpoints();
  cmap4.setDefaultColor(color(130,130,130));
  crange = new HalfOpenRange();
  crange.setLower(-10);
  crange.setUpper(20);
  cmap4.setColor(crange, checkpts);
  cmap4.drawToFile("/tmp/map_with_checkpoints.png");

  // create categorical map
  String[] cat1 = {"a","b","c","d","e","f","g","h","i"};
  DelvDiscreteColorMap cmap2 = create_discrete_map_from_hex(cat1, categorical_map_1());
  cmap2.drawToFile("/tmp/cat1.png");

  String[] cat2 = {"a","b","c","d","e","f","g","h","i","j","k","l"};
  DelvDiscreteColorMap cmap3 = create_discrete_map_from_hex(cat2, categorical_map_2());
  cmap3.drawToFile("/tmp/cat2.png");
}
