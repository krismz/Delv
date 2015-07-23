function init() {
  console.log("entering init");
  dataLoaded = false;

  var chartsrc = "./bar_chart.json";
  var viewsrc = "./bar_chart.js";
  var constructor = "vgWrapperNS.bar_chart_view";
  var id = "TimeOfDay";
  console.log("creating vega chart: " + id);
  var chart = new delv.vegaChart(id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Delay";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Distance";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, viewsrc, chartsrc, constructor, init_view_instance);
  
  id = "Date";
  console.log("creating vega chart: " + id);
  chart = new delv.vegaChart(id, viewsrc, chartsrc, constructor, init_view_instance);

  console.log("Initializing dataIF");
  dataIF = new vgWrapperNS.vega_crossfilter_data("vgDemo");
  dataIF.load_data("./data/vega_crossfilter_data.json", finishLoadingJSData);

  resizeAll();
}

function finishLoadingJSData() {
  console.log("finishLoadingJSData called");
  delv.giveDataIFToViews("vgDemo");
  delv.reloadData("vgDemo");
}

function init_view_instance(view, elemId) {
  delv.log("init_view_instance(" + view + ", " + elemId + ")");
  view.dataIF("vgDemo");
  if (elemId == "TimeOfDay") {
    view.setDatasetName("times")
      .setXAttr("bin")
      .setYAttr("count_delay")
      .setTitle("Time of Day", false)
      .setXDomain([0, 24], false)
      .renderSVG();
    
  } else if (elemId == "Delay") {
    view.setDatasetName("delay")
      .setXAttr("bin")
      .setYAttr("count_delay")
      .setTitle("Delay (min.)", false)
      .setXDomain([-60, 140], false)
      .renderSVG();
    
  } else if (elemId == "Distance") {
    view.setDatasetName("distance")
      .setXAttr("bin")
      .setYAttr("count_delay")
      .setTitle("Distance (mi.)", false)
      .setXDomain([0, 2000], false)
      .renderSVG();

  } else if (elemId == "Date") {
    view.setDatasetName("date")
      .setXAttr("day")
      .setYAttr("count_delay")
      .setTitle("Date", false)
      .setXDomain(["datetime('Jan 1 2001')", "datetime('Mar 31 2001')"])
      .xIsDate(true)
      .renderSVG();

  }
  delv.log("init_view_instance resizeAll");
  resizeAll();
}

function resizeAll() {
  delv.resizeAll();
}
