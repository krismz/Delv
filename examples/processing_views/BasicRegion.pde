// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

//----------------------------------------------------
//
class FeatureType
{
  String _tag;
  boolean _show;
  // TODO remove _show_color from here and get from color map instead?
  // alternatively, have color map update this local value
  color _show_color;
  float _min_strength, _max_strength;

  FeatureType( String tag )
  {
    _tag = tag;
    _show = true;
    _show_color = DEFAULT_COLOR;
  }

  String tag() { return _tag; }

  void show( boolean s ) { _show = s; }
  void showColor( color c ) { _show_color = c; }
  boolean show() { return _show; }
  color showColor() { return _show_color; }

  void minMaxStrength( float min_s, float max_s ) { _min_strength = min_s; _max_strength = max_s; }
  float minStrength() { return _min_strength; }
  float maxStrength() { return _max_strength; }
  float maxMinusMinStrength() { return _max_strength-_min_strength; }
}


//----------------------------------------------------
//
class PointFeature extends BasicRegion
{
  int _type;
  float _strength;

  PointFeature( long start, int type, float strength, String tag, String id )
  {
    super( start, tag, id );
    _type = type;
    _strength = strength;
  }

  int type() { return _type; }
  float strength() { return _strength; }
}


//----------------------------------------------------
//
class IntervalFeature extends IntervalRegion
{
  int _type;
  float _strength;


  IntervalFeature( long start, long len, int type, float strength, String tag, String id )
  {
    super( start, len, tag, id );
    _type = type;
    _strength = strength;
  }

  int type() { return _type; }
  float strength() { return _strength; }
}

//----------------------------------------------------
//
class IntervalRegion extends BasicRegion
{
  long _len;
  long _stop;
  long _relative_stop;
  IntervalRegion() {}
  IntervalRegion( long start, long len, String tag, String id )
  {
    super(start, tag, id);
    _len = len;
    computeStop();
  }

  void len( long l ) { _len = l; }
  long len() { return _len; }
  long stop() { return _stop; }

  void computeStop() { _stop = _start + _len - 1; }

  void computeRelativeStartStop( long start )
  {
    computeRelativeStart(start);
    _relative_stop = _stop - start;
  }

}

//----------------------------------------------------
//
class Region extends IntervalRegion
{
  ArrayList<PointFeature> _pointFeaturesAbove;
  ArrayList<PointFeature> _pointFeaturesBelow;
  ArrayList<IntervalFeature> _intervalFeaturesAbove;
  ArrayList<IntervalFeature> _intervalFeaturesBelow;
  float _pixel_per_unit;
  String _units;
  int _render_start, _render_stop;
  boolean _show;

  Region()
  {
    _pointFeaturesAbove = new ArrayList<PointFeature>();
    _pointFeaturesBelow = new ArrayList<PointFeature>();
    _intervalFeaturesAbove = new ArrayList<IntervalFeature>();
    _intervalFeaturesBelow = new ArrayList<IntervalFeature>();
    _show = true;
  }

  Region( long start, long len, String tag, String id )
  {
    super( start, len, tag, id );
    _pointFeaturesAbove = new ArrayList<PointFeature>();
    _pointFeaturesBelow = new ArrayList<PointFeature>();
    _intervalFeaturesAbove = new ArrayList<IntervalFeature>();
    _intervalFeaturesBelow = new ArrayList<IntervalFeature>();
    _show = true;
  }

  void addPointFeatureAbove( PointFeature pf ) { _pointFeaturesAbove.add(pf); }
  void addPointFeatureBelow( PointFeature pf ) { _pointFeaturesBelow.add(pf); }
  void addIntervalFeatureAbove( IntervalFeature intf ) { _intervalFeaturesAbove.add(intf); }
  void addIntervalFeatureBelow( IntervalFeature intf ) { _intervalFeaturesBelow.add(intf); }


  // NOTE Collections.sort does not work in processing.js
  void sortFeatures() {
  // NOTE Collections.sort does not work in processing.js
//     FeatureComparator1 comparator1 = new FeatureComparator1();
//     Collections.sort( _features, comparator1 );
  }

  void show( boolean s ) { _show = s; }
  boolean show() { return _show; }

  PointFeature pointFeatureAbove( int i ) { return (PointFeature)_pointFeaturesAbove.get(i); }
  PointFeature pointFeatureBelow( int i ) { return (PointFeature)_pointFeaturesBelow.get(i); }
  IntervalFeature intervalFeatureAbove( int i ) { return (IntervalFeature)_intervalFeaturesAbove.get(i); }
  IntervalFeature intervalFeatureBelow( int i ) { return (IntervalFeature)_intervalFeaturesBelow.get(i); }

  int numPointFeaturesAbove() { return _pointFeaturesAbove.size(); }
  int numPointFeaturesBelow() { return _pointFeaturesBelow.size(); }
  int numIntervalFeaturesAbove() { return _intervalFeaturesAbove.size(); }
  int numIntervalFeaturesBelow() { return _intervalFeaturesBelow.size(); }

  void pixelPerUnit( float v ) { _pixel_per_unit = v; }
  float pixelPerUnit() { return _pixel_per_unit; }
  void units( String u ) { _units = u; }
  String units() { return _units; }
  void renderStartStop( int start, int stop ) { _render_start = start; _render_stop = stop; }
  int renderStart() { return _render_start; }
  int renderStop() { return _render_stop; }

  void setRelativeStartsAndStops()
  {
    for ( int i = 0; i < numPointFeaturesAbove(); i++ )
      pointFeatureAbove(i).computeRelativeStart( _start );
    for ( int i = 0; i < numPointFeaturesBelow(); i++ )
      pointFeatureBelow(i).computeRelativeStart( _start );

    for ( int i = 0; i < numIntervalFeaturesAbove(); i++ )
      intervalFeatureAbove(i).computeRelativeStartStop( _start );
    for ( int i = 0; i < numIntervalFeaturesBelow(); i++ )
      intervalFeatureBelow(i).computeRelativeStartStop( _start );

  }

  void addStartStopFeatures(int type, float strength)
  {
    addIntervalFeatureBelow( new IntervalFeature( _start, 0, type, strength, "", "") );
    addIntervalFeatureBelow( new IntervalFeature( _stop, 0, type, strength, "", "") );
  }
}


// public class FeatureComparator1 implements Comparator<Feature> {
//   public int compare(Feature bs1, Feature bs2) {
//     return ((Long)(bs2._len)).compareTo((Long)(bs1._len));
//   }
// }

// public class FeatureComparator2 implements Comparator<Feature> {
//   public int compare(Feature bs1, Feature bs2) {
//     return ((Float)(bs2._strength)).compareTo((Float)(bs1._strength));
//   }
// }

//----------------------------------------------------
//
// the basic definition of a genomic region
//
class BasicRegion
{
  long _start;
  long _relative_start;
  String _tag;
  String _id;

  BasicRegion() {}

  BasicRegion( long start, String tag, String id )
  {
    _start = start;
    _tag = tag;
    _id = id;
  }

  void tag( String t ) { _tag = t; }
  void id( String i ) { _id = i; }
  void start( long s ) { _start = s; }

  long start() { return _start; }
  String tag() { return _tag; }
  String id() { return _id; }
  long relativeStart() { return _relative_start; }


  void computeRelativeStart( long start )
  {
    _relative_start = _start - start;
  }
}

