// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

import java.awt.event.MouseWheelListener;
import java.awt.event.MouseWheelEvent;
import java.util.Iterator;

///////////////////////////////////
//         RegionDataset         //
///////////////////////////////////
class RegionDataset {
  String _name;
  String _regionTypeAttr;
  String _regionLengthAttr;
  String _barLengthAttr;
  String _barHeightAttr;
  String _barStartAttr;
  String _barTypeAttr;
  String _barTagAttr;
  String _barIdAttr;
  String _units;
  String _defaultRegionType;
  String _defaultBarHeight;
  String _defaultBarLength;
  String _defaultBarType;

  RegionDataset() {
    _name = "";
    _regionTypeAttr = "";
    _regionLengthAttr = "";
    _barLengthAttr = "";
    _barHeightAttr = "";
    _barStartAttr = "";
    _barTypeAttr = "";
    _barTagAttr = "";
    _barIdAttr = "";
    _units = "";
    _defaultRegionType = "";
    _defaultBarHeight = "1.0";
    _defaultBarLength = "0";
    _defaultBarType = "";
  }

  String name() {
    return _name;
  }
  RegionDataset name(String name) {
    _name = name;
    return this;
  }

  String regionTypeAttr() {
    return _regionTypeAttr;
  }
  RegionDataset regionTypeAttr(String regionTypeAttr) {
    _regionTypeAttr = regionTypeAttr;
    return this;
  }
  String defaultRegionType() {
    return _defaultRegionType;
  }
  RegionDataset defaultRegionType(String defaultRegionType) {
    _defaultRegionType = defaultRegionType;
    return this;
  }

  String regionLengthAttr() {
    return _regionLengthAttr;
  }
  RegionDataset regionLengthAttr(String regionLengthAttr) {
    _regionLengthAttr = regionLengthAttr;
    return this;
  }

  String barLengthAttr() {
    return _barLengthAttr;
  }
  RegionDataset barLengthAttr(String barLengthAttr) {
    _barLengthAttr = barLengthAttr;
    return this;
  }
  String defaultBarLength() {
    return _defaultBarLength;
  }
  RegionDataset defaultBarLength(String defaultBarLength) {
    _defaultBarLength = defaultBarLength;
    return this;
  }

  String barHeightAttr() {
    return _barHeightAttr;
  }
  RegionDataset barHeightAttr(String barHeightAttr) {
    _barHeightAttr = barHeightAttr;
    return this;
  }
  String defaultBarHeight() {
    return _defaultBarHeight;
  }
  RegionDataset defaultBarHeight(String defaultBarHeight) {
    _defaultBarHeight = defaultBarHeight;
    return this;
  }

  String barStartAttr() {
    return _barStartAttr;
  }
  RegionDataset barStartAttr(String barStartAttr) {
    _barStartAttr = barStartAttr;
    return this;
  }

  String barTypeAttr() {
    return _barTypeAttr;
  }
  RegionDataset barTypeAttr(String barTypeAttr) {
    _barTypeAttr = barTypeAttr;
    return this;
  }
  String defaultBarType() {
    return _defaultBarType;
  }
  RegionDataset defaultBarType(String defaultBarType) {
    _defaultBarType = defaultBarType;
    return this;
  }

  String barTagAttr() {
    return _barTagAttr;
  }
  RegionDataset barTagAttr(String barTagAttr) {
    _barTagAttr = barTagAttr;
    return this;
  }

  String barIdAttr() {
    return _barIdAttr;
  }
  RegionDataset barIdAttr(String barIdAttr) {
    _barIdAttr = barIdAttr;
    return this;
  }

  String units() {
    return _units;
  }
  RegionDataset units(String units) {
    _units = units;
    return this;
  }

}

///////////////////////////////////
//              View             //
///////////////////////////////////

class RegionView extends DelvBasicView {
// TODO figure out which of these members are actually necessary
  int _width, _height;
  int _regions_view_w, _regions_view_h, _regions_w, _regions_h;
  int[] _regions_origin;

  int _region_alignment;
  int _region_tag_max_width;

  boolean _feature_above_rolled_over, _feature_below_rolled_over;
  int _rolled_over_feature_above, _rolled_over_feature_below, _rolled_over_region;
  int _feature_above_mouseX, _feature_above_mouseY;
  int _feature_below_mouseX, _feature_below_mouseY;

  FeatureType[] _feature_above_types;
  int[] _feature_above_order;
  FeatureType[] _feature_below_types;
  int[] _feature_below_order;
  Region[] _regions;

  boolean _feature_above_type_rolled_over;
  int _rolled_over_feature_above_type;

  boolean _y_scroll_present, _y_scroll_bar_rolled_over, _y_scroll_bar_pressed;
  int _y_scroll_bar_start, _y_scroll_bar_h, _y_scroll_bar_pressed_y;

  int _scale_pixel_length;
  String _scale_tag;

  float _percent_regions_shown, _percent_regions_start;

  RegionDataset _above_dataset;
  RegionDataset _below_dataset;

  RegionView() {
    this("Region");
  }


  RegionView(String name)
  {
    super(name);
    // TODO un hard code some of these configuration parameters
    _global_min_v = 5.0;
    _regions_origin = new int[2];

    _region_alignment = REGION_ALIGNMENT_LEFT;
    _feature_above_rolled_over = _feature_below_rolled_over = _feature_above_type_rolled_over = false;

    // find the max pixel width of the region and feature type tags

//     _region_tag_max_width = _feature_type_tag_max_width = MIN_INT;
    _region_tag_max_width = MIN_INT;
    textFont( _verdana_font_12 );
    _region_tag_max_width = REGION_TAG_OFFSET;

    _regions_origin[0] = _region_tag_max_width - 1; // if displaying the tag
//     _regions_origin[0] = REGION_OFFSET;
    _regions_origin[1] = SCALE_BAR_OFFSET;

    _percent_regions_start = 0.0;

    _regions = new Region[0];
    _y_scroll_bar_start = 0;
    _y_scroll_bar_rolled_over = _y_scroll_bar_pressed = false;
  }

  RegionDataset createDataset(String name) {
    RegionDataset rd = new RegionDataset();
    rd.name(name);
    return rd;
  }

  void addDataset(RegionDataset dataset, boolean add_below) {
    if (add_below) {
      _below_dataset = dataset;
    }
    else {
      _above_dataset = dataset;
    }
  }

  void connectSignals() {
    if (_delv == null) {
      return;
    }
    super.connectSignals();
    // filter, hover handled by base class
    // TODO document better what each class provides
    _delv.connectToSignal("colorChanged", _name, "onColorChanged");
    _delv.connectToSignal("alignmentChanged", _name, "onAlignmentChanged");
  }

  // Region needs to override a number of methods because of the dual datasets
  // TODO maybe create a Delv1DatasetView and a Delv2DatasetView?
  void hoverItem(String id, boolean doDraw) {
    String[][] coords = new String[1][];
    coords[0] = idToCoord(id);
    if (_feature_above_rolled_over) {
      if (_hoverCoords.length != 1 || !coordsEqual(_hoverCoords[0], coords[0])) {
        _hoverCoords = coords;
        _delv.hoverItem(_name, _above_dataset.name(), coords[0]);
        if (_below_dataset != null) {
          _delv.hoverItem(_name, _below_dataset.name(), new String[0]);
        }

        // TODO remove this, just done for d3 demo
        String[] selections = new String[1];
        selections[0] = id;
        _delv.selectItems(_name, _above_dataset.name(), selections, "PRIMARY");
        if (doDraw) {
          draw();
        }
      }
    } else {
      if (_hoverCoords.length != 1 || !coordsEqual(_hoverCoords[0], coords[0])) {
        _hoverCoords = coords;
        if (_below_dataset != null) {
          _delv.hoverItem(_name, _below_dataset.name(), coords[0]);
        }
        _delv.hoverItem(_name, _above_dataset.name(), new String[0]);

        // TODO remove this, just done for d3 demo
        String[] selections = new String[1];
        selections[0] = "";
        _delv.selectItems(_name, _above_dataset.name(), selections, "PRIMARY");
        if (doDraw) {
          draw();
        }
      }
    }
  }

  void onColorChanged(String invoker, String dataset, String attribute) {
    // TODO respond to color for below dataset as well
    if (!invoker.equals(_name) &&
        dataset.equals(_above_dataset.name()) &&
        attribute.equals(_above_dataset.barTypeAttr())) {
      updateFeatureVisibility();
    }
  }

  void onFilterChanged(String invoker, String dataset, String coordination, String detail) {
    // TODO respond to filter for below dataset as well
    if (!invoker.equals(_name) &&
        dataset.equals(_above_dataset.name())) {
      updateRegionVisibility();
      updateFeatureVisibility();
    }
  }

  void onHoverChanged(String invoker, String dataset, String coordination, String detail) {
    // TODO respond to hover for below dataset as well
    if (!invoker.equals(_name) &&
        dataset.equals(_above_dataset.name())) {
      if (coordination.equals("ITEM")) {
        updateHoveredIds(_delv.getHoverIds(_above_dataset.name()));
      } else {
        updateHoveredCategory(_delv.getHoverCat(_above_dataset.name(), _above_dataset.barTypeAttr()));
      }
    }
  }

  void onSelectChanged(String invoker, String dataset, String coordination, String selectType) {
    // TODO respond to select for below dataset as well
    if (!invoker.equals(_name) &&
        dataset.equals(_above_dataset.name()) &&
        selectType.equals("PRIMARY")) {
      updateSelections();
    }
  }

  void onAlignmentChanged(String invoker, String dataset, String alignment) {
    if (!invoker.equals(_name)) {
      setAlignment(alignment);
    }
  }

  void updateSelections() {
    // TODO undo this crosslinking from selection to hovering
    updateHoveredIds(_delv.getSelectIds(_above_dataset.name(), "PRIMARY"));
  }

  void addDatasetToRegionMap(RegionDataset dataset, HashMap<String,Region> regionMap, boolean add_below) {
    String name = dataset.name();

    String[] regions = new String[0];
    String[] regionLengths = new String[0];
    String[] barStarts = new String[0];
    String[] barLengths = new String[0];
    String[] barTypes = new String[0];
    String[] barHeights = new String[0];
    String[] barIds = new String[0];
    String[] barTags = new String[0];
    boolean haveRegions;
    boolean haveRegionLengths;
    boolean haveBarLengths;
    boolean haveBarTypes;
    boolean haveBarHeights;

    // TODO want to refactor dataIF to something like _dataIF.allItems(name, dataset.regionTypeAttr())
    barStarts = _delv.getAllItems(name, dataset.barStartAttr());

    if (!dataset.regionTypeAttr().equals("")) {
      regions = _delv.getAllItems(name, dataset.regionTypeAttr());
      haveRegions = true;
    } else { haveRegions = false; }

    if (!dataset.regionLengthAttr().equals("")) {
      regionLengths = _delv.getAllItems(name, dataset.regionLengthAttr());
      haveRegionLengths = true;
    } else { haveRegionLengths = false; }

    if (!dataset.barLengthAttr().equals("")) {
      barLengths = _delv.getAllItems(name, dataset.barLengthAttr());
      haveBarLengths = true;
    }
    else { haveBarLengths = false; }

    if (!dataset.barTypeAttr().equals("")) {
      barTypes = _delv.getAllItems(name, dataset.barTypeAttr());
      haveBarTypes = true;
    }
    else { haveBarTypes = false; }

    if (!dataset.barHeightAttr().equals("")) {
      barHeights = _delv.getAllItems(name, dataset.barHeightAttr());
      haveBarHeights = true;
    }
    else { haveBarHeights = false; }

    if (!dataset.barIdAttr().equals("")) {
      barIds = _delv.getAllItems(name, dataset.barIdAttr());
    }
    else {
      barIds = _delv.getAllIds(name, dataset.barStartAttr());
    }
    if (!dataset.barTagAttr().equals("")) {
      barTags = _delv.getAllItems(name, dataset.barTagAttr());
    }
    else {
      barTags = _delv.getAllIds(name, dataset.barStartAttr());
    }

    String[] regionTypes = new String[0];
    if (haveRegions) {
      regionTypes = _delv.getAllCats(name, dataset.regionTypeAttr());
    }
    else {
      regionTypes = new String[1];
      regionTypes[0] = dataset.defaultRegionType();
      regions = new String[1];
      regions[0] = dataset.defaultRegionType();
    }
    for (int i = 0; i < regionTypes.length; ++i) {
      if (!(regionMap.containsKey(regionTypes[i]))) {
        Region newReg = new Region();
        newReg.len(0);
        newReg.tag(regionTypes[i]);
        newReg.id(regionTypes[i]);
        regionMap.put(regionTypes[i], newReg);
      }
    }

    String[] possibleTypes = new String[0];
    if (haveBarTypes) {
      possibleTypes = _delv.getAllCats(name,dataset.barTypeAttr());
    }
    else {
      possibleTypes = new String[1];
      possibleTypes[0] = dataset.defaultBarType();
    }
    if (add_below) {
      setIntervalFeaturesBelowTypes(possibleTypes);
    }
    else {
      setIntervalFeaturesAboveTypes(possibleTypes);
    }

    for (int i = 0; i < barStarts.length; ++i) {
      int regIdx = 0;
      if (haveRegions) {
        regIdx = i;
      }
      Region curReg = regionMap.get(regions[regIdx]);
      if (curReg == null) {
        continue;
      }
      curReg.start(0);
      int t = -1;
      if (haveBarTypes) {
        for ( int j = 0; j < possibleTypes.length; j++ )
        {
          if ( barTypes[i].equals( possibleTypes[j] ) )
            t = j;
        }
      }
      else { t = 0; }
      float h = 1.0;
      if (haveBarHeights) {
        h = float(barHeights[i]);
      }
      else {
        h = float(dataset.defaultBarHeight());
      }
      int l = 0;
      if (haveBarLengths) {
        l = int(barLengths[i]);
      }
      else {
        l = int(dataset.defaultBarLength());
      }
      if (add_below) {
      curReg.addIntervalFeatureBelow( new IntervalFeature( int(barStarts[i]),
                                                           l,
                                                           t,
                                                           h,
                                                           barTags[i],
                                                           barIds[i] ) );
      }
      else {
        curReg.addIntervalFeatureAbove( new IntervalFeature( int(barStarts[i]),
                                                             l,
                                                             t,
                                                             h,
                                                             barTags[i],
                                                             barIds[i] ) );
      }
      if (haveRegionLengths) {
        curReg.len(max(int(regionLengths[i]), int(curReg.len())));
      }
      else {
        curReg.len(max(int(barStarts[i]) + l, int(curReg.len())));
      }
      regionMap.put(regions[regIdx], curReg);
    }
//     return regionMap;
  } // end addDatasetToRegionMap

  void onDataChanged(String source) {
    if (_delv == null) {
      return;
    }
    // TODO right now assumes that there is always a region above if there is also a region below
    HashMap<String,Region> regionMap = new HashMap<String, Region>();

    addDatasetToRegionMap(_above_dataset, regionMap, false);
    if (_below_dataset != null) {
      addDatasetToRegionMap(_below_dataset, regionMap, true);
    }

    ArrayList<Region> regionList = new ArrayList<Region>();
    regionList.addAll(regionMap.values());
    Iterator regIt = regionList.iterator();
    while (regIt.hasNext()) {
      Region curReg = (Region)regIt.next();
      curReg.units(_above_dataset.units());
      curReg.computeStop();
      if (_below_dataset == null) {
        curReg.addStartStopFeatures(0, 1.0);
      }
      else {
        curReg.addStartStopFeatures(0, int(_below_dataset.defaultBarHeight()));
      }
      curReg.setRelativeStartsAndStops();
      curReg.sortFeatures();
    }

    setRegions(regionList);

    // set up config values
    determineMinMaxStrengths(false);

    updateRegionVisibility();
    updateFeatureVisibility();
  }

  void updateRegionVisibility() {
    String[] visibleRegions;
    if (!_above_dataset.regionTypeAttr().equals("")) {
      visibleRegions = _delv.getFilterCats(_above_dataset.name(), _above_dataset.regionTypeAttr());
    }
    else {
      visibleRegions = new String[1];
      visibleRegions[0] = _above_dataset.defaultRegionType();
    }
    setVisibleRegions(visibleRegions);
  }

  void updateFeatureVisibility() {
    String[] visibleFeatures;
    if (!_above_dataset.barTypeAttr().equals("")) {
      visibleFeatures = _delv.getFilterCats(_above_dataset.name(), _above_dataset.barTypeAttr());
    }
    else {
      // TODO save this structure off to save time?
      visibleFeatures = new String[1];
      visibleFeatures[0] = _above_dataset.defaultBarType();
    }
    setVisibleIntervalFeaturesAbove(visibleFeatures);

    if (!_above_dataset.barTypeAttr().equals("")) {
      // TODO should we use colorAttr instead of specifying attr here?
      String[][] colorStrs;
      colorStrs = _delv.getFilterCatColors(_above_dataset.name(),
                                           _above_dataset.barTypeAttr());
      for (int i = 0; i < colorStrs.length; i++) {
        String[] cStr = colorStrs[i];
        color c = color(int(cStr[0]), int(cStr[1]), int(cStr[2]));
        setIntervalFeatureAboveTypeColor(visibleFeatures[i], c);
      }
    }
  }

  void updateHoveredIds(String[] ids) {
    // TODO can only handle one item rolled over here, so arbitrarily take the first one
    if (ids.length > 0) {
      setIntervalFeatureAboveHoveredId(ids[0]);
    } else {
      setIntervalFeatureAboveHoveredId("");
    }
  }

  void updateHoveredCategory(String cat) {
    setIntervalFeatureAboveHoveredType(cat);
  }


  void setAlignment(String alignment) {
    String align = alignment.toLowerCase();
    if (align.startsWith("l")) {
      _region_alignment = REGION_ALIGNMENT_LEFT;
    } else if (align.startsWith("r")) {
      _region_alignment = REGION_ALIGNMENT_RIGHT;
    } else if (align.startsWith("c")) {
      _region_alignment = REGION_ALIGNMENT_CENTER;
    } else {
      _region_alignment = REGION_ALIGNMENT_STRETCH;
    }
    setAlignmentAndScaleParameters();
    draw();
  }

  // internal functions
  void setIntervalFeaturesAboveTypes(String[] types) {
    _feature_above_types = new FeatureType[types.length];
    _feature_above_order = new int[types.length];
    for (int i = 0; i < types.length; i++) {
      _feature_above_types[i] = new FeatureType( types[i] );
      _feature_above_order[i] = i;
//       _feature_type_tag_max_width = max( _feature_type_tag_max_width, (int)textWidth( _feature_above_types[i].tag() ) );
    }
//     _num_active_features = _feature_types.length;
  }
  void setIntervalFeaturesBelowTypes(String[] types) {
    _feature_below_types = new FeatureType[types.length];
    _feature_below_order = new int[types.length];
    for (int i = 0; i < types.length; i++) {
      _feature_below_types[i] = new FeatureType( types[i] );
      _feature_below_order[i] = i;
//       _feature_type_tag_max_width = max( _feature_type_tag_max_width, (int)textWidth( _feature_below_types[i].tag() ) );
    }
//     _num_active_features = _feature_types.length;
  }

  void setVisibleIntervalFeaturesAbove(String[] features) {
    for ( int i = 0; i < _feature_above_types.length; i++ )
    {
      _feature_above_types[i].show(false);
    }

    for ( int f = 0; f < features.length; f++)
    {
      int type = -1;
      for ( int i = 0; i < _feature_above_types.length; i++ )
      {
        if (features[f].equals(_feature_above_types[i].tag())) {
          _feature_above_types[i].show(true);
        }
      }
    }
    draw();
  }

  void setVisibleRegions(String[] regions) {
    for ( int i = 0; i < _regions.length; i++ )
    {
      _regions[i].show(false);
      for ( String region : regions )
      {
        if ( region.equals(_regions[i].id()) )
        {
          _regions[i].show(true);
        }
      }
    }
    computeTotalRegionsHeight();
    setAlignmentAndScaleParameters();
    draw();
  }

  void determineMinMaxStrengths( boolean global ) {
    float min_v, max_v;

    // give all the feature types the same, global min and max
    if ( global )
    {
      min_v = MAX_FLOAT;
      max_v = MIN_FLOAT;

      for ( int i = 0; i < _regions.length; i++ )
      { 
        for ( int j = 0; j < _regions[i].numIntervalFeaturesAbove(); j++ )
        {
          min_v = min( min_v, _regions[i].intervalFeatureAbove(j).strength() );
          max_v = max( max_v, _regions[i].intervalFeatureAbove(j).strength() );
        }
      }

      min_v = _global_min_v; 
      for ( int i = 0; i < _feature_above_types.length; i++ )
        _feature_above_types[i].minMaxStrength( min_v, max_v );
    }

    // store min and max on a per feature type basis
    else
    {
      for ( int i = 0; i < _feature_above_types.length; i++ )
      {
        min_v = MAX_FLOAT;
        max_v = MIN_FLOAT;

        for ( int r = 0; r < _regions.length; r++ )
        { 
          for ( int j = 0; j < _regions[r].numIntervalFeaturesAbove(); j++ )
          {
            if ( _regions[r].intervalFeatureAbove(j).type() != i ) continue;

            min_v = min( min_v, _regions[r].intervalFeatureAbove(j).strength() );
            max_v = max( max_v, _regions[r].intervalFeatureAbove(j).strength() );
          }
        }
        min_v = _global_min_v;
        _feature_above_types[i].minMaxStrength( min_v, max_v );
      }
    }
  }

  void determineMaxRegionLength()
  {
    long max_v = MIN_INT; // Processing and thus processing.js doesn't have MIN_LONG defined.  But then javascript doesn't really have longs either
    for ( int i = 0; i < _regions.length; i++ )
      if ( _regions[i].show() ) max_v = (long)max( max_v, _regions[i].len() );
    _regions_max_len = max_v;
  }

  void setRegions(ArrayList<Region> regions) {
    _regions = regions.toArray(new Region[regions.size()]);
    _region_tag_max_width = REGION_TAG_OFFSET;
    for ( int i = 0; i < _regions.length; i++ ) {
      _region_tag_max_width = max( _region_tag_max_width, (int)textWidth( _regions[i].tag() ) + REGION_TAG_OFFSET );
    }
    _regions_origin[0] = _region_tag_max_width - 1; // if displaying the tag

    // compute the total height of the regions
    computeTotalRegionsHeight();

  }

  void setIntervalFeatureAboveTypeColor(String cat, color c) {
    int type = -1;
    for ( int i = 0; i < _feature_above_types.length; i++ )
    {
      if (cat.equals(_feature_above_types[i].tag())) {
        _feature_above_types[i].showColor(c);
        break;
      }
    }
    draw();
  }

  void setIntervalFeatureAboveHoveredId(String id) {
    _feature_above_rolled_over = false;
    Region region;
    IntervalFeature feature;
    for ( int j = 0; j < _regions.length; j++ )
    {
      region = _regions[j];
      for ( int k = region.numIntervalFeaturesAbove()-1; k >= 0; k-- )
      {
        feature = region.intervalFeatureAbove(k);
        if (feature.id().equals(id)) {
          _feature_above_rolled_over = true;
          _rolled_over_region = j;
          _rolled_over_feature_above = k;
          _feature_above_mouseX = -1;
          _feature_above_mouseY = -1;
          break;
        }
      }
      if (_feature_above_rolled_over) {
        break;
      }
    }
    draw();
  }

  void setIntervalFeatureAboveHoveredType(String cat) {
    _feature_above_type_rolled_over = false;
    for ( int i = 0; i < _feature_above_types.length; i++ )
    {
      if (cat.equals(_feature_above_types[i].tag())) {
        _feature_above_type_rolled_over = true;
        _rolled_over_feature_above_type = i;
        break;
      }
    }
    draw();
  }

  void computeTotalRegionsHeight() {
    _regions_h = 0;

    for ( int i = 0; i < _regions.length; i++ ) {
      if ( _regions[i].show() ) _regions_h += REGION_HEIGHT + REGION_OFFSET;
    }
    if ( _regions_h != 0 ) _regions_h -= REGION_OFFSET;

    // TODO figure out how to handle scrolling
    computeYScrollBarDimensions();
  }

  void computeYScrollBarDimensions() {
    if ( _regions_h > _regions_view_h ) {

      _percent_regions_shown = (float)_regions_view_h / (float)_regions_h;
      _y_scroll_bar_h = (int)(_percent_regions_shown * _regions_view_h);

      //check if we are going from not scrolling to scrolling
      if ( !_y_scroll_present ) {
        _y_scroll_bar_start = 0;
        _percent_regions_start = 0.0;
      }
      else { 
        if ( (_percent_regions_shown+_percent_regions_start) > 1.0 ) {
          _y_scroll_bar_start = _regions_view_h - _y_scroll_bar_h; 
          _percent_regions_start = (float)_y_scroll_bar_start / (float)_regions_h;
        }
        else {
          _y_scroll_bar_start = (int)(_percent_regions_start*_regions_h);
        }
      }

      _y_scroll_present = true;
    }
    else {
      _percent_regions_start = 0.0;
      _percent_regions_shown = 1.0;
      _y_scroll_present = false;
    }
  }

// this needs to be called whenever the regions change
  void setAlignmentAndScaleParameters()
  {   
    // get the max length for just the regions that are being shown 
    determineMaxRegionLength();

    // set the unit/pixel and regions start/stops
    float pixel_per_unit = (float)_regions_view_w / (float)_regions_max_len;
    String units = "";
    if (_regions.length > 0 )
    {
      units = _regions[0].units();
    }
    switch ( _region_alignment )
    {
    case REGION_ALIGNMENT_LEFT:

      for ( int i = 0; i < _regions.length; i++ )
      {
        _regions[i].pixelPerUnit( pixel_per_unit );
        _regions[i].renderStartStop( 0, round( (float)(_regions[i].len()-1)*pixel_per_unit ) );
      }
      break;

    case REGION_ALIGNMENT_RIGHT:

      for ( int i = 0; i < _regions.length; i++ )
      {
        _regions[i].pixelPerUnit( pixel_per_unit );
        _regions[i].renderStartStop( _regions_view_w-round((float)_regions[i].len()*pixel_per_unit), _regions_view_w-1  );
      }
      break;

    case REGION_ALIGNMENT_CENTER:

      for ( int i = 0; i < _regions.length; i++ )
      {
        _regions[i].pixelPerUnit( pixel_per_unit );
        int diff = _regions_view_w-round((float)_regions[i].len()*pixel_per_unit);
        _regions[i].renderStartStop( diff/2, _regions_view_w-1-diff/2  );
      }
      break;

    case REGION_ALIGNMENT_STRETCH:

      for ( int i = 0; i < _regions.length; i++ )
      {
        _regions[i].pixelPerUnit( (float)_regions_view_w / (float)_regions[i].len()  );
        _regions[i].renderStartStop( 0, (_regions_view_w-1) );
      }
      break;
    }

    // set the scale bar parameters
    long scale_length = 10000000; 
    _scale_tag = "10 M" + units;
    if ( _regions_max_len <= 20 ) { 
      scale_length = 1; 
      _scale_tag = "1 " + units;
    }
    else if ( _regions_max_len <= 200 ) { 
      scale_length = 10; 
      _scale_tag = "10 " + units;
    }
    else if ( _regions_max_len <= 2000 ) { 
      scale_length = 100; 
      _scale_tag = "100 " + units;
    }
    else if ( _regions_max_len <= 20000 ) { 
      scale_length = 1000; 
      _scale_tag = "1 k" + units;
    }
    else if ( _regions_max_len <= 200000 ) { 
      scale_length = 10000; 
      _scale_tag = "10 k" + units;
    }
    else if ( _regions_max_len <= 2000000 ) { 
      scale_length = 100000; 
      _scale_tag = "100 k" + units;
    }
    else if ( _regions_max_len <= 20000000 ) { 
      scale_length = 1000000; 
      _scale_tag = "1 M" + units;
    }
    _scale_pixel_length = round((float)scale_length*pixel_per_unit);
  }

  void render() {
   int x, y, w, h;

   //
   // render the regions
   //
    pushMatrix();
    translate( _regions_origin[0], _regions_origin[1] );

    Region region;

    int amt_scrolled = (int)(_percent_regions_start*_regions_h);
    pushMatrix();
    translate( 0, -amt_scrolled );

    int num_regions_skipped = floor( (float)amt_scrolled / (float)(REGION_HEIGHT+REGION_OFFSET) );
    int num_regions_ignored = max(0, floor( (float)(_regions_h - (amt_scrolled+_regions_view_h)) / (float)(REGION_HEIGHT+REGION_OFFSET) ));

    y = num_regions_skipped*(REGION_HEIGHT+REGION_OFFSET)+FEATURE_ABOVE_HEIGHT;

    IntervalFeature feature_above;
    FeatureType feature_type;
    IntervalFeature feature_below;
    int rolled_f_x=0, rolled_f_w=0, rolled_f_h=0;
    int start_region = 0;
    int skip_count = 0;
    for ( int i = 0; i < _regions.length; i++)
    {
      region = _regions[i];
      if (!region.show()) continue;
      skip_count++;
      if (skip_count == num_regions_skipped)
      {
        start_region = i+1;
        break;
      }
    }
    if (skip_count < num_regions_skipped)
    {
      start_region = _regions.length;
    }

    for ( int i = start_region; i < _regions.length-num_regions_ignored; i++ )
    {
      region = _regions[i];

      if ( !region.show() ) continue;

      // render the background strength bars
      rectMode( CORNERS );
      noStroke();
      // TODO figure out how to handle color, especially app level color that does not relate to the data (background etc)
      fill( REGION_MAX_VALUE_BAND_COLORS[0] );
      rect( region.renderStart(), y-FEATURE_ABOVE_HEIGHT, region.renderStop(), y-FEATURE_ABOVE_HEIGHT/2 );
      fill( REGION_MAX_VALUE_BAND_COLORS[1] );
      rect( region.renderStart(), y-FEATURE_ABOVE_HEIGHT/2, region.renderStop(), y );

      strokeWeight( REGION_LINE_WEIGHT );
      stroke( REGION_HALF_VALUE_LINE_COLOR );
      line( region.renderStart(), y-FEATURE_ABOVE_HEIGHT/2-1, region.renderStop(), y-FEATURE_ABOVE_HEIGHT/2-1 );
      stroke( REGION_MAX_VALUE_LINE_COLOR );
      line( region.renderStart(), y-FEATURE_ABOVE_HEIGHT, region.renderStop(), y-FEATURE_ABOVE_HEIGHT );
      line( region.renderStart(), y-FEATURE_ABOVE_HEIGHT, region.renderStart(), y );
      line( region.renderStop(), y-FEATURE_ABOVE_HEIGHT, region.renderStop(), y );


      // render the noncolored, not rolled over features
      rectMode( CORNER );
      for ( int j = 0; j < region.numIntervalFeaturesAbove(); j++ )
      {
        feature_above = region.intervalFeatureAbove(j);
        feature_type = _feature_above_types[feature_above.type()];

        if ( !feature_type.show() ) continue;
        if ( _feature_above_type_rolled_over && (_rolled_over_feature_above_type == feature_above.type()) ) continue;
        if ( !(feature_type.showColor() == DEFAULT_COLOR) ) continue;

        // first, render the filled in feature
        noStroke();
        fill( feature_type.showColor() );
        stroke( FEATURE_OUTLINE_COLOR );
        strokeWeight( 1 );

        x = region.renderStart() + round( feature_above.relativeStart()*region.pixelPerUnit() );
        w = max( round( feature_above.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );
        h = round( (float)FEATURE_ABOVE_HEIGHT * (feature_above.strength() - feature_type.minStrength())/feature_type.maxMinusMinStrength() );

        if ( _feature_above_rolled_over && (_rolled_over_region == i) && (_rolled_over_feature_above == j) )
        {
          rolled_f_x = x;
          rolled_f_w = w;
          rolled_f_h = h;
        }
        else {
          rect( x, y, w, -h );
        }
      }

      // render the colored, not rolled over features
      for ( int j = 0; j < region.numIntervalFeaturesAbove(); j++ )
      {
        feature_above = region.intervalFeatureAbove(j);
        feature_type = _feature_above_types[feature_above.type()];

        if ( !feature_type.show() ) continue;
        if ( _feature_above_type_rolled_over && (_rolled_over_feature_above_type == feature_above.type()) ) continue;
        if ( feature_type.showColor() == DEFAULT_COLOR ) continue;

        // first, render the filled in feature
        noStroke();
        fill( feature_type.showColor() );
        stroke( FEATURE_OUTLINE_COLOR );
        strokeWeight( 1 );

        x = region.renderStart() + round( feature_above.relativeStart()*region.pixelPerUnit() );
        w = max( round( feature_above.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );
        h = round( (float)FEATURE_ABOVE_HEIGHT * (feature_above.strength() - feature_type.minStrength())/feature_type.maxMinusMinStrength() );

        if ( _feature_above_rolled_over && (_rolled_over_region == i) && (_rolled_over_feature_above == j) )
        {
          rolled_f_x = x;
          rolled_f_w = w;
          rolled_f_h = h;
        }
        else {
          rect( x, y, w, -h );
        }
      }

      // render all the features with the rolled over feature type
      if ( _feature_above_type_rolled_over ) {
        for ( int j = 0; j < region.numIntervalFeaturesAbove(); j++ )
        {
          feature_above = region.intervalFeatureAbove(j);
          feature_type = _feature_above_types[feature_above.type()];

          if ( !feature_type.show() ) continue;
          if ( !(_feature_above_order[_rolled_over_feature_above_type] == feature_above.type()) ) continue;

          // first, render the filled in feature
          noStroke();
          fill( feature_type.showColor() );
          stroke( ROLLED_OVER_FEATURE_LINE_COLOR );
          strokeWeight( ROLLED_OVER_FEATURE_LINE_WEIGHT );

          x = region.renderStart() + round( feature_above.relativeStart()*region.pixelPerUnit() );
          w = max( round( feature_above.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );
          h = round( (float)FEATURE_ABOVE_HEIGHT * (feature_above.strength() - feature_type.minStrength())/feature_type.maxMinusMinStrength() );

          rect( x, y, w, -h );
        }
      }

      // render the rolled over feature
      if ( _feature_above_rolled_over && (_rolled_over_region == i) )
      {
        // render the feature
        feature_above = region.intervalFeatureAbove(_rolled_over_feature_above);
        feature_type = _feature_above_types[feature_above.type()];

        stroke( ROLLED_OVER_FEATURE_LINE_COLOR );
        strokeWeight( ROLLED_OVER_FEATURE_LINE_WEIGHT );
        fill( feature_type.showColor() );

        rect( rolled_f_x, y, rolled_f_w, -rolled_f_h );
        if (_feature_above_mouseX < 0) {
          _feature_above_mouseX = rolled_f_x + rolled_f_w / 2 + _regions_origin[0];
        }
        if (_feature_above_mouseY < 0) {
          _feature_above_mouseY = y - rolled_f_h / 2 + _regions_origin[1];
        }

      }

      // render the features below
      for ( int j = 0; j < region.numIntervalFeaturesBelow(); j++ )
      {
        feature_below = region.intervalFeatureBelow(j);

        if ( _feature_below_rolled_over && (_rolled_over_region == i) && (_rolled_over_feature_below == j ) )
        {
          stroke( ROLLED_OVER_FEATURE_LINE_COLOR );
          strokeWeight( ROLLED_OVER_FEATURE_LINE_WEIGHT );
        }
        else
        {
          stroke( FEATURE_LINE_COLOR );
          strokeWeight( FEATURE_LINE_WEIGHT );
        }

        x = region.renderStart() + round( feature_below.relativeStart()*region.pixelPerUnit() );
        line( x, y, x, y+FEATURE_BELOW_HEIGHT );
        w = max( round( feature_below.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );

        if (_feature_below_mouseX < 0) {
          _feature_below_mouseX = x + w / 2 + _regions_origin[0];
        }
        if (_feature_below_mouseY < 0) {
          _feature_below_mouseY = y + (FEATURE_BELOW_HEIGHT / 2) + _regions_origin[1];
        }

        if ( w != 0 ) // feature_below.len() != 0
        {
          // TODO incorporate feature_below strength into line height.
          // Right now, this rendering is assuming a uniform strength
          line( x, y+FEATURE_BELOW_HEIGHT, x+w, y+FEATURE_BELOW_HEIGHT );
          line( x+w, y+FEATURE_BELOW_HEIGHT, x+w, y );
        }
      }

      // render the region line
      stroke( REGION_LINE_COLOR );
      strokeWeight( REGION_LINE_WEIGHT );
      line( region.renderStart(), y, region.renderStop(), y );

      // render the region tag
      // TODO think about adding in the hierarchical display logic from ConditioningView here
      textFont( _pixel_font_8 );
      textAlign( RIGHT, CENTER );
      fill( REGION_TAG_TEXT_COLOR );
      text( region.tag(), /*region.renderStart()*/-REGION_TAG_OFFSET, y-FEATURE_ABOVE_HEIGHT/2-2 );


      y += REGION_HEIGHT+REGION_OFFSET;
    }

    popMatrix();


    // render over anything outside of the view area, as well as the scroll bar
    if ( _y_scroll_present ) {

      fill( BACKGROUND_COLOR );
      noStroke();
      rect( -_region_tag_max_width, _regions_view_h, _regions_view_w+_region_tag_max_width+1, WINDOW_BORDER_WIDTH );
      rect( -_region_tag_max_width, 0, _regions_view_w+_region_tag_max_width+1, -(WINDOW_BORDER_WIDTH+SCALE_BAR_OFFSET) );

      stroke( REGION_VIEW_OUTLINE_COLOR );
      strokeWeight( 1 );
      line( -_region_tag_max_width, 0, _regions_view_w+REGION_SCROLLBAR_OFFSET, 0 );
      line( _regions_view_w+REGION_SCROLLBAR_OFFSET, 0, _regions_view_w+REGION_SCROLLBAR_OFFSET, _regions_view_h );
      line( -_region_tag_max_width, _regions_view_h, _regions_view_w+REGION_SCROLLBAR_OFFSET, _regions_view_h );

      // render the scrollbar

      x = _regions_view_w + REGION_SCROLLBAR_OFFSET - REGION_SCROLLBAR_W/2;
      y = _y_scroll_bar_start;
      fill( REGION_VIEW_OUTLINE_COLOR );

      if ( !_y_scroll_bar_rolled_over ) noStroke();
      else stroke( SCROLL_BAR_HIGHLIGHT_COLOR );
      rect( x, y, REGION_SCROLLBAR_W, _y_scroll_bar_h );
    }

    // render the tags for rolled over features above or below
    if ( _feature_above_rolled_over ) {
      feature_above = _regions[_rolled_over_region].intervalFeatureAbove(_rolled_over_feature_above);

      String s1 = "coords: " + feature_above.start() + " - " + feature_above.stop();
      String s2 = feature_above.tag();
      textFont( _pixel_font_8 );
      textAlign( LEFT, BOTTOM );
      noStroke();
      fill( ROLL_OVER_TEXT_BOX_COLOR );
      if ( s2.length() == 0 ) {
        // TODO some of these offsets are based on the font size, figure out how to unhardcode them
        rect( _feature_above_mouseX-_regions_origin[0]+4, _feature_above_mouseY-_regions_origin[1]-8, textWidth(s1), -11 );
        fill( ROLL_OVER_TEXT_BOX_TEXT_COLOR );
        text( s1, _feature_above_mouseX-_regions_origin[0]+4+1, _feature_above_mouseY-_regions_origin[1]-8 );
      }
      else {
        rect( _feature_above_mouseX-_regions_origin[0]+4, _feature_above_mouseY-_regions_origin[1]-8, max(textWidth(s1), textWidth(s2)), -22 );
        fill( ROLL_OVER_TEXT_BOX_TEXT_COLOR );
        text( s2, _feature_above_mouseX-_regions_origin[0]+4+1, _feature_above_mouseY-_regions_origin[1]-19 );
        text( s1, _feature_above_mouseX-_regions_origin[0]+4+1, _feature_above_mouseY-_regions_origin[1]-8 );
      }
    }
    if ( _feature_below_rolled_over ) {
      feature_below = _regions[_rolled_over_region].intervalFeatureBelow(_rolled_over_feature_below);

      // render the tag
      if ( feature_below.len() == 0 ) {
        String s1 = "coord: " + feature_below.start();
        String s2 = feature_below.tag();
        textFont( _pixel_font_8 );
        textAlign( LEFT, BOTTOM );
        noStroke();
        fill( ROLL_OVER_TEXT_BOX_COLOR );
        if ( s2.length() == 0 ) {
          rect( _feature_below_mouseX-_regions_origin[0]+4, _feature_below_mouseY-_regions_origin[1]-8, textWidth(s1), -11 );
          fill( ROLL_OVER_TEXT_BOX_TEXT_COLOR );
          text( s1, _feature_below_mouseX-_regions_origin[0]+4+1, _feature_below_mouseY-_regions_origin[1]-8 );
        }
        else {
          rect( _feature_below_mouseX-_regions_origin[0]+4, _feature_below_mouseY-_regions_origin[1]-8, max(textWidth(s1), textWidth(s2)), -22 );
          fill( ROLL_OVER_TEXT_BOX_TEXT_COLOR );
          text( s2, _feature_below_mouseX-_regions_origin[0]+4+1, _feature_below_mouseY-_regions_origin[1]-19 );
          text( s1, _feature_below_mouseX-_regions_origin[0]+4+1, _feature_below_mouseY-_regions_origin[1]-8 );
        }
      }
      else {
        String s1 = "coords: " + feature_below.start() + " - " + feature_below.stop();
        String s2 = feature_below.tag();
        textFont( _pixel_font_8 );
        textAlign( LEFT, BOTTOM );
        noStroke();
        fill( ROLL_OVER_TEXT_BOX_COLOR );
        rect( _feature_below_mouseX-_regions_origin[0]+4, _feature_below_mouseY-_regions_origin[1]-8, max(textWidth(s1), textWidth(s2)), -22 );
        fill( ROLL_OVER_TEXT_BOX_TEXT_COLOR );
        text( s2, _feature_below_mouseX-_regions_origin[0]+4+1, _feature_below_mouseY-_regions_origin[1]-19 );
        text( s1, _feature_below_mouseX-_regions_origin[0]+4+1, _feature_below_mouseY-_regions_origin[1]-8 );
      }
    }

    // first, the scale bar
    y = -SCALE_BAR_OFFSET + 1; // +1 seems to be required for the QtWebView
    strokeWeight( SCALE_BAR_LINE_WEIGHT );
    stroke( SCALE_BAR_COLOR );
    textFont( _pixel_font_8 );
    fill( SCALE_BAR_COLOR );
    switch ( _region_alignment )
    {
    case REGION_ALIGNMENT_LEFT:
      line( 0, y, _scale_pixel_length, y );
      line( 0, y, 0, y+SCALE_BAR_H );
      line( _scale_pixel_length, y, _scale_pixel_length, y+SCALE_BAR_H );
      textAlign( LEFT, TOP );
      text( _scale_tag, _scale_pixel_length+4, y-3 );
      break;
    case REGION_ALIGNMENT_CENTER:
      line( _regions_view_w/2-_scale_pixel_length/2, y, _regions_view_w/2+_scale_pixel_length/2, y );
      line( _regions_view_w/2-_scale_pixel_length/2, y, _regions_view_w/2-_scale_pixel_length/2, y+SCALE_BAR_H );
      line( _regions_view_w/2+_scale_pixel_length/2, y, _regions_view_w/2+_scale_pixel_length/2, y+SCALE_BAR_H );
      textAlign( LEFT, TOP );
      text( _scale_tag, _regions_view_w/2+_scale_pixel_length/2+4, y-3 );
      break;
    case REGION_ALIGNMENT_RIGHT:
      line( _regions_view_w, y, _regions_view_w-_scale_pixel_length, y );
      line( _regions_view_w, y, _regions_view_w, y+SCALE_BAR_H );
      line( _regions_view_w-_scale_pixel_length, y, _regions_view_w-_scale_pixel_length, y+SCALE_BAR_H );
      textAlign( RIGHT, TOP );
      text( _scale_tag, _regions_view_w-_scale_pixel_length-4, y-3 );
      break;
    }

    popMatrix();
  }

  String overFeature( int mx, int my )
  {

    int amt_scrolled = (int)(_percent_regions_start*_regions_h);
    my += amt_scrolled;

    // determine which region the y position is in
    int index = 0;
    int num_regions_skipped = floor( (float)amt_scrolled / (float)(REGION_HEIGHT+REGION_OFFSET) );
    int y = num_regions_skipped*(REGION_HEIGHT+REGION_OFFSET);
    int num_active_regions = 0;
    for ( int j = 0; j < _regions.length; j++ )
    {
      if ( !_regions[j].show() ) continue;

      ++num_active_regions;
      if ( (my >= y) && (my <= y+REGION_HEIGHT) )
      {
        index = j;
        j = _regions.length;
      }
      y += REGION_HEIGHT + REGION_OFFSET;
    }
    int i = floor( (float)my/(float)(REGION_HEIGHT+REGION_OFFSET) );
    if ( i >= num_active_regions ) return "";

    // determine if it is above the line, below the line or in an offset space
    int diff = my - i*(REGION_HEIGHT+REGION_OFFSET);
    boolean above_line = false;
    if ( diff > REGION_HEIGHT ) return "";
    else if ( diff <= FEATURE_ABOVE_HEIGHT ) above_line = true;

    Region region = _regions[index];
    int x, w, h;

    if ( above_line )
    {
      IntervalFeature feature;
      FeatureType feature_type;

      // go through the features above the line
      for ( int j = region.numIntervalFeaturesAbove()-1; j >= 0; j-- )
      {
        feature = region.intervalFeatureAbove(j);
        feature_type = _feature_above_types[feature.type()];

        if ( !feature_type.show() ) continue;

        // get the location information
        x = region.renderStart() + round( feature.relativeStart()*region.pixelPerUnit() );
        w = max( round( feature.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );

        if ( (mx >= x) && (mx <= x+w) )
        {
          h = round( (float)FEATURE_ABOVE_HEIGHT * (feature.strength() - feature_type.minStrength())/feature_type.maxMinusMinStrength() );
          if ( FEATURE_ABOVE_HEIGHT-diff <= h )
          {
            _feature_above_rolled_over = true;
            _rolled_over_feature_above = j;
            _rolled_over_region = index;
            _feature_above_mouseX = mx+_regions_origin[0];
            _feature_above_mouseY = my+_regions_origin[1];
            return _regions[_rolled_over_region].intervalFeatureAbove(_rolled_over_feature_above).id();
          }
        }
        else continue;
      }
    }
    else
    {
      IntervalFeature feature;

      // go through the features below the line
      for ( int j = 0; j < region.numIntervalFeaturesBelow(); j++ )
      {
        feature = region.intervalFeatureBelow(j);

        // get the location information
        x = region.renderStart() + round( feature.relativeStart()*region.pixelPerUnit() );
        w = max( round( feature.len()*region.pixelPerUnit() ), FEATURE_MIN_WIDTH );

        if ( (mx >= x-1) && (mx <= x+w+1) )
        {
          _feature_below_rolled_over = true;
          _rolled_over_feature_below = j;
          _rolled_over_region = index;
          _feature_below_mouseX = mx+_regions_origin[0];
          _feature_below_mouseY = my+_regions_origin[1];

          return _regions[_rolled_over_region].intervalFeatureBelow(_rolled_over_feature_below).id();
        }
      }
    }
    return "";
  }

  boolean overYScrollBar( int my ) {
    _y_scroll_bar_rolled_over = false;
    if ( (my >= _y_scroll_bar_start) && (my <= _y_scroll_bar_start+_y_scroll_bar_h) ) _y_scroll_bar_rolled_over = true;
    return _y_scroll_bar_rolled_over;
  }

  boolean mouseOverRegions( int mx, int my ) {
    return ( (mx >= _regions_origin[0]) &&
             (mx <= _regions_origin[0]+_regions_view_w) &&
             (my >= _regions_origin[1]) &&
             (my <= _regions_origin[1]+_regions_view_h) );
  }

  boolean mouseOverYScrollBar( int mx, int my ) {
    return ( (mx > _regions_origin[0]+_regions_view_w+REGION_SCROLLBAR_OFFSET-REGION_SCROLLBAR_W/2) &&
             (mx <= _regions_origin[0]+_regions_view_w+REGION_SCROLLBAR_OFFSET+REGION_SCROLLBAR_W/2) &&
             (my >= _regions_origin[1]) &&
             (my <= _regions_origin[1]+_regions_view_h) );
  }

  void mouseMovedInView( int mx, int my )
  {
    _feature_above_rolled_over = _feature_below_rolled_over = _feature_above_type_rolled_over = false;
    _y_scroll_bar_rolled_over = false;
    String hovered_feature = "";

    // check if we are in the regions region
    if ( mouseOverRegions(mx, my) ) {
      hovered_feature = overFeature( mx-_regions_origin[0], my-_regions_origin[1] );
    }

    else if ( mouseOverYScrollBar(mx, my) ) {
      overYScrollBar( my-_regions_origin[1] );
    }

    // need to always call to make sure hovered_feature is alway up-to-date
    hoverItem(hovered_feature);

  }

  void pressedYScrollBar( int my ) {
    if ( !_y_scroll_bar_rolled_over ) return;

    _y_scroll_bar_pressed = true;
    _y_scroll_bar_pressed_y = my;
  }

  void mousePressedInView( int mx, int my, boolean rightPressed )
  {
    _y_scroll_bar_pressed = false;

    if ( mouseOverYScrollBar(mx, my) ) {
      pressedYScrollBar( my-_regions_origin[1] );
      draw();
    }
  }

  void mouseReleasedInView( int mx, int my )
  {
    _y_scroll_bar_pressed = false;
    draw();
  }

  void yScrollBarDragged( int my ) {
    int diff = my - _y_scroll_bar_pressed_y;

    if ( diff > 0 ) diff = min( diff, _regions_view_h - (_y_scroll_bar_start+_y_scroll_bar_h) );
    else diff = max( diff, -_y_scroll_bar_start );

    _y_scroll_bar_start += diff;
    _percent_regions_start = (float)_y_scroll_bar_start / (float)_regions_view_h;

    _y_scroll_bar_pressed_y = my;
  }

  void mouseDraggedInView( int mx, int my )
  {
    _feature_above_type_rolled_over = false;

    if ( _y_scroll_bar_pressed ) {
      yScrollBarDragged( my-_regions_origin[1] );
      draw();
    }
  }

  void mouseScrolledInView( int wr ) {
    if (_y_scroll_present) {
      _y_scroll_bar_pressed_y = 0;
      // for "normal" scrolling direction, use -wr
      // for Mac Lion default scrolling direction, use wr
      yScrollBarDragged( -wr );
      draw();
    }
  }

    // external API below
  void setup() {
    stroke(DEFAULT_COLOR);
    setAlignmentAndScaleParameters();

    // TODO: may want to make this part of base View class instead, with
    // option to add depending on subclass desires
    // following addMouseWheelListener definition plus
    // import java.awt.event.MouseWheelListener;
    // import java.awt.event.MouseWheelEvent;
    // needed for Processing.
    // Processing.js uses the mouseScrolled approach instead
    addMouseWheelListener( new MouseWheelListener() {
      public void mouseWheelMoved(MouseWheelEvent mwe) {
        mouseScrolledInView(mwe.getWheelRotation() * mwe.getWheelRotation() * mwe.getWheelRotation() * 2);
      }} );
  }

  void resize(int w, int h) {
    if ((w != _w) || (h != _h)) {
      _regions_w = _regions_view_w = w - FEATURE_LEGEND_OFFSET - _regions_origin[0];
      _regions_view_h = h - _regions_origin[1];
      setAlignmentAndScaleParameters();
      computeYScrollBarDimensions();
      super.resize(w, h);
    }
  }

}


