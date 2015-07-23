var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.vega_crossfilter_data = function ( name ) {
  var newObj = new delv.data(name);
  newObj.chart = {};
  newObj.setDelvIF(delv);
  delv.addDataIF(newObj);

  newObj.load_data = function(script, when_finished) {
    delv.log("Loading data from " + script);
    d3.json(script, function(error, json) {
      delv.log("load_data, error: " + error);
      //vg.parse.spec(script, function(chart) {
      vg.parse.spec(json, function(chart) {
        delv.log("vg.parse.spec callback");
        vgWrapperNS.convert_to_dataIF(chart, name);
        when_finished();
      });
    });
  };
  return newObj;
};

vgWrapperNS.convert_to_dataIF = function( chart, name ) {
  delv.log("vgWrapperNS.convert_to_dataIF()");
  var dataIF = delv.getDataIF(name);
  dataIF.chart = chart();
  dataIF.chart.update();
  var ds = dataIF.addDataSet("flights");
  var def_color = ["210", "210", "210"];
  
  ds.addAttribute( new delv.attribute("origin", delv.AttributeType.UNSTRUCTURED, new delv.colorMap(def_color), new delv.dataRange()) );
  ds.addAttribute( new delv.attribute("destination", delv.AttributeType.UNSTRUCTURED, new delv.colorMap(def_color), new delv.dataRange()) );
  ds.addAttribute( new delv.attribute("date", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("day", delv.AttributeType.UNSTRUCTURED, new delv.colorMap(def_color), new delv.dataRange()) );
  ds.addAttribute( new delv.attribute("hour", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("distance", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  var values =  dataIF.chart.data("flights").values();
  for (var v = 0; v < values.length; v++) {
    var id = ""+v;
    var elem = values[v];
    ds.addId(id);
    ds.setItem("origin", id, elem["origin"]);
    ds.setItem("destination", id, elem["destination"]);
    ds.setItem("date", id, elem["date"]);
    ds.setItem("day", id, elem["day"]);
    ds.setItem("hour", id, elem["hour"]);
    ds.setItem("delay", id, elem["delay"]);
    ds.setItem("distance", id, elem["distance"]);
  }

  ds = dataIF.addDataSet("times");
  ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  values =  dataIF.chart.data("times").values();
  for (var v = 0; v < values.length; v++) {
    var id = ""+v;
    var elem = values[v];
    ds.addId(id);
    ds.setItem("bin", id, elem["bin"]);
    ds.setItem("count_delay", id, elem["count_delay"]);
  }

  ds = dataIF.addDataSet("delay");
  ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  values =  dataIF.chart.data("delay").values();
  for (var v = 0; v < values.length; v++) {
    var id = ""+v;
    var elem = values[v];
    ds.addId(id);
    ds.setItem("bin", id, elem["bin"]);
    ds.setItem("count_delay", id, elem["count_delay"]);
  }

  ds = dataIF.addDataSet("distance");
  ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
  ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  values =  dataIF.chart.data("distance").values();
  for (var v = 0; v < values.length; v++) {
    var id = ""+v;
    var elem = values[v];
    ds.addId(id);
    ds.setItem("bin", id, elem["bin"]);
    ds.setItem("count_delay", id, elem["count_delay"]);
  }

  ds = dataIF.addDataSet("date");
  ds.addAttribute( new delv.attribute("day", delv.AttributeType.UNSTRUCTURED, new delv.colorMap(def_color), new delv.dataRange()) );
  ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  values =  dataIF.chart.data("date").values();
  for (var v = 0; v < values.length; v++) {
    var id = ""+v;
    var elem = values[v];
    ds.addId(id);
    ds.setItem("day", id, elem["day"]);
    ds.setItem("count_delay", id, elem["count_delay"]);
  }
};
