// ======================================================================
// Copyright (c) 2013, Scientific Computing and Imaging Institute,
// University of Utah. All rights reserved.
// Author: Kris Zygmunt
// License: New BSD 3-Clause (see accompanying LICENSE file for details)
// ======================================================================
class d3DemoData extends DelvBasicData {

  // overridden functions
  void loadData() {
    load_from_file("./test_data/config.txt");
  }

  // subclass-specific functions
  void load_from_file(String filename) {
    println( "Reading config file..." );

    String[] rows = loadStrings( filename );

    int counter = 0;
    String[] cols;
    ArrayList region_files = new ArrayList();

    boolean normalize_globally = false;

    // read in the lines and store the file names
    while ( counter < rows.length )
    {
      cols = splitTokens( rows[counter++] );

      if ( cols.length == 0 )
        continue;

      else if ( cols[0].equals("REGION:") )
        region_files.add( cols[1] );

      // _region_label ignored right now, hard-coded by inSite.js
      else if ( cols[0].equals("REGION_LABEL:") )
        _region_label = cols[1];

      // _type_label ignored right now, hard-coded by inSite.js
      else if ( cols[0].equals("TYPE_LABEL:") )
        _type_label = cols[1];

      else if ( cols[0].equals("NORMALIZATION:") ) {
        if ( cols[1].equalsIgnoreCase("global") ) normalize_globally = true;
      }

      else if ( cols[0].equals("GLOBAL_MIN_VALUE:") )
        _global_min_v = parseFloat(cols[1]);
    }

    // set up datasets
    color def_col = color( 210, 210, 210 );
    DelvBasicDataSet ds = addDataSet("Regions");
    ds.addAttribute(new DelvBasicAttribute("Species", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("Phenotype", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("class", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("start", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("length", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("motif_type", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("strength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("totalLength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));

    ds = addDataSet("Annotations");
    ds.addAttribute(new DelvBasicAttribute("Species", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("Phenotype", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("class", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
     ds.addAttribute(new DelvBasicAttribute("start", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("length", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("description", AttributeType.CATEGORICAL, new DelvDiscreteColorMap(def_col), new DelvCategoricalRange()));
    ds.addAttribute(new DelvBasicAttribute("totalLength", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));


    // read in the region files
    //_regions = new Region[region_files.size()];
    for ( int i = 0; i < region_files.size(); i++ )
      readRegionFile( (String)region_files.get(i) );

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
    println("finished reading data");
  }

//
// REGION FILE
//
  void readRegionFile( String file )
  {
    String[] rows = loadStrings( file );

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
        DelvBasicDataSet ds = _data.get("Regions");
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
        DelvBasicDataSet ds = _data.get("Annotations");
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

} // end class d3DemoData
