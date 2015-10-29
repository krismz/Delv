// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt, Miriah Meyer, Kristi Potter
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================

public class InSiteDataSet extends DelvBasicDataSet {
  ArrayList _region_files;
  boolean _normalize_globally;
  DelvBasicDataSet _regions;
  DelvBasicDataSet _annotations;

  public InSiteDataSet(String name) {
    super(name);
    _normalize_globally = false;
    _global_min_v = 5.0;
  }

  // overridden functions
  public void loadData() {
    load_from_file("./test_data/config.txt");
  }

  void bindDelv(Delv dlv) {
    super.bindDelv(dlv);
    if (_regions != null) {
      dlv.addDataSet("Regions", _regions);
    }
    if (_annotations != null) {
      dlv.addDataSet("Annotations", _annotations);
    }
  }

  public void clearRegionFiles() {
    _region_files = new ArrayList();

    // set up datasets
    color def_col = color_( 210 );
    if (_delv != null) {
      _delv.removeDataSet("Regions");
    }
    DelvBasicDataSet ds = new DelvBasicDataSet("Regions");
    ds.addAttr(new DelvBasicAttribute("Species", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("Phenotype", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("class", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("start", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttr(new DelvBasicAttribute("length", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttr(new DelvBasicAttribute("motif_type", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("strength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttr(new DelvBasicAttribute("totalLength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    _regions = ds;

    if (_delv != null) {
      _delv.removeDataSet("Annotations");
    }
    ds = new DelvBasicDataSet("Annotations");
    ds.addAttr(new DelvBasicAttribute("Species", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("Phenotype", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("class", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
     ds.addAttr(new DelvBasicAttribute("start", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttr(new DelvBasicAttribute("length", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttr(new DelvBasicAttribute("description", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttr(new DelvBasicAttribute("totalLength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    _annotations = ds;
  }

  public void addRegionFile(String filename) {
    _region_files.add(filename);
  }

  public void updateConfig(String filename) {
    String[] rows = loadStrings( filename );

    int counter = 0;
    String[] cols;

    _normalize_globally = false;

    // read in the lines and store the file names
    while ( counter < rows.length )
    {
      cols = splitTokens( rows[counter++] );

      if ( cols.length == 0 )
        continue;

      else if ( cols[0].equals("REGION:") )
        _region_files.add( cols[1] );

      // _region_label ignored right now, hard-coded by inSite.js
      else if ( cols[0].equals("REGION_LABEL:") )
        _region_label = cols[1];

      // _type_label ignored right now, hard-coded by inSite.js
      else if ( cols[0].equals("TYPE_LABEL:") )
        _type_label = cols[1];

      else if ( cols[0].equals("NORMALIZATION:") ) {
        if ( cols[1].equalsIgnoreCase("global") ) _normalize_globally = true;
      }

      else if ( cols[0].equals("GLOBAL_MIN_VALUE:") )
        _global_min_v = parseFloat(cols[1]);
    }

  }

  public void updateRegions() {

    // read in the region files
    //_regions = new Region[region_files.size()];
    for ( int i = 0; i < _region_files.size(); i++ )
      readRegionFile( (String)_region_files.get(i) );

    // print( "    regions: " );
    // print( _regions[0].tag() );
    // for ( int i = 1; i < region_files.size(); i++ )
    //   print( ", " + _regions[i].tag() );
    // println();

    // store the binding site types
    // _binding_site_types = new BindingSiteType[types.size()];
    // _binding_site_order = new int[types.size()];
    // for ( int i = 0; i < types.size(); i++ ) {
    //   _binding_site_types[i] = new BindingSiteType( (String)types.get(i) );
    //   _binding_site_order[i] = i;
    // }

    // print( "    binding site types: " );
    // print( _binding_site_types[0].tag() );
    // for ( int i = 0; i < _binding_site_types.length; i++ )
    //   print( ", " + _binding_site_types[i].tag() );
    // println();
  
    // // determine the min and max strength values
    // determineMinMaxStrengths( normalize_globally );
  }


  // subclass-specific functions
  public void load_from_file(String filename) {
    clearRegionFiles();
    updateConfig(filename);
    updateRegions();
  }


  public void readRegionText( String txt) {
    String[] rows = splitTokens(txt, "\r\n");
    readRegionRows(rows);
  }
//
// REGION FILE
//
  public void readRegionFile( String file )
  {
    String[] rows = loadStrings( file );
    readRegionRows(rows);
  }

  void readRegionRows(String[] rows)
  {
    int counter = 0;
    String[] cols;

    // Region region = new Region();
    String name = "";
    String totLength = "";
    String pheno = "";
    while ( counter < rows.length )
    {
      cols = splitTokens( rows[counter++], ", :" );

      if ( cols.length == 0 )
        continue;

      else if ( cols[0].substring(0,2).equals("##") )
        continue;

      else if ( cols[0].equalsIgnoreCase("#NAME") )
        name = cols[1];

      else if ( cols[0].equalsIgnoreCase("#REGION_ATTRIBUTE1") )
        pheno = cols[1];

      // don't think we need region start right now, only item start
      // else if ( cols[0].equalsIgnoreCase("#START") )
      //   start = cols[1];

      else if ( cols[0].equalsIgnoreCase("#LENGTH") )
        totLength = cols[1];

      else if ( cols[0].equalsIgnoreCase("binding_site") )
      {
        DelvDataSet ds = _regions;
        String id = ds.getNextId();

        // TODO, really could get column names and position from file header
        // things are still somewhat hard-coded

        ds.addId(id);
        ds.setItem("Species", id, name);
        ds.setItem("Phenotype", id, pheno);
        ds.setItem("totalLength", id, totLength);
        ds.setItem("class", id, "binding_site");
        ds.setItem("start", id, cols[1]);
        ds.setItem("length", id, cols[2]);
        ds.setItem("motif_type", id, cols[3]);
        ds.setItem("strength", id, cols[4]);
      }

      else if ( cols[0].equalsIgnoreCase("feature") || cols[0].equalsIgnoreCase("annotation") )
      {
        DelvDataSet ds = _annotations;
        String id = ds.getNextId();

        // TODO, really could get column names and position from file header
        // things are still somewhat hard-coded

        ds.addId(id);
        ds.setItem("Species", id, name);
        ds.setItem("Phenotype", id, pheno);
        ds.setItem("totalLength", id, totLength);
        ds.setItem("class", id, "binding_site");
        ds.setItem("start", id, cols[1]);
        ds.setItem("length", id, cols[2]);
        if (cols.length >= 4) {
          ds.setItem("description", id, cols[3]);
        }
      }
    }

  }

} // end class InSiteDataSet
