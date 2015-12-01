var vgWrapperNS = vgWrapperNS || {};

vgWrapperNS.vega_crossfilter_data = function ( name ) {
  var newObj = new delv.dataSet(name);
  var view = new delv.view(name);
  delv.mixin(newObj, view);
  newObj.chart = {};
  newObj.spec = {};

  newObj.resize = function(w, h) {};
  newObj.onDataChanged = function(invoker, dataset) {};
  newObj.load_data = function(script, when_finished) {
    var view = this;
    d3.json(script, function(error, json) {
      view.spec = json;
      vg.parse.spec(json, function(chart) {
        view.create_dataSet(name);
        view.convert_to_dataSet(chart, name);
        when_finished();
      });
    });
  };

  newObj.updateDataTables = function() {
    var ds;
    var values;
    var vMin;
    var vMax;
    ds = delv.getDataSet("times");
    vMin = ds.getFilterMin("bin_hour");
    vMax = ds.getFilterMax("bin_hour");
    ds.clearItems();
    values =  this.chart.data("times").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin_hour", id, elem["bin_hour"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    ds.filterRanges("bin_hour", [vMin], [vMax]);

    ds = delv.getDataSet("distance");
    vMin = ds.getFilterMin("bin_dist");
    vMax = ds.getFilterMax("bin_dist");
    ds.clearItems();
    values =  this.chart.data("distance").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin_dist", id, elem["bin_dist"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    ds.filterRanges("bin_dist", [vMin], [vMax]);

    ds = delv.getDataSet("delay");
    vMin = ds.getFilterMin("bin_delay");
    vMax = ds.getFilterMax("bin_delay");
    ds.clearItems();
    values =  this.chart.data("delay").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      ds.addId(id);
      ds.setItem("bin_delay", id, elem["bin_delay"]);
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    ds.filterRanges("bin_delay", [vMin], [vMax]);

    ds = delv.getDataSet("date");
    vMin = ds.getFilterMin("day");
    vMax = ds.getFilterMax("day");
    ds.clearItems();
    values =  this.chart.data("date").values();
    for (var v = 0; v < values.length; v++) {
      var id = ""+v;
      var elem = values[v];
      var day = new Date(Date.parse(""+elem["day"]));
      ds.addId(id);
      ds.setItem("day", id, ""+(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear());
      ds.setItem("count_delay", id, elem["count_delay"]);
    }
    ds.filterRanges("day", [vMin], [vMax]);

    delv.dataChanged(name, "times");
    delv.dataChanged(name, "distance");
    delv.dataChanged(name, "delay");
    delv.dataChanged(name, "date");
  };

  newObj.create_dataSet = function( name ) {

    var ds = new delv.dataSet("times");
    var def_color = ["210", "210", "210"];
    ds.addAttr( new delv.attribute("bin_hour", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttr( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    delv.addDataSet("times", ds);

    ds = new delv.dataSet("delay");
    ds.addAttr( new delv.attribute("bin_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttr( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    delv.addDataSet("delay", ds);


    ds = new delv.dataSet("distance");
    ds.addAttr( new delv.attribute("bin_dist", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    ds.addAttr( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    delv.addDataSet("distance", ds);

    ds = new delv.dataSet("date");
    ds.addAttr( new delv.attribute("day", delv.AttributeType.DATETIME, new delv.colorMap(def_color), new delv.continuousRange()) );
    ds.addAttr( new delv.attribute("count_delay", delv.AttributeType.CONTINUOUS, new delv.continuousColorMap(def_color), new delv.continuousRange()) );
    delv.addDataSet("date", ds);

  };
  
  newObj.convert_to_dataSet = function( chart, name ) {
    //var dataSet = delv.getDataSet(name);
    this.chart = chart();
    this.chart.update();
    this.updateDataTables();
  };


  newObj.onFilterChanged = function(invoker, dataset, coordination, attr) {
    var fMin;
    var fMax;
    var minDate;
    var maxDate;

    fMin = delv.getFilterMin(dataset, attr);
    if (typeof(fMin) === "undefined") {
      fMin = delv.getMin(dataset, attr);
    }
    fMax = delv.getFilterMax(dataset, attr);
    if (typeof(fMax) === "undefined") {
      fMax = delv.getMax(dataset, attr);
    }

    // TODO big bug, fMax shouldn't still be undefined here.  Why?
    if (typeof(fMin) === "undefined") {
      fMin = fMax;
    }
    if (typeof(fMax) === "undefined") {
      fMax = fMin;
    }

    if (dataset === "times") {
      this.chart.signal("minTime", fMin);
      this.chart.signal("maxTime", fMax);
    } else if (dataset === "delay") {
      this.chart.signal("minDelay", fMin);
      this.chart.signal("maxDelay", fMax);
    } else if (dataset === "distance") {
      this.chart.signal("minDist", fMin);
      this.chart.signal("maxDist", fMax);
    } else if (dataset === "date") {
      var minDate = new Date(fMin);
      var maxDate = new Date(fMax);
      this.chart.signal("minDay", minDate.getTime());
      this.chart.signal("maxDay", maxDate.getTime());
    }
    this.chart.update();
    this.updateDataTables();
  };

  delv.addDataSet(name, newObj);
  delv.addView(newObj);
  // TODO add signal handling to do crossfiltering
  delv.connectToSignal("filterChanged", name, "onFilterChanged");

  return newObj;
};

