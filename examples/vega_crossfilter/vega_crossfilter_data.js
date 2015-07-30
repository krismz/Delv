var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.vega_crossfilter_data = function ( name ) {
  var newObj = new delv.data(name);
  newObj.chart = {};
  newObj.spec = {};
  newObj.setDelvIF(delv);

  newObj.resize = function(w, h) {};
  newObj.dataIF = function(name) {};
  newObj.reloadData = function(source) {};
  newObj.load_data = function(script, when_finished) {
    var view = this;
    d3.json(script, function(error, json) {
      view.spec = json;
      vg.parse.spec(json, function(chart) {
        view.create_dataIF(name);
        view.convert_to_dataIF(chart, name);
        when_finished();
      });
    });
  };

  newObj.updateDataTables = function() {
    var ds;
    var values;
    var dataIF;
    var vMin;
    var vMax;
    dataIF = delv.getDataIF(this.getName());
    ds = dataIF.getDataSet("times");
    vMin = ds.getVisibleMin("bin");
    vMax = ds.getVisibleMax("bin");
    ds.clearItems();
    values =  dataIF.chart.data("times").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin", id, elem["bin"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    if (typeof(vMin) !== "undefined") {
      ds.updateVisibleMin("bin", vMin);
    }
    if (typeof(vMax) !== "undefined") {
      ds.updateVisibleMax("bin", vMax);
    }

    ds = dataIF.getDataSet("distance");
    vMin = ds.getVisibleMin("bin");
    vMax = ds.getVisibleMax("bin");
    ds.clearItems();
    values =  dataIF.chart.data("distance").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin", id, elem["bin"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    if (typeof(vMin) !== "undefined") {
      ds.updateVisibleMin("bin", vMin);
    }
    if (typeof(vMax) !== "undefined") {
      ds.updateVisibleMax("bin", vMax);
    }

    ds = dataIF.getDataSet("delay");
    vMin = ds.getVisibleMin("bin");
    vMax = ds.getVisibleMax("bin");
    ds.clearItems();
    values =  dataIF.chart.data("delay").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin", id, elem["bin"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    if (typeof(vMin) !== "undefined") {
      ds.updateVisibleMin("bin", vMin);
    }
    if (typeof(vMax) !== "undefined") {
      ds.updateVisibleMax("bin", vMax);
    }

    ds = dataIF.getDataSet("date");
    vMin = ds.getVisibleMin("day");
    vMax = ds.getVisibleMax("day");
    ds.clearItems();
    values =  dataIF.chart.data("date").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      var day = new Date(Date.parse(""+elem["day"]));
      ds.addId(id);
      ds.setItem("day", id, ""+(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear());
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    if (typeof(vMin) !== "undefined") {
      ds.updateVisibleMin("day", vMin);
    }
    if (typeof(vMax) !== "undefined") {
      ds.updateVisibleMax("day", vMax);
    }

  };

  newObj.create_dataIF = function( name ) {
    var dataIF = delv.getDataIF(name);

    var ds = dataIF.addDataSet("times");
    var def_color = ["210", "210", "210"];
    ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

    ds = dataIF.addDataSet("delay");
    ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );


    ds = dataIF.addDataSet("distance");
    ds.addAttribute( new delv.attribute("bin", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

    ds = dataIF.addDataSet("date");
    ds.addAttribute( new delv.attribute("day", delv.AttributeType.DATETIME, new delv.colorMap(def_color), new delv.continuousRange()) );
    ds.addAttribute( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );

  };
  
  newObj.convert_to_dataIF = function( chart, name ) {
    var dataIF = delv.getDataIF(name);
    dataIF.chart = chart();
    dataIF.chart.update();
    this.updateDataTables();
  };


  newObj.onVisibilityChanged = function(invoker, dataset, attr) {
    var vMin;
    var vMax;
    var dataIF = delv.getDataIF(this.getName());

    vMin = dataIF.getVisibleMin(dataset, attr);
    if (typeof(vMin) === "undefined") {
      vMin = dataIF.getMin(dataset, attr);
    }
    vMax = dataIF.getVisibleMax(dataset, attr);
    if (typeof(vMax) === "undefined") {
      vMax = dataIF.getMax(dataset, attr);
    }

    // TODO big bug, vMax shouldn't still be undefined here.  Why?
    if (typeof(vMin) === "undefined") {
      vMin = vMax;
    }
    if (typeof(vMax) === "undefined") {
      vMax = vMin;
    }

    if (dataset === "times") {
      dataIF.chart.signal("minTime", vMin);
      dataIF.chart.signal("maxTime", vMax);
    } else if (dataset === "delay") {
      dataIF.chart.signal("minDelay", vMin);
      dataIF.chart.signal("maxDelay", vMax);
    } else if (dataset === "distance") {
      dataIF.chart.signal("minDist", vMin);
      dataIF.chart.signal("maxDist", vMax);
    } else if (dataset === "date") {
      dataIF.chart.signal("minDay", new Date(vMin));
      dataIF.chart.signal("maxDay", new Date(vMax));
    }
    dataIF.chart.update();
    this.updateDataTables();
    delv.reloadData("crossfilter_data");
  };

  delv.addDataIF(newObj);
  delv.addView(newObj, name);
  // TODO add signal handling to do crossfiltering
  delv.connectToSignal("dataVisibilityChanged", name, "onVisibilityChanged");

  return newObj;
};

