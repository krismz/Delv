// A simple test interface that reads in two column data from pointFile
// and stores it in a dataset called Points with attributes ids, pt0, and pt1

class SimpleTestData implements DelvBasicData {
  String _pointFile;
  String _dataset;
  String _highlightedID;
  String _hoveredID;
  ArrayList<String> _ids;
  ArrayList<String> _col0;
  ArrayList<String> _col1;

  SimpleTestData(String name, String pointFile) {
    super(name);
    readPoints(pointFile);
  }

  void readPoints(String filename) {
    String [] rows = loadStrings( filename );
    int rowcounter = 0;
    int itemcounter = 0;
    String[] cols;

    color def_col = color( 210, 210, 210 );
    DelvBasicDataSet ds = addDataSet("Points");
    ds.addAttribute(new DelvBasicAttribute("pt0", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));
    ds.addAttribute(new DelvBasicAttribute("pt1", AttributeType.CONTINUOUS, new DelvContinuousColorMap(def_col), new DelvContinuousRange()));

    while ( rowcounter < rows.length )
    {
      cols = splitTokens( rows[rowcounter++] );

      if ( cols.length == 0 )
        continue;

      else if (cols.length == 2 )
      {
        // ids will be one-based, and not contiguous
        String id = "" + itemcounter;
        itemcounter++;
        ds.addId(id);
        ds.setItem("pt0", id, cols[0]);
        ds.setItem("pt1", id, cols[1]);
      }
    }
  }



 
}
